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

extension EX.Program {
	public enum CodingKeys : String, CodingKey {
		case body = "_0"
		case procedures = "procedures"
	}
}

extension EX.Procedure {
	public enum CodingKeys : String, CodingKey {
		case name = "_0"
		case parameters = "_1"
		case body = "_2"
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

