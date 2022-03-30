// Glyco © 2021–2022 Constantino Tsarouhas

/// A value that maps effects to effects and predicates to predicates.
///
/// The `updated(using:analysis:configuration:)` method in `ALA.Effect` and `ALA.Predicate` applies a local transformation first on the parent before recursively applying it on descendants. The transformation itself is local and does itself not recursively transform the subtree.
protocol ALALocalTransformation {
	
	/// Returns a locally transformed copy of `effect`.
	///
	/// - Parameter effect: The effect to transform.
	func callAsFunction(_ effect: ALA.Effect) throws -> ALA.Effect
	
	/// Returns a locally transformed copy of `predicate`.
	///
	/// - Parameter predicate: The predicate to transform.
	func callAsFunction(_ predicate: ALA.Predicate) throws -> ALA.Predicate
	
}

extension ALA {
	
	/// A transformation that doesn't change effects or predicates.
	struct Identity : ALALocalTransformation {
		func callAsFunction(_ effect: Effect) throws -> Effect { effect }
		func callAsFunction(_ predicate: Predicate) throws -> Predicate { predicate }
	}
	
	/// A transformation that replaces all occurrences of a given abstract location by a another given location.
	struct CoalesceLocations : ALALocalTransformation {
		
		/// The location that is replaced by `retainedLocation`.
		let removedLocation: AbstractLocation
		
		/// The location that is retained.
		///
		/// - Invariant: `retainedLocation` is not equal to `.abstract(removedLocation)`.
		let retainedLocation: Location
		
		/// The local declarations.
		///
		/// - Invariant: `declarations` contains a declaration for `removedLocation`. (The declaration should be removed after global coalescing is done.)
		let declarations: Declarations
		
		// See protocol.
		func callAsFunction(_ effect: ALA.Effect) throws -> ALA.Effect {
			switch effect {
				
				case .do, .if, .pushScope, .popScope, .clearAll, .call, .return:
				return effect
				
				case .set(.abstract(removedLocation), to: let source, analysisAtEntry: let analysis)
					where source.location == retainedLocation || source.location == .abstract(removedLocation):
				return .do([], analysisAtEntry: analysis)
				
				case .set(.abstract(removedLocation), to: let source, analysisAtEntry: let analysis):
				return .set(retainedLocation, to: source, analysisAtEntry: analysis)
				
				case .set(retainedLocation, to: .abstract(removedLocation), analysisAtEntry: let analysis):
				return .do([], analysisAtEntry: analysis)
				
				case .set(retainedLocation, to: let source, analysisAtEntry: let analysis) where source.location == retainedLocation:
				return .do([], analysisAtEntry: analysis)
				
				case .set(let destination, to: let source, analysisAtEntry: let analysis):
				return try .set(substitute(destination), to: substitute(source), analysisAtEntry: analysis)	// keep substititions to also deal with future kinds of sources/locations
				
				case .compute(let destination, let lhs, let op, let rhs, analysisAtEntry: let analysis):
				return try .compute(substitute(destination), substitute(lhs), op, substitute(rhs), analysisAtEntry: analysis)
				
				case .createBuffer(bytes: let bytes, capability: let buffer, scoped: let scoped, analysisAtEntry: let analysis):
				return .createBuffer(bytes: bytes, capability: substitute(buffer), scoped: scoped, analysisAtEntry: analysis)
				
				case .destroyBuffer(let buffer, analysisAtEntry: let analysis):
				return .destroyBuffer(capability: try substitute(buffer), analysisAtEntry: analysis)
				
				case .getElement(let dataType, of: let buffer, offset: let offset, to: let destination, analysisAtEntry: let analysis):
				return try .getElement(dataType, of: substitute(buffer), offset: substitute(offset), to: substitute(destination), analysisAtEntry: analysis)
				
				case .setElement(let dataType, of: let buffer, offset: let offset, to: let source, analysisAtEntry: let analysis):
				return try .setElement(dataType, of: substitute(buffer), offset: substitute(offset), to: substitute(source), analysisAtEntry: analysis)
				
				case .createSeal(in: let destination, analysisAtEntry: let analysis):
				return .createSeal(in: substitute(destination), analysisAtEntry: analysis)
				
			}
		}
		
		// See protocol.
		func callAsFunction(_ predicate: ALA.Predicate) throws -> ALA.Predicate {
			switch predicate {
				
				case .constant, .if, .do:
				return predicate
				
				case .relation(let lhs, let relation, let rhs, analysisAtEntry: let analysis):
				return try .relation(substitute(lhs), relation, substitute(rhs), analysisAtEntry: analysis)
				
			}
		}
		
		private func substitute(_ location: Location) -> Location {
			location == .abstract(removedLocation) ? retainedLocation : location
		}
		
		private func substitute(_ source: Source) throws -> Source {
			guard source == .abstract(removedLocation) else { return source }
			switch retainedLocation {
				
				case .abstract(let location):
				return .abstract(location)
				
				case .register(let register):
				return try .register(register, declarations.type(of: Location.abstract(removedLocation)))
				
				case .frame(let location):
				return .frame(location)
				
			}
		}
		
	}
	
}
