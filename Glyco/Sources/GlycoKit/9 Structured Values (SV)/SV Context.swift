// Glyco © 2021–2022 Constantino Tsarouhas

extension SV {
	
	/// A value used while lowering a procedure.
	struct Context {
		
		/// A mapping from vector locations to element types.
		var elementTypesByVectorLocation = [Location : ValueType]()
		
		/// A mapping from record locations to record types.
		var recordTypesByRecordLocation = [Location : RecordType]()
		
	}
	
}
