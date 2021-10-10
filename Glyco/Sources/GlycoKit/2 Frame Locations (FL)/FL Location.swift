// Glyco © 2021 Constantino Tsarouhas

/// A location to a register or frame cell on an FL machine.
enum FLLocation : Codable {
	
	/// A location to a register.
	case register(RVRegister)
	
	/// A location to a frame cell.
	case frameCell(FLFrameCellLocation)
	
}
