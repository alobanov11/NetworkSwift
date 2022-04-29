//
//  Created by Антон Лобанов on 21.04.2022.
//

import Foundation

public enum NetworkLogger {
	public static var isEnabled = true

	public static var handler: ([Any?]) -> Void = { values in
		#if DEBUG
		print(String(repeating: "_", count: 85))
		for value in values {
			if let value = value {
				print(value)
			}
		}
		print(String(repeating: "_", count: 85))
		#endif
	}

	static func log(_ values: [Any?]) {
		guard self.isEnabled else { return }
		self.handler(values)
	}
}
