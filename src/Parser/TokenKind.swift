import Util
import AST

public enum ModifierKind {
    case Convenience, Dynamic, Final, Lazy, Mutating, Nonmutating
    case Optional, Override, Required, Static, Unowned, Weak
    case Internal, Private, Public
}

public enum TokenKind : Equatable {
    case Error(ErrorMessage)
    case EndOfFile, LineFeed
    // symbols
    case Arrow, AssignmentOperator, Atmark, BinaryQuestion
    case Colon, Comma, Dot, PostfixExclamation, PostfixGraterThan, PostfixQuestion
    case PrefixAmpersand, PrefixLessThan, PrefixQuestion, Semicolon, Underscore
    // brackets
    case LeftParenthesis, RightParenthesis
    case LeftBrace, RightBrace
    case LeftBracket, RightBracket
    // operators
    case PrefixOperator(String), BinaryOperator(String), PostfixOperator(String)
    // value references
    case Identifier(String), ImplicitParameterName(Int)
    // literals
    case IntegerLiteral(Int64, decimalDigits: Bool)
    case FloatingPointLiteral(Double)
    case StringLiteral(String)
    case BooleanLiteral(Bool)
    case COLUMN, FILE, FUNCTION, LINE
    // modifier
    case Modifier(ModifierKind)
    // reserved words
    case As, Associativity, Break, Catch, Case, Class, Continue, Default, Defer
    case Deinit, DidSet, Do, DynamicType, Enum, Extension, Fallthrough, Else, For
    case Func, Get, Guard, If, Import, In, Indirect, Infix, Init, InOut, Is, Let
    case Left, Nil, None, Operator, Postfix, Prefix, Protocol, Precedence, Repeat
    case Rethrows, Return, Right, Safe, `Self`, Set, Struct, Subscript, Super
    case Switch, Throw, Throws, Try, Typealias, Unsafe, Var, Where
    case While, WillSet, PROTOCOL, TYPE
}

