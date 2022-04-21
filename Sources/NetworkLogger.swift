//
//  Created by Антон Лобанов on 21.04.2022.
//

import Foundation

public enum NetworkLogger {
	public static var isEnabled = true

	static func log(_ values: [Any?]) {
		guard self.isEnabled else { return }
		print(String(repeating: "_", count: 85))
		for value in values {
			if let value = value {
				print(value)
			}
		}
		print(String(repeating: "_", count: 85))
	}
}
