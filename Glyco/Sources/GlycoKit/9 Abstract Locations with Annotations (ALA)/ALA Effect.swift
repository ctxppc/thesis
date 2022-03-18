// Glyco © 2021–2022 Constantino Tsarouhas

extension ALA {
	
	/// An effect on an ALA machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect], analysisAtEntry: Analysis)
		
		/// An effect that retrieves the datum from given source and puts it in given location, effectively copying the datum.
		case set(Location, to: Source, analysisAtEntry: Analysis)
		
		/// An effect that computes given expression and puts the result in given location.
		case compute(Location, Source, BinaryOperator, Source, analysisAtEntry: Analysis)
		
		/// An effect that creates an (uninitialised) buffer of `bytes` bytes and puts a capability for that buffer in given location.
		///
		/// If `scoped` is `true`, the buffer may be destroyed when the current scope is popped and must not be accessed afterwards.
		case createBuffer(bytes: Int, capability: Location, scoped: Bool, analysisAtEntry: Analysis)
		
		/// An effect that destroys the buffer referred by the capability from given source.
		///
		/// This effect must only be used with *scoped* buffers created in the *current* scope. For any two buffers *a* and *b* created in the current scope, *b* must be destroyed exactly once before destroying *a*. Destruction is not required before popping the scope; in that case, destruction is automatic.
		case destroyBuffer(capability: Source, analysisAtEntry: Analysis)
		
		/// An effect that retrieves the datum at offset `offset` in the buffer in `of` and puts it in `to`.
		case getElement(DataType, of: Location, offset: Source, to: Location, analysisAtEntry: Analysis)
		