public func ==(lhs: TokenKind, rhs: TokenKind) -> Bool {
    switch lhs {
    case .Error:
        if case .Error = rhs {
            return true
        }
    case .EndOfFile:
        if case .EndOfFile = rhs {
            return true
        }
    case .LineFeed:
        if case .LineFeed = rhs {
            return true
        }
    case .Arrow:
        if case .Arrow = rhs {
            return true
        }
    case .AssignmentOperator:
        if case .AssignmentOperator = rhs {
            return true
        }
    case .Atmark:
        if case .Atmark = rhs {
            return true
        }
    case .BinaryQuestion:
        if case .BinaryQuestion = rhs {
            return true
        }
    case .Colon:
        if case .Colon = rhs {
            return true
        }
    case .Comma:
        if case .Comma = rhs {
            return true
        }
    case .Dot:
        if case .Dot = rhs {
            return true
        }
    case .PostfixExclamation:
        if case .PostfixExclamation = rhs {
            return true
        }
    case .PostfixGraterThan:
        if case .PostfixGraterThan = rhs {
            return true
        }
    case .PostfixQuestion:
        if case .PostfixQuestion = rhs {
            return true
        }
    case .PrefixAmpersand:
        if case .PrefixAmpersand = rhs {
            return true
        }
    case .PrefixLessThan:
        if case .PrefixLessThan = rhs {
            return true
        }
    case .PrefixQuestion:
        if case .PrefixQuestion = rhs {
            return true
        }
    case .Semicolon:
        if case .Semicolon = rhs {
            return true
        }
    case .Underscore:
        if case .Underscore = rhs {
            return true
        }
    case .LeftParenthesis:
        if case .LeftParenthesis = rhs {
            return true
        }
    case .RightParenthesis:
        if case .RightParenthesis = rhs {
            return true
        }
    case .LeftBrace:
        if case .LeftBrace = rhs {
            return true
        }
    case .RightBrace:
        if case .RightBrace = rhs {
            return true
        }
    case .LeftBracket:
        if case .LeftBracket = rhs {
            return true
        }
    case .RightBracket:
        if case .RightBracket = rhs {
            return true
        }
    case .PrefixOperator:
        if case .PrefixOperator = rhs {
            return true
        }
    case .BinaryOperator:
        if case .BinaryOperator = rhs {
            return true
        }
    case .PostfixOperator:
        if case .PostfixOperator = rhs {
            return true
        }
    case .Identifier:
        if case .Identifier = rhs {
            return true
        }
    case .ImplicitParameterName:
        if case .ImplicitParameterName = rhs {
            return true
        }
    case .IntegerLiteral:
        if case .IntegerLiteral = rhs {
            return true
        }
    case .FloatingPointLiteral:
        if case .FloatingPointLiteral = rhs {
            return true
        }
    case .StringLiteral:
        if case .StringLiteral = rhs {
            return true
        }
    case .BooleanLiteral:
        if case .BooleanLiteral = rhs {
            return true
        }
    case .COLUMN:
        if case .COLUMN = rhs {
            return true
        }
    case .FILE:
        if case .FILE = rhs {
            return true
        }
    case .FUNCTION:
        if case .FUNCTION = rhs {
            return true
        }
    case .LINE:
        if case .LINE = rhs {
            return true
        }
    case .Modifier:
        if case .Modifier = rhs {
            return true
        }
    case .As:
        if case .As = rhs {
            return true
        }
    case .Associativity:
        if case .Associativity = rhs {
            return true
        }
    case .Break:
        if case .Break = rhs {
            return true
        }
    case .Catch:
        if case .Catch = rhs {
            return true
        }
    case .Case:
        if case .Case = rhs {
            return true
        }
    case .Class:
        if case .Class = rhs {
            return true
        }
    case .Continue:
        if case .Continue = rhs {
            return true
        }
    case .Default:
        if case .Default = rhs {
            return true
        }
    case .Defer:
        if case .Defer = rhs {
            return true
        }
    case .Deinit:
        if case .Deinit = rhs {
            return true
        }
    case .DidSet:
        if case .DidSet = rhs {
            return true
        }
    case .Do:
        if case .Do = rhs {
            return true
        }
    case .DynamicType:
        if case .DynamicType = rhs {
            return true
        }
    case .Enum:
        if case .Enum = rhs {
            return true
        }
    case .Extension:
        if case .Extension = rhs {
            return true
        }
    case .Fallthrough:
        if case .Fallthrough = rhs {
            return true
        }
    case .Else:
        if case .Else = rhs {
            return true
        }
    case .For:
        if case .For = rhs {
            return true
        }
    case .Func:
        if case .Func = rhs {
            return true
        }
    case .Get:
        if case .Get = rhs {
            return true
        }
    case .Guard:
        if case .Guard = rhs {
            return true
        }
    case .If:
        if case .If = rhs {
            return true
        }
    case .Import:
        if case .Import = rhs {
            return true
        }
    case .In:
        if case .In = rhs {
            return true
        }
    case .Indirect:
        if case .Indirect = rhs {
            return true
        }
    case .Infix:
        if case .Infix = rhs {
            return true
        }
    case .Init:
        if case .Init = rhs {
            return true
        }
    case .InOut:
        if case .InOut = rhs {
            return true
        }
    case .Is:
        if case .Is = rhs {
            return true
        }
    case .Let:
        if case .Let = rhs {
            return true
        }
    case .Left:
        if case .Left = rhs {
            return true
        }
    case .Nil:
        if case .Nil = rhs {
            return true
        }
    case .None:
        if case .None = rhs {
            return true
        }
    case .Operator:
        if case .Operator = rhs {
            return true
        }
    case .Postfix:
        if case .Postfix = rhs {
            return true
        }
    case .Prefix:
        if case .Prefix = rhs {
            return true
        }
    case .Protocol:
        if case .Protocol = rhs {
            return true
        }
    case .Precedence:
        if case .Precedence = rhs {
            return true
        }
    case .Repeat:
        if case .Repeat = rhs {
            return true
        }
    case .Rethrows:
        if case .Rethrows = rhs {
            return true
        }
    case .Return:
        if case .Return = rhs {
            return true
        }
    case .Right:
        if case .Right = rhs {
            return true
        }
    case .Safe:
        if case .Safe = rhs {
            return true
        }
    case .Set:
        if case .Set = rhs {
            return true
        }
    case .`Self`:
        if case .`Self` = rhs {
            return true
        }
    case .Struct:
        if case .Struct = rhs {
            return true
        }
    case .Subscript:
        if case .Subscript = rhs {
            return true
        }
    case .Super:
        if case .Super = rhs {
            return true
        }
    case .Switch:
        if case .Switch = rhs {
            return true
        }
    case .Throw:
        if case .Throw = rhs {
            return true
        }
    case .Throws:
        if case .Throws = rhs {
            return true
        }
    case .Try:
        if case .Try = rhs {
            return true
        }
    case .Typealias:
        if case .Typealias = rhs {
            return true
        }
    case .Unsafe:
        if case .Unsafe = rhs {
            return true
        }
    case .Var:
        if case .Var = rhs {
            return true
        }
    case .Where:
        if case .Where = rhs {
            return true
        }
    case .While:
        if case .While = rhs {
            return true
        }
    case .WillSet:
        if case .WillSet = rhs {
            return true
        }
    case .PROTOCOL:
        if case .PROTOCOL = rhs {
            return true
        }
    case .TYPE:
        if case .TYPE = rhs {
            return true
        }
    }
    return false
}
