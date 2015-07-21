import Util

public struct Token {
    public var kind: TokenKind
    public var info: SourceInfo

    init(kind: TokenKind, info: SourceInfo) {
        self.kind = kind
        self.info = info
    }
}

class TokenStream {
    private struct Context {
        var source: String? = nil
        // set `CharacterClass.LineFeed` to `prev`
        // in order to remove line feed in the head of the file
        var prev: CharacterClass = .LineFeed
        var exprev: CharacterClass = .LineFeed

        let cp: CharacterPeeper
        let lineNo: () -> Int
        let charNo: () -> Int
        let _consume: () -> ()

        init(cs: CharacterStream) {
            cp = cs
            lineNo = { cs.lineNo }
            charNo = { cs.charNo }
            _consume = { cs.consume() }
        }

        mutating func reset() {
            source = nil
        }

        mutating func consume(consumed: CharacterClass? = nil, n: Int = 1) {
            if let cc = consumed {
                exprev = prev
                prev = cc
            }
            for var i = 0; i < n; ++i {
                let c = cp.look()!
                if source == nil {
                    source = String(c)
                } else {
                    source!.append(c)
                }
                _consume()
            }
        }
    }

    private var queue: [Token]!
    private var index: Int!
    private var ctx: Context!
    private var classifier: CharacterClassifier!

    init?(file: File) {
        if let cs = CharacterStream(file) {
            ctx = Context(cs: cs)
            classifier = CharacterClassifier(cp: cs)
            queue = [load()]
            index = 0
        } else {
            return nil
        }
    }

    func look(ahead: Int = 0, skipLineFeed: Bool = true) -> Token {
        if index + ahead >= queue.count {
            for var i = queue.count - 1; i < index + ahead; ++i {
                queue.append(load())
            }
        }
        let top = queue[index + ahead]
        if skipLineFeed && top.kind == .LineFeed {
            return look(ahead + 1, skipLineFeed: false)
        }
        return top
    }

    func next(n: Int = 1, skipLineFeed: Bool = true) {
        guard n > 0 else {
            return
        }
        if skipLineFeed && queue[index! + 1].kind == .LineFeed {
            ++index!
            next(n, skipLineFeed: skipLineFeed)
        } else {
            ++index!
            next(n - 1, skipLineFeed: skipLineFeed)
        }
    }

    func test(kinds: [TokenKind]) -> Bool {
        return examine(kinds).0
    }

    func match(kinds: [TokenKind]) -> TokenKind {
        return examine(kinds).1
    }

    private func examine(kinds: [TokenKind]) -> (Bool, TokenKind) {
        let skipLineFeed = kinds.contains(.LineFeed)
        let t = look(skipLineFeed: skipLineFeed)
        for k in kinds {
            if t.kind == k {
                next(skipLineFeed: skipLineFeed)
                return (true, t.kind)
            }
        }
        return (false, t.kind)
    }