		/// An effect that evaluates `to` and puts it in the buffer in `of` at offset `offset`.
		case setElement(DataType, of: Location, offset: Source, to: Source, analysisAtEntry: Analysis)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect, analysisAtEntry: Analysis)
		
		/// Pushes a new scope to the scope stack, protecting any callee-saved physical locations (registers and frame locations) from the previous scope that may be defined in the new scope.
		///
		/// This effect must be executed exactly once before any location defined in the current scope is accessed.
		///
		/// A push scope effect "defines" all callee-saved registers with the value from the previous scope. If nothing else is done, callee-saved registers will conflict with every location that is live at any point until the pop scope effect and will not be used for assignment.
		///
		/// To make callee-saved registers available for assignment, they should be copied into abstract locations after pushing the scope, and copied back into the register prior to popping the scope. The latter copy will cause the registers to be marked as definitely discarded between the two copies, thereby making them available for assignment. Any register not used for assignment will be coalesced with its abstract location, thereby eliding the copy effects to and from the abstract location.
		case pushScope(analysisAtEntry: Analysis)
		
		/// Pops a scope from the scope stack, restoring any physical locations (registers and frame locations) previously saved using `pushScope`.
		///
		/// This effect must be executed exactly once before any location defined in the previous scope is accessed.
		///
		/// A pop scope effect "uses" the values of callee-saved registers, as defined during the preceding push scope effect so that it can "return" them to the previous scope. If those values were copied into abstract locations after their definition by the push scope effect, they should be copied back to the callee-saved registers before the pop scope effect so that the registers become available for other assignments.
		case popScope(analysisAtEntry: Analysis)
		
		/// An effect that clears all registers except the structural registers `csp`, `cgp`, `ctp`, and `cfp` as well as given registers.
		case clearAll(except: [Register], analysisAtEntry: Analysis)
		
		/// An effect that calls the procedure with given name and uses given parameter registers.
		///
		/// This effect assumes a suitable calling convention has already been applied to the program. The parameter registers are only used for the purposes of liveness analysis.
		///
		/// A call effect "defines" caller-saved registers.
		case call(Label, parameters: [Register], analysisAtEntry: Analysis)
		
		/// An effect that returns control to the caller with given target code capability (which is usually `cra`).
		///
		/// This effect assumes a suitable calling convention has already been applied to the program.
		case `return`(to: Source, analysisAtEntry: Analysis)
		
		// See protocol.
		@EffectBuilder<Lowered>
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects, analysisAtEntry: _):
				Lowered.do(try effects.lowered(in: &context))
				
				case .set(let destination, to: let source, analysisAtEntry: _):
				try Lowered.set(
					context.declarations.type(of: destination, and: source),
					destination.lowered(in: &context),
					to: source.lowered(in: &context)
				)
				
				case .compute(let destination, let lhs, let op, let rhs, analysisAtEntry: _):
				try Lowered.compute(destination.lowered(in: &context), lhs.lowered(in: &context), op, rhs.lowered(in: &context))
				
				case .createBuffer(bytes: let bytes, capability: let buffer, scoped: let scoped, analysisAtEntry: _):
				Lowered.createBuffer(bytes: bytes, capability: try buffer.lowered(in: &context), onFrame: scoped)
				
				case .destroyBuffer(capability: let buffer, analysisAtEntry: _):
				Lowered.destroyBuffer(capability: try buffer.lowered(in: &context))
				
				case .getElement(let elementType, of: let buffer, offset: let offset, to: let destination, analysisAtEntry: _):
				try Lowered.getElement(
					elementType,
					of:		buffer.lowered(in: &context),
					offset:	offset.lowered(in: &context),
					to:		destination.lowered(in: &context)
				)
				
				case .setElement(let elementType, of: let buffer, offset: let offset, to: let source, analysisAtEntry: _):
				try Lowered.setElement(
					elementType,
					of:		buffer.lowered(in: &context),
					offset:	offset.lowered(in: &context),
					to:		source.lowered(in: &context)
				)
				
				case .if(let predicate, then: let affirmative, else: let negative, analysisAtEntry: _):
				try Lowered.if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .pushScope(analysisAtEntry: _):
				Lowered.pushFrame(context.assignments.frame)
				
				case .popScope(analysisAtEntry: _):
				Lowered.popFrame
				
				case .clearAll(except: let sparedRegisters, analysisAtEntry: _):
				Lowered.clearAll(except: sparedRegisters)
				
				case .call(let name, parameters: _, analysisAtEntry: _):
				Lowered.call(name)
				
				case .return(to: let caller, analysisAtEntry: _):
				Lowered.return(to: try caller.lowered(in: &context))
				
			}
		}
		
		/// Returns a transformed copy of `self` with updated analysis at entry.
		///
		/// The transformation is applied first. If the transformed effect contains effects or predicates, it is applied to those as well.
		///
		/// - Parameters:
		///    - transform: A transformation.
		///    - analysis: On method entry, analysis at exit of `self`. On method exit, the analysis at entry of `self`.
		///    - configuration: The compilation configuration.
		///
		/// - Returns: `transform(self)` with updated analysis at entry.
		func updated(using transform: ALALocalTransformation, analysis: inout Analysis, configuration: CompilationConfiguration) throws -> Self {
			let transformed = try transform(self)
			try analysis.update(
				defined:		transformed.definedLocations(configuration: configuration),
				possiblyUsed:	transformed.possiblyUsedLocations(configuration: configuration)
			)
			switch transformed {
				
				case .do(let effects, analysisAtEntry: _):
				// Update effects in reverse order so that analysis flows backwards, then reverse sequence back to normal order
				return .do(
					try effects
						.reversed()
						.map { try $0.updated(using: transform, analysis: &analysis, configuration: configuration) }
						.reversed(),
					analysisAtEntry: analysis
				)
				
				case .set(let destination, to: let source, analysisAtEntry: _):
				return .set(destination, to: source, analysisAtEntry: analysis)
				
				case .compute(let destination, let lhs, let operation, let rhs, analysisAtEntry: _):
				return .compute(destination, lhs, operation, rhs, analysisAtEntry: analysis)
				
				case .createBuffer(bytes: let bytes, capability: let buffer, scoped: let scoped, analysisAtEntry: _):
				return .createBuffer(bytes: bytes, capability: buffer, scoped: scoped, analysisAtEntry: analysis)
				
				case .destroyBuffer(let buffer, analysisAtEntry: _):
				return .destroyBuffer(capability: buffer, analysisAtEntry: analysis)
				
				case .getElement(let elementType, of: let buffer, offset: let offset, to: let destination, analysisAtEntry: _):
				return .getElement(elementType, of: buffer, offset: offset, to: destination, analysisAtEntry: analysis)
				
				case .setElement(let elementType, of: let buffer, offset: let offset, to: let element, analysisAtEntry: _):
				return .setElement(elementType, of: buffer, offset: offset, to: element, analysisAtEntry: analysis)
				
				case .if(let predicate, then: let affirmative, else: let negative, analysisAtEntry: _):
				do {
					
					/*			      analysisAtEntry
					┌────────────────────────┼────────────────────────┐
					│    ┌───────────────────▼───────────────────┐    │
					│    │                                       │    │
					│    │               Predicate               │    │
					│    │                                       │    │
					│    └───────┬───────────────────────┬───────┘    │
					│ analysisAtAffirmativeEntry         │            │
					│    ┌───────▼────────┐     ┌────────▼───────┐    │
					│    │  Affirmative   │     │    Negative    │    │
					│    │     branch     │     │     branch     │    │
					│    └───────┬────────┘     └────────┬───────┘    │
					│            │                       │            │
					└────────────┼───────────────────────┼────────────┘
								 │                       │
								 └───────────┬───────────┘
											 │
											 ▼
					 */
					
					var analysisAtAffirmativeEntry = analysis
					let updatedAffirmative = try affirmative.updated(
						using:			transform,
						analysis:		&analysisAtAffirmativeEntry,
						configuration:	configuration
					)
					
					let updatedNegative = try negative.updated(using: transform, analysis: &analysis, configuration: configuration)
					analysis.formUnion(with: analysisAtAffirmativeEntry)
					
					let updatedPredicate = try predicate.updated(using: transform, analysis: &analysis, configuration: configuration)
					
					return .if(updatedPredicate, then: updatedAffirmative, else: updatedNegative, analysisAtEntry: analysis)
					
				}
				
				case .pushScope(analysisAtEntry: _):
				return .pushScope(analysisAtEntry: analysis)
				
				case .popScope(analysisAtEntry: _):
				return .popScope(analysisAtEntry: analysis)
				
				case .clearAll(except: let sparedRegisters, analysisAtEntry: _):
				return .clearAll(except: sparedRegisters, analysisAtEntry: analysis)
				
				case .call(let name, parameters: let parameters, analysisAtEntry: _):
				return .call(name, parameters: parameters, analysisAtEntry: analysis)
				
				case .return(to: let caller, analysisAtEntry: _):
				return .return(to: caller, analysisAtEntry: analysis)
				
			}
		}
		
		/// A function that transforms an effect into the same effect or different effect.
		typealias Transformation = (Self) throws -> Self
		
		/// The analysis of `self` at entry.
		var analysisAtEntry: Analysis {
			switch self {
				case .do(_, analysisAtEntry: let analysis),
					.set(_, to: _, analysisAtEntry: let analysis),
					.compute(_, _, _, _, analysisAtEntry: let analysis),
					.createBuffer(bytes: _, capability: _, scoped: _, analysisAtEntry: let analysis),
					.destroyBuffer(capability: _, analysisAtEntry: let analysis),
					.getElement(_, of: _, offset: _, to: _, analysisAtEntry: let analysis),
					.setElement(_, of: _, offset: _, to: _, analysisAtEntry: let analysis),
					.if(_, then: _, else: _, analysisAtEntry: let analysis),
					.pushScope(analysisAtEntry: let analysis),
					.popScope(analysisAtEntry: let analysis),
					.clearAll(except: _, analysisAtEntry: let analysis),
					.call(_, parameters: _, analysisAtEntry: let analysis),
					.return(to: _, analysisAtEntry: let analysis):
				return analysis
			}
		}
		
		/// Returns the locations defined by `self`.
		///
		/// - Parameter configuration: The compilation configuration.
		///
		/// - Returns: The locations defined by `self`.
		private func definedLocations(configuration: CompilationConfiguration) -> [Location] {
			switch self {
				
				case .do, .destroyBuffer, .setElement, .if, .popScope, .return:
				return []
				
				case .set(let destination, to: _, analysisAtEntry: _),
					.getElement(_, of: _, offset: _, to: let destination, analysisAtEntry: _),
					.compute(let destination, _, _, _, analysisAtEntry: _),
					.createBuffer(bytes: _, capability: let destination, scoped: _, analysisAtEntry: _):
				return [destination]
				
				case .pushScope:
				return configuration.calleeSavedRegisters.map { .register($0) }
				
				case .clearAll(except: let sparedRegisters, analysisAtEntry: _):
				let sparedRegisters = Set(sparedRegisters)
				return Register.assignableRegisters
					.filter { !sparedRegisters.contains($0) }
					.map { .register($0) }
				
				case .call:
				return configuration.callerSavedRegisters.map { .register($0) }	// includes args and cra
				
			}
		}
		
		/// Returns the locations possibly used by `self`.
		///
		/// - Parameter configuration: The compilation configuration.
		///
		/// - Returns: The locations possibly used by `self`.
		private func possiblyUsedLocations(configuration: CompilationConfiguration) -> [Location] {
			switch self {
				
				case .do,
					.set(_, to: .constant, analysisAtEntry: _),
					.compute(_, .constant, _, .constant, analysisAtEntry: _),
					.createBuffer,
					.if,
					.pushScope,
					.clearAll:
				return []
				
				case .destroyBuffer(capability: let source, analysisAtEntry: _),
					.set(_, to: let source, analysisAtEntry: _):
				return [source].compactMap(\.location)
				
				case .compute(_, let lhs, _, let rhs, analysisAtEntry: _):
				return [lhs, rhs].compactMap(\.location)
				
				case .getElement(_, of: let buffer, offset: let index, to: _, analysisAtEntry: _):
				return [index].compactMap(\.location) + [buffer]
				
				case .setElement(_, of: let buffer, offset: let index, to: let element, analysisAtEntry: _):
				return [index, element].compactMap(\.location) + [buffer]
				
				case .popScope:
				return configuration.calleeSavedRegisters.map { .register($0) }
				
				case .call(_, parameters: let parameters, analysisAtEntry: _):
				return parameters.map { .register($0) }
				
				case .return(to: let caller, analysisAtEntry: _):
				return [caller].compactMap(\.location) + [.register(.a0)]
				
			}
		}
		
		/// Returns a pair of locations that can be safely coalesced, or `nil` if no such pair is known.
		///
		/// - Parameter analysis: The analysis at scope (program, procedure) entry.
		///
		/// - Returns: A pair of locations that can be safely coalesced, or `nil` if no such pair is known.
		func safelyCoalescableLocations(analysisAtScopeEntry analysis: Analysis) -> (AbstractLocation, Location)? {
			switch self {
				
				case .do(let effects, analysisAtEntry: _):
				return effects
						.reversed()
						.lazy
						.compactMap { $0.safelyCoalescableLocations(analysisAtScopeEntry: analysis) }
						.first
				
				case .set(.abstract(let destination), to: let source, analysisAtEntry: _):
				guard let source = source.location, analysis.safelyCoalescable(source, .abstract(destination)) else { return nil }
				return (destination, source)
					
				case .set(let destination, to: .abstract(let source), analysisAtEntry: _):
				guard analysis.safelyCoalescable(.abstract(source), destination) else { return nil }
				return (source, destination)
				
				case .set, .compute,
					.createBuffer, .destroyBuffer,
					.getElement, .setElement,
					.pushScope, .popScope,
					.clearAll,
					.call, .return:
				return nil
				
				case .if(let predicate, then: let affirmative, else: let negative, analysisAtEntry: _):
				return negative.safelyCoalescableLocations(analysisAtScopeEntry: analysis)
					?? affirmative.safelyCoalescableLocations(analysisAtScopeEntry: analysis)
					?? predicate.safelyCoalescableLocations(analysisAtScopeEntry: analysis)
				
			}
		}
		
		/// Returns a copy of `self` where `removedLocation` is coalesced into `retainedLocation` and the effect's analysis at entry is updated accordingly.
		///
		/// - Parameters:
		///   - removedLocation: The location that is replaced by `retainedLocation`.
		///   - retainedLocation: The location that remains.
		///   - declarations: The local declarations.
		///   - analysis: On method entry, analysis at exit of `self`. On method exit, the analysis at entry of `self`.
		///   - configuration: The compilation configuration.
		///
		/// - Requires: `declarations` contains a declaration for `removedLocation`. The declaration should be removed after global coalescing is done. 
		///
		/// - Returns: A copy of `self` where `removedLocation` is coalesced into `retainedLocation` and the effect's analysis at entry is updated accordingly.
		func coalescing(
			_ removedLocation:		AbstractLocation,
			into retainedLocation:	Location,
			declarations:			Declarations,
			analysis:				inout Analysis,
			configuration:			CompilationConfiguration
		) throws -> Self {
			try updated(
				using:			CoalesceLocations(removedLocation: removedLocation, retainedLocation: retainedLocation, declarations: declarations),
				analysis:		&analysis,
				configuration:	configuration
			)
		}
		
	}
	
}
