// Glyco © 2021–2022 Constantino Tsarouhas

extension FO {
	
	/// A register or memory location.
	public enum Location : Codable, Equatable {
		
		/// A location on the register bank.
		case register(Register)
		
		/// A location on the call frame.
		case frame(Frame.Location)
		
	}
	
	public typealias Frame = Lower.Frame
	
}
