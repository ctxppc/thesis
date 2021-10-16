// Glyco © 2021 Constantino Tsarouhas

extension FL {
	
	/// A location to a register or frame cell on an FL machine.
	public enum Location : Codable {
		
		/// A location to a register.
		case register(Register)
		
		/// A location to a frame cell.
		case frameCell(FrameCellLocation)
		
	}
	
	public typealias Register = Lower.Register
	
}
