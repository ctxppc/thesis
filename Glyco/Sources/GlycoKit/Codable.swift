// Generated using Sourcery 1.8.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension AL.Program {
	public enum CodingKeys : String, CodingKey {
		case locals = "locals"
		case effect = "in"
		case procedures = "procedures"
	}
}

extension AL.Procedure {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case locals = "locals"
		case effect = "in"
	}
}

extension ALA.Program {
	public enum CodingKeys : String, CodingKey {
		case locals = "locals"
		case effect = "in"
		case procedures = "procedures"
	}
}

extension ALA.ConflictGraph {
	public enum CodingKeys : String, CodingKey {
		case conflicts = "_0"
	}
}

extension ALA.Conflict {
	public enum CodingKeys : String, CodingKey {
		case first = "_0"
		case second = "_1"
	}
}

extension ALA.Procedure {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case locals = "locals"
		case effect = "in"
	}
}

extension ALA.Analysis {
	public enum CodingKeys : String, CodingKey {
		case conflicts = "conflicts"
		case possiblyLiveLocations = "possiblyLiveLocations"
	}
}

extension BB.Program {
	public enum CodingKeys : String, CodingKey {
		case blocks = "_0"
	}
}

extension BB.Block {
	public enum CodingKeys : String, CodingKey {
		case name = "name"
		case effects = "do"
		case continuation = "then"
	}
}

extension CA.Program {
	public enum CodingKeys : String, CodingKey {
		case effect = "_0"
		case procedures = "procedures"
	}
}

extension CA.Procedure {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case parameters = "takes"
		case resultType = "returns"
		case effect = "in"
	}
}

extension CC.Program {
	public enum CodingKeys : String, CodingKey {
		case effect = "_0"
		case procedures = "procedures"
	}
}

extension CC.RecordType {
	public enum CodingKeys : String, CodingKey {
		case fields = "_0"
	}
}

extension CC.Field {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case valueType = "_1"
	}
}

extension CC.Parameter {
	public enum CodingKeys : String, CodingKey {
		case location = "_0"
		case type = "_1"
		case sealed = "sealed"
	}
}

extension CC.Procedure {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case parameters = "takes"
		case resultType = "returns"
		case effect = "in"
	}
}

extension CD.Program {
	public enum CodingKeys : String, CodingKey {
		case effect = "_0"
		case procedures = "procedures"
	}
}

extension CD.Procedure {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case effect = "in"
	}
}

extension CE.Program {
	public enum CodingKeys : String, CodingKey {
		case statements = "_0"
	}
}

extension CV.Program {
	public enum CodingKeys : String, CodingKey {
		case effect = "_0"
		case procedures = "procedures"
	}
}

extension CV.Procedure {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case parameters = "takes"
		case resultType = "returns"
		case effect = "in"
	}
}

extension DF.Program {
	public enum CodingKeys : String, CodingKey {
		case result = "_0"
		case functions = "functions"
	}
}

extension DF.Definition {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case value = "_1"
	}
}

extension DF.Function {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case parameters = "takes"
		case resultType = "returns"
		case result = "in"
	}
}

extension EX.Program {
	public enum CodingKeys : String, CodingKey {
		case result = "_0"
		case functions = "functions"
	}
}

extension EX.Definition {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case value = "_1"
	}
}

extension EX.Function {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case parameters = "takes"
		case resultType = "returns"
		case result = "in"
	}
}

extension FO.Program {
	public enum CodingKeys : String, CodingKey {
		case effects = "_0"
	}
}

extension ID.Program {
	public enum CodingKeys : String, CodingKey {
		case effect = "_0"
		case procedures = "procedures"
	}
}

extension ID.Procedure {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case effect = "in"
	}
}

extension LS.Program {
	public enum CodingKeys : String, CodingKey {
		case result = "_0"
		case functions = "functions"
	}
}

extension LS.Parameter {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case type = "_1"
		case sealed = "sealed"
	}
}

extension LS.Function {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case parameters = "takes"
		case resultType = "returns"
		case result = "in"
	}
}

extension LS.Definition {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case value = "_1"
	}
}

extension LS.RecordType {
	public enum CodingKeys : String, CodingKey {
		case fields = "_0"
	}
}

extension LS.Field {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case valueType = "_1"
	}
}

extension MM.Program {
	public enum CodingKeys : String, CodingKey {
		case effects = "_0"
	}
}

extension MM.Frame {
	public enum CodingKeys : String, CodingKey {
		case allocatedByteSize = "allocatedByteSize"
	}
}

extension NT.Program {
	public enum CodingKeys : String, CodingKey {
		case result = "_0"
		case functions = "functions"
	}
}

extension NT.Definition {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case value = "_1"
	}
}

extension NT.RecordType {
	public enum CodingKeys : String, CodingKey {
		case fields = "_0"
	}
}

extension NT.Field {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case valueType = "_1"
	}
}

extension NT.Function {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case parameters = "takes"
		case resultType = "returns"
		case result = "in"
	}
}

extension NT.Parameter {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case type = "_1"
		case sealed = "sealed"
	}
}

extension OB.Program {
	public enum CodingKeys : String, CodingKey {
		case result = "_0"
		case functions = "functions"
	}
}

extension OB.Parameter {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case type = "_1"
	}
}

extension OB.Initialiser {
	public enum CodingKeys : String, CodingKey {
		case parameters = "takes"
		case effect = "in"
	}
}

extension OB.Function {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case parameters = "takes"
		case resultType = "returns"
		case result = "in"
	}
}

extension OB.RecordType {
	public enum CodingKeys : String, CodingKey {
		case fields = "_0"
	}
}

extension OB.Field {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case valueType = "_1"
	}
}

extension OB.ObjectType {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case state = "state"
		case initialiser = "initialiser"
		case methods = "methods"
	}
}

extension OB.Method {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case parameters = "takes"
		case resultType = "returns"
		case result = "in"
	}
}

extension OB.Definition {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case value = "_1"
	}
}

extension PR.Program {
	public enum CodingKeys : String, CodingKey {
		case blocks = "_0"
	}
}

extension PR.Block {
	public enum CodingKeys : String, CodingKey {
		case name = "name"
		case effects = "do"
		case continuation = "then"
	}
}

extension RT.Program {
	public enum CodingKeys : String, CodingKey {
		case statements = "_0"
	}
}

extension RV.Program {
	public enum CodingKeys : String, CodingKey {
		case statements = "_0"
	}
}

extension SV.Program {
	public enum CodingKeys : String, CodingKey {
		case effect = "_0"
		case procedures = "procedures"
	}
}

extension SV.RecordType {
	public enum CodingKeys : String, CodingKey {
		case fields = "_0"
	}
}

extension SV.Field {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case valueType = "_1"
	}
}

extension SV.Procedure {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case effect = "in"
	}
}

extension Λ.Program {
	public enum CodingKeys : String, CodingKey {
		case result = "_0"
		case functions = "functions"
	}
}

extension Λ.Function {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case parameters = "takes"
		case resultType = "returns"
		case result = "in"
	}
}

extension Λ.Definition {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case value = "_1"
	}
}

