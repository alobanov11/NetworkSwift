//
//  Created by Антон Лобанов on 14.10.2021.
//

import Foundation

public typealias JSONValue = Any
public typealias JSONObject = [String: JSONValue]

public extension Encodable {
	func encode2JSONObject(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .deferredToDate) throws -> JSONObject {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = dateEncodingStrategy

		let data = try encoder.encode(self)
		let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

		guard let dictionary = json as? [String: Any] else { throw NSError() }

		return dictionary
	}
}
