// Glyco © 2021 Constantino Tsarouhas

import Collections
import DepthKit
import Foundation

extension PA {
	
	/// An effect on a PA machine.
	public enum Effect : Codable, Equatable, SimplyLowerable {
		
		/// An effect that performs `effects`.
		case sequence(effects: [Effect])
		
		/// An effect that retrieves the value in `source` and puts it in `destination`.
		case copy(destination: Location, source: Source)
		
		/// An effect that computes `lhs` `operation` `rhs` and puts it in `destination`.
		case compute(destination: Location, lhs: Source, operation: BinaryOperator, rhs: Source)
		
		/// An effect that performs `affirmative` if `predicate` holds, or `negative` otherwise.
		indirect case conditional(predicate: Predicate, affirmative: Effect, negative: Effect)
		
		/// An effect that invokes the procedure labelled `procedure` after copying `arguments` to be used as arguments.
		///
		/// This effect overwrites the first *n* argument registers (from `Register.argumentRegisters`) where *n* is equal to `arguments.count`. `arguments` must not refer to such overwritten argument registers, unless it's its destination register.
		case invoke(procedure: Label, arguments: [Source])
		
		/// An effect that terminates the program with `result`.
		case `return`(result: Source)
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Effect {
			switch self {
				
				case .sequence(effects: let effects):
				return .sequence(try effects.lowered(in: &context))
				
				case .copy(destination: let destination, source: let source):
				return .copy(destination: destination, source: source)
				
				case .compute(destination: let destination, lhs: let lhs, operation: let operation, rhs: let rhs):
				return .compute(destination: destination, lhs: lhs, operation: operation, rhs: rhs)
				
				case .conditional(predicate: let predicate, affirmative: let affirmative, negative: let negative):
				return try .conditional(predicate: predicate, affirmative: affirmative.lowered(in: &context), negative: negative.lowered(in: &context))
				
				case .invoke(procedure: let name, arguments: let arguments):
				guard let procedure = context.procedures.first(where: { $0.name == name }) else { throw LoweringError.unrecognisedProcedure(name: name) }
				var availableRegisters = Register.argumentRegisters[...]
				var frame = Frame()
				let assignments = zip(procedure.parameters, arguments).map { (parameter, argument) in
					ArgumentAssignment(parameter: parameter, argument: argument, availableRegisters: &availableRegisters, frame: &frame)
				}
				let overwrittenArgumentRegisters = Set<Register>(assignments.compactMap { assignment in
					guard case .register(let register) = assignment.destination else { return nil }
					return register
				})
				let overwrittenArgumentRegistersUsedAsSource = assignments.lazy.compactMap { assignment -> Register? in
					switch (assignment.destination, assignment.argument) {
						
						case (.register(let destination), .location(.register(let source))) where destination == source:
						return nil
						
						case (_, .location(.register(let register))) where overwrittenArgumentRegisters.contains(register):
						return register
						
						default:
						return nil
						
					}
				}
				if let r = overwrittenArgumentRegistersUsedAsSource.first {
					throw LoweringError.overwrittenArgumentRegisterUsedAsArgument(invocation: self, argumentRegister: r)
				}
				return .sequence(assignments.map { $0.destination <- $0.argument } + [.invoke(procedure: name)])
				
				case .return(result: let result):
				return .return(result: result)
				
			}
		}
		
	}
	
	enum LoweringError : LocalizedError {
		
		/// An error indicating that no procedure is known by the name `name`.
		case unrecognisedProcedure(name: Label)
		
		/// An error indicating that `invocation` uses argument register `argumentRegister` for an argument, which is itself overwritted with another argument.
		case overwrittenArgumentRegisterUsedAsArgument(invocation: Effect, argumentRegister: Register)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				
				case .unrecognisedProcedure(name: let name):
				return "No procedure is known by the name “\(name)”."
				
				case .overwrittenArgumentRegisterUsedAsArgument(invocation: let invocation, argumentRegister: let argumentRegister):
				return "\(invocation) uses argument register \(argumentRegister) for an argument, which is itself overwritten with another argument."
				
			}
		}
		
	}
	
	/// A value specifying the destination location of an argument
	private struct ArgumentAssignment {
		
		/// Assigns a destination location for `argument`.
		///
		/// - Parameters:
		///   - parameter: The parameter associated with `argument`.
		///   - argument: The argument for which to assign a destination location.
		///   - availableRegisters: Argument registers that are available for assignment.
		///   - frame: The frame in which spilled arguments can be stored.
		init<Registers : Collection>(parameter: Procedure.Parameter, argument: Source, availableRegisters: inout Registers, frame: inout Frame)
		where Registers.Element == Register, Registers.SubSequence == Registers {
			self.argument = argument
			if let (assignableRegister, remainingRegisters) = availableRegisters.splittingFirst() {
				availableRegisters = remainingRegisters
				destination = .register(assignableRegister)
			} else {
				destination = .frameCell(frame.allocate(parameter.dataType))
			}
		}
		
		/// The argument.
		let argument: Source
		
		/// The argument's destination.
		let destination: Location
		
	}
	
}
