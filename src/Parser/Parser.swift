import Util
import AST

public class Parser {
    private let moduleName: String

    public init(moduleName: String, modules: [String:String]) {
        self.moduleName = moduleName
        for (name, fileName) in modules {
            ScopeManager.addImportableModule(name, parseModule(fileName))
        }
    }

    public func parseModule(fileName: String)() throws -> [Declaration] {
        do {
            let parser = prepareDeclarationParser(try createStream(fileName))
            return try parser.moduleDeclarations()
        } catch let e {
            ErrorReporter.instance.bundle(fileName)
            throw e
        }
    }

    public func parse(
        fileNames: [String], useStdLib: Bool = true
    ) throws -> [String:TopLevelDeclaration] {
        var result: [String:TopLevelDeclaration] = [:]
        if useStdLib {
            try ScopeManager.importModule("TreeSwift", nil)
        }
        for fileName in fileNames {
            do {
                let parser = prepareDeclarationParser(try createStream(fileName))
                result[fileName] = try parser.topLevelDeclaration(fileName)
                ErrorReporter.instance.bundle(fileName)
            } catch let e {
                ErrorReporter.instance.bundle(fileName)
                throw e
            }
        }
        try specifyMain(result)
        return result
    }

    private func createStream(fileName: String) throws -> TokenStream {
        guard let f = File(name: fileName, mode: "r") else {
            throw ErrorReporter.instance.fatal(.FileNotFound(fileName), nil)
        }
        guard let ts = TokenStream(file: f) else {
            throw ErrorReporter.instance.fatal(.FileCanNotRead(fileName), nil)
        }
        return ts
    }

    private func specifyMain(tlds: [String:TopLevelDeclaration]) throws {
        var found: String?
        for (name, tld) in tlds {
            for p in tld.procedures {
                guard case .DeclarationProcedure = p else {
                    if let n = found {
                        throw ErrorReporter.instance.fatal(.MultipleMain(n, name), nil)
                    }
                    tld.isMain = true
                    found = name
                    break
                }
            }
        }
    }

    private func prepareDeclarationParser(ts: TokenStream) -> DeclarationParser {
        let ap = AttributesParser(ts)
        let gp = GenericsParser(ts)
        let tp = TypeParser(ts)
        let ep = ExpressionParser(ts)
        let dp = DeclarationParser(ts)
        let pp = PatternParser(ts)
        let prp = ProcedureParser(ts)
        gp.setParser(typeParser: tp)
        tp.setParser(attributesParser: ap, genericsParser: gp)
        ep.setParser(
            typeParser: tp, genericsParser: gp, procedureParser: prp,
            expressionParser: ep, declarationParser: dp
        )
        dp.setParser(
            procedureParser: prp, patternParser: pp, expressionParser: ep,
            typeParser: tp, attributesParser: ap, genericsParser: gp
        )
        pp.setParser(typeParser: tp, expressionParser: ep)
        prp.setParser(
            declarationParser: dp, patternParser: pp,expressionParser: ep,
            attributesParser: ap
        )
        return dp
    }
}
