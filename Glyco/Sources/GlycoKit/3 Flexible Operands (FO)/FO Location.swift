// Glyco © 2021–2022 Constantino Tsarouhas

extension FO {
	
	/// A location to a register or frame cell on an FO machine.
	public enum Location : Codable, Equatable {
		
		/// A location to a register.
		case register(Register)
		
		/// A location to a frame cell.
		case frameCell(Frame.Location)
		
	}
	
	public typealias Frame = Lower.Frame
	
}
