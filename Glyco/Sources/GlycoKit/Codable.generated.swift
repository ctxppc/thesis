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

extension BB.Program {
	public enum CodingKeys : String, CodingKey {
		case blocks = "_0"
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
		case parameters = "_1"
		case effect = "_2"
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
		case parameters = "_1"
		case effect = "_2"
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
		case effect = "_1"
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
		case parameters = "_1"
		case effect = "_2"
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
		case parameters = "_1"
		case result = "_2"
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
		case parameters = "_1"
		case result = "_2"
	}
}

extension FL.Program {
	public enum CodingKeys : String, CodingKey {
		case instructions = "_0"
	}
}

extension FO.Program {
	public enum CodingKeys : String, CodingKey {
		case effects = "effects"
	}
}

extension FO.HaltEffect {
	public enum CodingKeys : String, CodingKey {
		case result = "result"
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
		case parameters = "_1"
		case result = "_2"
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

extension RV.Program {
	public enum CodingKeys : String, CodingKey {
		case instructions = "instructions"
	}
}

extension S.Program {
	public enum CodingKeys : String, CodingKey {
		case assembly = "assembly"
	}
}

