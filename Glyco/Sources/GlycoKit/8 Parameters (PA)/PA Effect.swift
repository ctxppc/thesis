// Glyco © 2021–2022 Constantino Tsarouhas

import DepthKit
import Foundation

extension PA {
	
	/// An effect on a PA machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case sequence([Effect])
		
		/// An effect that retrieves the value in `from` and puts it in `to`.
		case copy(from: Source, to: Location)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `to`.
		case compute(Source, BinaryOperator, Source, to: Location)
		
		/// An effect that performs `then` if the predicate holds, or `else` otherwise.
		indirect case `if`(Predicate, then: Effect, else: Effect)
		
		/// An effect that invokes the labelled procedure passing given arguments.
		case invoke(Label, [Source])
		
		/// An effect that terminates the program with `result`.
		case `return`(Source)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .sequence(let effects):
				return .sequence(try effects.lowered(in: &context))
				
				case .copy(from: let source, to: let location):
				return .copy(from: try source.lowered(in: &context), to: .abstract(location))
				
				case .compute(let lhs, let op, let rhs, to: let destination):
				return try .compute(lhs.lowered(in: &context), op, rhs.lowered(in: &context), to: .abstract(destination))
				
				case .if(let predicate, then: let affirmative, else: let negative):
				return try .if(predicate.lowered(in: &context), then: affirmative.lowered(in: &context), else: negative.lowered(in: &context))
				
				case .invoke(let name, let arguments):
				guard let procedure = context.procedures.first(where: { $0.name == name }) else { throw LoweringError.unrecognisedProcedure(name: name) }
				let assignments = procedure.parameterAssignments(in: context.configuration)
				let loweredArguments = try arguments.lowered(in: &context)
				let registerCopies = zip(assignments.registers, loweredArguments).map { (register, argument) in
					Lower.Effect.copy(from: argument, to: .parameter(.register(register)))
				}
				let frameCellCopies = zip(assignments.frameLocations, loweredArguments.dropFirst(registerCopies.count)).map { (frameLocation, argument) in
					Lower.Effect.copy(from: argument, to: .parameter(.frame(frameLocation)))
				}
				let parameterLocations = assignments.registers.map { Lower.ParameterLocation.register($0) }
					+ assignments.frameLocations.map { .frame($0) }
				return .sequence(frameCellCopies + registerCopies + [.invoke(name, parameterLocations)])
				
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