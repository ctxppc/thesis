// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import Foundation

extension CC {
	
	/// An effect on a CC machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case `do`([Effect])
		
		/// An effect that retrieves the value from given source and puts it in given location.
		case set(Location, to: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that retrieves the element at zero-based position `at` in the vector in `of` and puts it in `to`.
		case getElement(of: Location, at: Source, to: Location)
		
		/// An effect that evaluates `to` and puts it in the vector in `of` at zero-based position `at`.
		case setElement(of: Location, at: Source, to: Source)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// An effect that invokes the labelled procedure passing given arguments.
		case call(Label, [Source])
		
		/// An effect that terminates the program with `result`.
		case `return`(Source)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .do(let effects):
				return .do(try effects.lowered(in: &context))
				
				case .set(let location, to: let source):
				return .set(.abstract(location), to: try source.lowered(in: &context))
				
				case .compute(let lhs, let op, let rhs, to: let destination):
				return try .compute(lhs.lowered(in: &context), op, rhs.lowered(in: &context), to: .abstract(destination))
				
				case .getElement(of: let vector, at: let index, to: let destination):
				return .getElement(of: .abstract(vector), at: try index.lowered(in: &context), to: .abstract(destination))
				
				case .setElement(of: let vector, at: let index, to: let element):
				return try .setElement(of: .abstract(vector), at: index.lowered(in: &context), to: element.lowered(in: &context))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .call(let name, let arguments):
				guard let procedure = context.procedures.first(where: { $0.name == name }) else { throw LoweringError.unrecognisedProcedure(name: name) }
				let assignments = procedure.parameterAssignments(in: context.configuration)
				let loweredArguments = try arguments.lowered(in: &context)
				let registerCopies = zip(assignments.registers, loweredArguments).map { (register, argument) in
					.register(register) <- argument
				}
				let frameCellCopies = zip(assignments.frameLocations, loweredArguments.dropFirst(registerCopies.count)).map { (frameLocation, argument) in
					.frame(frameLocation) <- argument
				}
				let parameterLocations = assignments.registers.map { Lower.ParameterLocation.register($0) }
					+ assignments.frameLocations.map { .frame($0) }
				return .do(frameCellCopies + registerCopies + [.call(name, parameterLocations)])
				
				case .return(let result):
				return .return(try result.lowered(in: &context))
				
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
