// Generated using Sourcery 1.6.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension AL.Program {
	public enum CodingKeys : String, CodingKey {
		case effect = "_0"
		case procedures = "procedures"
	}
}

extension AL.Procedure {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case effect = "_1"
	}
}

extension ALA.Program {
	public enum CodingKeys : String, CodingKey {
		case effect = "_0"
		case procedures = "procedures"
	}
}

extension ALA.Procedure {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case effect = "in"
	}
}

extension ALA.Analysis {
	public enum CodingKeys : String, CodingKey {
		case conflicts = "conflicts"
		case possiblyLiveLocations = "possiblyLiveLocations"
	}
}

extension ALA.Conflict {
	public enum CodingKeys : String, CodingKey {
		case first = "_0"
		case second = "_1"
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

extension CC.Parameter {
	public enum CodingKeys : String, CodingKey {
		case location = "_0"
		case type = "_1"
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

extension CF.Program {
	public enum CodingKeys : String, CodingKey {
		case effects = "_0"
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

extension FO.HaltEffect {
	public enum CodingKeys : String, CodingKey {
		case result = "result"
		case type = "type"
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

extension RV.Program {
	public enum CodingKeys : String, CodingKey {
		case instructions = "_0"
	}
}

extension S.Program {
	public enum CodingKeys : String, CodingKey {
		case assembly = "assembly"
	}
}

