// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A location to a register or frame cell on an FL machine.
	enum Location : Codable {
		
		/// A location to a register.
		case register(RV.Register)
		
		/// A location to a frame cell.
		case frameCell(FrameCellLocation)
		
	}
	
}
