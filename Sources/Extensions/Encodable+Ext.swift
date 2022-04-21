//
//  Created by Антон Лобанов on 14.10.2021.
//

import Foundation

public extension Encodable {
	var asDictionary: [String: Any] {
		guard let data = try? JSONEncoder().encode(self) else { return [:] }

		guard let dictionary = try? JSONSerialization.jsonObject(
			with: data,
			options: .allowFragments
		) as? [String: Any]
		else {
			return [:]
		}

		return dictionary
	}
}
