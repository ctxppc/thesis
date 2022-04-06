// Glyco © 2021–2022 Constantino Tsarouhas

import Algorithms
import DepthKit
import Foundation

extension CC {
	
	/// A program element that can be invoked by name.
	public struct Procedure : Codable, Equatable, Named, SimplyLowerable, Validatable {
		
		/// Creates a procedure with given name, parameters, result type, and effect.
		public init(_ name: Label, takes parameters: [Parameter], returns resultType: ValueType, in effect: Effect) {
			self.name = name
			self.parameters = parameters
			self.resultType = resultType
			self.effect = effect
		}
		
		/// The name with which the procedure can be invoked.
		public var name: Label
		
		/// The procedure's parameters.
		public var parameters: [Parameter]
		
		/// The procedure's result type.
		public var resultType: ValueType
		
		/// The procedure's effect when invoked.
		public var effect: Effect
		
		// See protocol.
		public func validate(configuration: CompilationConfiguration) throws {
			let sealedParameters = parameters.filter(\.sealed)
			guard sealedParameters.count <= 1 else { throw ValidationError.multipleSealedParameters(sealedParameters) }
		}
		
		// See protocol.
		func lowered(in context: inout Context) throws -> Lower.Procedure {
			
			let previousProcedure = context.loweredProcedure
			context.loweredProcedure = self
			defer { context.loweredProcedure = previousProcedure }
			
			return .init(name, in: try .do {
				
				// Prepare new scope.
				Lower.Effect.pushScope
				
				// Bind assignable callee-saved registers to abstract locations to limit their liveness.
				for register in context.configuration.calleeSavedRegisters {
					Lower.Effect.set(.abstract(context.saveLocation(for: register)), to: .register(register, .registerDatum))
				}
				
				// Bind return capability.
				Lower.Effect.set(.abstract(context.returnLocation), to: .register(.ra, .cap(.code)))
				
				// Determine parameter assignments.
				let assignments = Parameter.Assignments(parameters: parameters, resultType: resultType, configuration: context.configuration)
				
				// Bind local names to register-resident arguments — limit liveness ranges by using the registers as early as possible.
				// Sealed parameters are passed as part of the sealed invocation effect instead.
				for asn in assignments.viaRegisters where !asn.parameter.sealed {
					let parameter = asn.parameter
					Lower.Effect.set(.abstract(parameter.location), to: .register(asn.register, parameter.type.lowered()))
				}
				
				// Bind local names to arguments in arguments record.
				// If arguments record capability is available, load from record; otherwise load from call frame.
				var parameterRecordType = assignments.parameterRecordType
				if let argumentsRecordRegister = assignments.argumentsRecordRegister {
					for field in parameterRecordType {
						Lower.Effect.getField(
							field.name,
							of: .register(argumentsRecordRegister),
							to: .abstract(.init(rawValue: field.name.rawValue))
						)
					}
				} else {
					parameterRecordType.prependOrReplace(.init("cc.__savedfp__", .cap(.vector(of: .u8, sealed: false))))
					for (field, offset) in parameterRecordType.fieldByteOffsetPairs().dropFirst() {
						Lower.Effect.set(.abstract(.init(rawValue: field.name.rawValue)), to: .frame(.init(offset: offset)))
					}
				}
				
				// Execute main effect.
				try effect.lowered(in: &context)
				
			})
			
		}
		
		enum ValidationError : LocalizedError {
			
			/// An error indicating that multiple parameters are sealed.
			case multipleSealedParameters([Parameter])
			
			// See protocol.
			var errorDescription: String? {
				switch self {
					case .multipleSealedParameters(let parameters):
					return "Multiple parameters (\(parameters)) are marked as sealed; no more than one parameter can be marked as sealed"
				}
			}
			
		}
		
	}
	
}
