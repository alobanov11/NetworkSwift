//
//  Created by Антон Лобанов on 24.01.2023.
//

import Foundation

extension Optional {
	func orThrow<E: Error>(_ error: @autoclosure () -> E) throws -> Wrapped {
		guard let self = self else {
			throw error()
		}

		return self
	}
}
