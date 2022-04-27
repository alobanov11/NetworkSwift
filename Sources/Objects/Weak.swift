//
//  Created by Антон Лобанов on 27.04.2022.
//

import Foundation

final class Weak<Value> {
	var element: Value? {
		self.value as? Value
	}

	private weak var value: AnyObject?

	init(_ value: Value) {
		self.value = value as AnyObject
	}
}
