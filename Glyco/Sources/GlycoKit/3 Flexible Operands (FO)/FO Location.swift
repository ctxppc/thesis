// Glyco © 2021–2022 Constantino Tsarouhas

extension FO {
	
	/// A location to a register or frame cell on an FO machine.
	public enum Location : Codable, Equatable {
		
		/// A location on the register bank.
		case register(Register)
		
		/// A location on the call frame.
		case frame(Frame.Location)
		
	}
	
	public typealias Frame = Lower.Frame
	
}