    private func load(classified: CharacterClass? = nil) -> Token {
        var info = SourceInfo(lineNo: ctx.lineNo(), charNo: ctx.charNo())
        func produce(kind: TokenKind) -> Token {
            info.source = ctx.source
            ctx.reset()
            return Token(kind: kind, info: info)
        }

        let head = classified ?? classifier.classify()
        switch head {
        case .CarriageReturn:
            // ignore
            ctx.consume()
            return load()
        case .EndOfFile:
            return produce(.EndOfFile)
        case .LineFeed:
            switch ctx.prev {
            case .Space:
                // ignore line which is composed of the only spaces or block comments
                if ctx.exprev == .LineFeed {
                    fallthrough
                }
            case .LineFeed:
                // remove duplicated line feed (includes current one)
                ctx.consume()
                while true {
                    let cc = classifier.classify()
                    if cc == .LineFeed {
                        ctx.consume()
                    } else {
                        ctx.reset()
                        return load(cc)
                    }
                }
            default:
                break
            }
            ctx.consume(head)
            return produce(.LineFeed)
        case .Space:
            if ctx.prev == .Space {
                // remove duplicated space (includes current one)
                ctx.consume()
                while true {
                    let cc = classifier.classify()
                    if cc == .Space {
                        ctx.consume()
                    } else {
                        ctx.reset()
                        return load(cc)
                    }
                }
            } else {
                ctx.consume(head)
                return load()
            }
        case .Arrow:
            ctx.consume(head, n: 2)
            return produce(.Arrow)
        case .Equal:
            ctx.consume(head)
            return produce(.AssignmentOperator)
        case .Atmark:
            ctx.consume(head)
            return produce(.Atmark)
        case .Colon:
            ctx.consume(head)
            return produce(.Colon)
        case .Comma:
            ctx.consume(head)
            return produce(.Comma)
        case .Dot:
            ctx.consume(head)
            return produce(.Dot)
        case .Semicolon:
            ctx.consume(head)
            return produce(.Semicolon)
        case .Underscore:
            ctx.consume(head)
            return produce(.Underscore)
        case .LeftParenthesis:
            ctx.consume(head)
            return produce(.LeftParenthesis)
        case .RightParenthesis:
            ctx.consume(head)
            return produce(.RightParenthesis)
        case .LeftBrace:
            ctx.consume(head)
            return produce(.LeftBrace)
        case .RightBrace:
            ctx.consume(head)
            return produce(.RightBrace)
        case .LeftBracket:
            ctx.consume(head)
            return produce(.LeftBracket)
        case .RightBracket:
            ctx.consume(head)
            return produce(.RightBracket)
        case .LineCommentHead:
            ctx.consume(n: 2)
            while true {
                let cc = classifier.classify()
                switch cc {
                case .LineFeed, .EndOfFile:
                    // a comment produces nothing
                    ctx.reset()
                    // duplicative line feeds will be ignored
                    // in the lexical analyzation of line feed
                    return load(cc)
                default:
                    // ignore comment characters
                    ctx.consume()
                }
            }
        case .BlockCommentHead:
            ctx.consume(n: 2)
            // accepts nested comment
            var depth = 1
            while depth > 0 {
                switch classifier.classify() {
                case .BlockCommentHead:
                    ctx.consume(n: 2)
                    ++depth
                case .BlockCommentTail:
                    if ctx.prev != .Space {
                        // consume like a scape
                        ctx.consume(.Space, n: 2)
                    } else {
                        // avoid duplicative space consumption
                        ctx.consume(n: 2)
                    }
                    --depth
                case .EndOfFile:
                    info = SourceInfo(lineNo: ctx.lineNo(), charNo: ctx.charNo())
                    return produce(.Error(.UnexpectedEOF))
                default:
                    // ignore comment characters
                    ctx.consume()
                }
            }
            // a comment produces nothing
            ctx.reset()
            return load()
        case .BlockCommentTail:
            info = SourceInfo(lineNo: ctx.lineNo(), charNo: ctx.charNo())
            ctx.consume(n: 2)
            return produce(.Error(.ReservedToken))
        case .OperatorFollow, .IdentifierFollow, .BackSlash, .Others:
            info = SourceInfo(lineNo: ctx.lineNo(), charNo: ctx.charNo())
            ctx.consume()
            return produce(.Error(.InvalidToken))
        case .LessThan, .GraterThan, .Ampersand, .Question, .Exclamation:
            return produce(
                composerParse(head, composer: OperatorComposer(prev: ctx.prev))
            )
        case .OperatorHead, .DotOperatorHead:
            return produce(
                composerParse(head, composer: OperatorComposer(prev: ctx.prev))
            )
        case .Dollar:
            return produce(
                composerParse(head, composer: IdentifierComposer())
            )
        case .BackQuote:
            return produce(
                composerParse(head, composer: IdentifierComposer())
            )
        case .Minus:
            switch ctx.prev {
            case .LineFeed, .Semicolon, .Space,
                 .BlockCommentTail, .LeftParenthesis, .LeftBrace, .LeftBracket:
                return produce(
                    composerParse(head, composer: NumericLiteralComposer())
                )
            default:
                return produce(
                    composerParse(head, composer: OperatorComposer(prev: ctx.prev))
                )
            }
        case .Digit:
            return produce(
                composerParse(head, composer: NumericLiteralComposer())
            )
        case .DoubleQuote:
            return produce(
                composerParse(head, composer: StringLiteralComposer())
            )
        case .IdentifierHead:
            let composer = IdentifierComposer()
            var reservedWords: [WordLiteralComposer]?
            switch ctx.cp.look()! {
            case "a":
                reservedWords = [
                    WordLiteralComposer("as", .As),
                    WordLiteralComposer("associativity", .Associativity)
                ]
            case "b":
                reservedWords = [WordLiteralComposer("break", .Break)]
            case "c":
                reservedWords = [WordLiteralComposer("continue", .Continue)]
            case "d":
                reservedWords = [WordLiteralComposer("do", .Do)]
            case "e":
                reservedWords = [WordLiteralComposer("else", .Else)]
            case "f":
                reservedWords = [
                    WordLiteralComposer("false", .BooleanLiteral(false)),
                    WordLiteralComposer("for", .For),
                    WordLiteralComposer("func", .Func)
                ]
            case "i":
                reservedWords = [
                    WordLiteralComposer("if", .If),
                    WordLiteralComposer("infix", .Infix),
                    WordLiteralComposer("in", .In),
                    WordLiteralComposer("inout", .InOut),
                    WordLiteralComposer("is", .Is)
                ]
            case "l":
                reservedWords = [
                    WordLiteralComposer("left", .Left),
                    WordLiteralComposer("let", .Let)
                ]
            case "n":
                reservedWords = [
                    WordLiteralComposer("nil", .Nil),
                    WordLiteralComposer("none", .None)
                ]
            case "o":
                reservedWords = [WordLiteralComposer("operator", .Operator)]
            case "p":
                reservedWords = [
                    WordLiteralComposer("postfix", .Postfix),
                    WordLiteralComposer("precedence", .Precedence),
                    WordLiteralComposer("prefix", .Prefix)
                ]
            case "r":
                reservedWords = [
                    WordLiteralComposer("return", .Return),
                    WordLiteralComposer("right", .Right)
                ]
            case "t":
                reservedWords = [
                    WordLiteralComposer("true", .BooleanLiteral(true)),
                    WordLiteralComposer("typealias", .Typealias)
                ]
            case "v":
                reservedWords = [WordLiteralComposer("var", .Var)]
            case "u":
                reservedWords = [WordLiteralComposer("unowned", .Unowned)]
            case "w":
                reservedWords = [
                    WordLiteralComposer("weak", .Weak),
                    WordLiteralComposer("while", .While)
                ]
            default:
                break
            }
            var follow = head
            repeat {
                composer.put(follow, ctx.cp.look()!)
                reservedWords = reservedWords?.filter({
                    $0.put(follow, self.ctx.cp.look()!)
                })
                ctx.consume(follow)
                follow = classifier.classify()
            } while !composer.isEndOfToken(follow)

            if let kinds = reservedWords?.map({
                $0.compose(follow)
            }).filter({ $0 != nil }) {
                if kinds.count > 0 {
                    return produce(kinds[0]!)
                }
            }
            if let kind = composer.compose(follow) {
                return produce(kind)
            } else {
                return produce(.Error(.InvalidToken))
            }
        }
    }

    private func composerParse(
        head: CharacterClass, composer: TokenComposer
    ) -> TokenKind {
        var follow = head
        repeat {
            if !composer.put(follow, ctx.cp.look()!) {
                return .Error(.InvalidToken)
            }
            ctx.consume(follow)
            follow = classifier.classify()
        } while !composer.isEndOfToken(follow)

        if let kind = composer.compose(follow) {
            return kind
        } else {
            return .Error(.InvalidToken)
        }
    }
}
