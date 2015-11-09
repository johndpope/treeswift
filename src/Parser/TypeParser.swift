import AST

class TypeParser : GrammarParser {
    private var ap: AttributesParser!
    private var gp: GenericsParser!

    func setParser(
        attributesParser ap: AttributesParser,
        genericsParser gp: GenericsParser
    ) {
        self.ap = ap
        self.gp = gp
    }

    func typeAnnotation() throws -> (Type, [Attribute])? {
        if ts.test([.Colon]) {
            return (try type(), try ap.attributes())
        }
        return nil
    }

    func type() throws -> Type {
        return try containerType(try primaryType())
    }

    private func primaryType() throws -> Type {
        let trackable = ts.look()
        switch ts.match([identifier, .LeftBracket, .LeftParenthesis, .Protocol]) {
        case let .Identifier(s):
            return try identifierType(s, trackable)
        case .LeftBracket:
            return try collectionType()
        case .LeftParenthesis:
            return try tupleType()
        case .Protocol:
            return try protocolCompositionType()
        default:
            throw ts.fatal(.ExpectedType)
        }
    }

    func identifierType(
        s: String, _ trackable: SourceTrackable
    ) throws -> IdentifierType {
        return IdentifierType(
            try ScopeManager.createTypeRef(s, trackable),
            try gp.genericArgumentClause(),
            try nestedTypes()
        )
    }

    private func nestedTypes() throws -> [(String, [Type]?)] {
        var x: [(String, [Type]?)] = []
        while ts.look().kind == .Dot {
            guard case let .Identifier(s) = ts.match([identifier], ahead: 1) else {
                return x
            }
            x.append(s, try gp.genericArgumentClause())
        }
        return x
    }

    private func collectionType() throws -> Type {
        let t = try type()
        switch ts.match([.RightBracket, .Colon]) {
        case .RightBracket:
            return ArrayType(t)
        case .Colon:
            return DictionaryType(t, try type())
        default:
            throw ts.fatal(.ExpectedSymbolForAggregator)
        }
    }

    func tupleType() throws -> TupleType {
        let x = TupleType()
        // unit
        if ts.test([.RightParenthesis]) {
            return x
        }
        repeat {
            x.elems.append(try tupleTypeElement())
        } while ts.test([.Comma])
        switch ts.match([.RightParenthesis]) {
        case .PrefixOperator("..."), .BinaryOperator("..."), .PostfixOperator("..."):
            ts.next()
            x.variadic = true
            if !ts.test([.RightParenthesis]) {
                try ts.error(.ExpectedRightParenthesisAfterTupleType)
            }
            return x
        case .RightParenthesis:
            return x
        default:
            throw ts.fatal(.ExpectedRightParenthesisAfterTupleType)
        }
    }

    private func tupleTypeElement() throws -> TupleTypeElement {
        let x = TupleTypeElement()
        switch ts.look().kind {
        case .Atmark:
            x.attrs = try ap.attributes()
            if ts.test([.InOut]) {
                x.inOut = true
            }
            x.type = try type()
            return x
        case .InOut:
            x.inOut = true
            ts.next()
            if case let .Identifier(s) = ts.match([identifier]) {
                return try tupleTypeElementBody(x, s)
            }
            x.type = try type()
            return x
        case let .Identifier(s):
            ts.next()
            return try tupleTypeElementBody(x, s)
        default:
            x.type = try type()
            return x
        }
    }

    private func tupleTypeElementBody(
        x: TupleTypeElement, _ s: String
    ) throws -> TupleTypeElement {
        if let (type, attrs) = try typeAnnotation() {
            x.label = s
            x.attrs = attrs
            x.type = type
            return x
        }
        x.type = try type()
        return x
    }

    func protocolCompositionType() throws -> ProtocolCompositionType {
        if !ts.test([.PrefixLessThan]) {
            try ts.error(.ExpectedLessThanForProtocolCompositionType)
        }
        let x = ProtocolCompositionType()
        // empty list
        if ts.test([.PostfixGraterThan]) {
            return x
        }
        repeat {
            let trackable = ts.look()
            guard case let .Identifier(s) = ts.match([identifier]) else {
                throw ts.fatal(.ExpectedTypeIdentifierForProtocolCompositionType)
            }
            x.types.append(try identifierType(s, trackable))
        } while ts.test([.Comma])
        if !ts.test([.PostfixGraterThan]) {
            try ts.error(.ExpectedGraterThanAfterProtocolCompositionType)
        }
        return x
    }

    private func containerType(t: Type) throws -> Type {
        switch ts.match([
            .Throws, .Rethrows, .Arrow, .PostfixQuestion, .PostfixExclamation, .Dot
        ]) {
        case .Throws:
            return try functionType(t, .Throws)
        case .Rethrows:
            return try functionType(t, .Rethrows)
        case .Arrow:
            return try functionType(t, .Nothing)
        case .PostfixQuestion:
            return OptionalType(t)
        case .PostfixExclamation:
            return ImplicitlyUnwrappedOptionalType(t)
        case .Dot:
            switch ts.match([.TYPE, .PROTOCOL]) {
            case .TYPE:
                return MetaType(t)
            case .PROTOCOL:
                return MetaProtocol(t)
            default:
                throw ts.fatal(.ExpectedMetatypeType)
            }
        default:
            return t
        }
    }

    private func functionType(t: Type, _ throwType: ThrowType) throws -> Type {
        return FunctionType(t, .Nothing, try type())
    }
}
