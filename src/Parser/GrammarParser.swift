class GrammarParser {
    private let integerLiteral = TokenKind.IntegerLiteral(0, true)
    private let identifier = TokenKind.Identifier("")
    private let implicitParameterName = TokenKind.ImplicitParameterName(0)
    private let prefixOperator = TokenKind.PrefixOperator("")
    private let binaryOperator = TokenKind.BinaryOperator("")
    private let postfixOperator = TokenKind.PostfixOperator("")
    private let ts: TokenStream

    init(_ ts: TokenStream) {
        self.ts = ts
    }

    func find(startIndex: Int = 0, _ candidates: TokenKind...) -> (Int, TokenKind) {
        var i = startIndex
        var kind = ts.look(i).kind
        while kind != .EndOfFile {
            for c in candidates {
                if kind == c {
                    return (i, kind)
                }
            }
            kind = ts.look(++i).kind
        }
        return (i, .EndOfFile)
    }

    func findInsideOfBrackets(
        startIndex: Int = 0, _ candidates: TokenKind...
    ) -> (Int, TokenKind) {
        var i = startIndex
        var nest = 0
        while true {
            let kind = ts.look(i).kind
            switch kind {
            case .EndOfFile:
                return (i, .EndOfFile)
            case .LeftBracket:
                ++nest
            case .RightBracket:
                if nest == 0 {
                    return (i, .RightBracket)
                }
                --nest
            default:
                for c in candidates {
                    if kind == c {
                        return (i, kind)
                    }
                }
                ++i
            }
        }
    }

    func getValueRef(name: String) throws -> ValueRef {
        if name == "" {
            throw ParserError.Error("dummy error")
        }
        return ValueRef(name)
    }

    func getImplicitParameterRef(num: Int) throws -> ValueRef {
        if num < 0 {
            throw ParserError.Error("dummy error")
        }
        return ValueRef(String(num))
    }

    func getOperatorRef(name: String) throws -> OperatorRef {
        if name == "" {
            throw ParserError.Error("dummy error")
        }
        return OperatorRef(name)
    }

    func getMemberRef(name: String) throws -> MemberRef {
        if name == "" {
            throw ParserError.Error("dummy error")
        }
        return MemberRef(name)
    }

    func getTypeRef(name: String) throws -> TypeRef {
        if name == "" {
            throw ParserError.Error("dummy error")
        }
        return TypeRef(name)
    }
}
