// Glyco © 2021–2022 Constantino Tsarouhas

import Foundation

extension CC {
	
	/// An effect on a CC machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(DataType, Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that pushes a vector of `count` elements of given data type to the call frame and puts a capability for that vector in `into`.
		case allocateVector(DataType, count: Int = 1, into: Location)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(DataType, of: Location, at: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(DataType, of: Location, at: Source, to: Source)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// An effect that invokes the labelled procedure passing given arguments.
		case call(Label, [Source])
		
		/// An effect that returns given result to the caller.
		case `return`(DataType, Source)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				return .do(try effects.lowered(in: &context))
				
				case .set(let type, let location, to: let source):
				return .set(type, .abstract(location), to: try source.lowered(in: &context))
				
				case .compute(let lhs, let op, let rhs, to: let destination):
				return try .compute(lhs.lowered(in: &context), op, rhs.lowered(in: &context), to: .abstract(destination))
				
				case .allocateVector(let type, count: let count, into: let vector):
				return .allocateVector(type, count: count, into: .abstract(vector))
				
				case .getElement(let type, of: let vector, at: let index, to: let destination):
				return .getElement(type, of: .abstract(vector), at: try index.lowered(in: &context), to: .abstract(destination))
				
				case .setElement(let type, of: let vector, at: let index, to: let element):
				return try .setElement(type, of: .abstract(vector), at: index.lowered(in: &context), to: element.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .call(let name, let arguments):
				do {
					
					guard let procedure = context.procedures.first(where: { $0.name == name }) else { throw LoweringError.unrecognisedProcedure(name: name) }
					let assignments = procedure.parameterAssignments(in: context.configuration)
					
					let loweredArguments = try arguments.lowered(in: &context)
					let passArgsByRegister = zip(assignments.registers, loweredArguments).map { (asn, argument) in
						Lower.Effect.set(asn.0.type, .parameter(.register(asn.1)), to: argument)
					}
					let passArgsByFrame = zip(assignments.frameLocations, loweredArguments.dropFirst(passArgsByRegister.count)).map { (asn, argument) in
						Lower.Effect.set(asn.0.type, .parameter(.frame(asn.1)), to: argument)
					}
					
					let parameterLocations = assignments.registers.map { Lower.ParameterLocation.register($0.1) }
						+ assignments.frameLocations.map { .frame($0.1) }
					
					return .do(passArgsByFrame + passArgsByRegister + [.call(name, parameterLocations)])
					
				}
				
				case .return(let type, let result):
				return .do([
					// TODO: Apply calling conventions
					.set(type, .parameter(.register(.a0)), to: try result.lowered(in: &context)),
					.return,
				])
				
			}
		}
		
		enum LoweringError : LocalizedError {
			
			/// An error indicating that no procedure is known by the name `name`.
			case unrecognisedProcedure(name: Label)
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					case .unrecognisedProcedure(name: let name):
					return "No procedure is known by the name “\(name)”."
				}
			}
			
		}
		
	}
	
}
