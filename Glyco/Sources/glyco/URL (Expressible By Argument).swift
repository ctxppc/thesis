// Glyco © 2021–2022 Constantino Tsarouhas

import ArgumentParser
import Foundation

extension URL : ExpressibleByArgument {
	public init(argument: String) {
		self.init(fileURLWithPath: argument)
	}
}
