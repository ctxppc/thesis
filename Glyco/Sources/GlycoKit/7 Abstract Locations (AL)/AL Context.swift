// Glyco © 2021–2022 Constantino Tsarouhas

extension AL {
	
	/// A value used while lowering a procedure.
	public struct Context {
		
		/// The analysis.
		///
		/// When a program element's lowering begins, this value is the analysis at exit. When a program element's lowering finishes, this value is the analysis at entry.
		var analysis: Lower.Analysis
		
	}
	
}
