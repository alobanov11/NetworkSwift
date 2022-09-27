//
//  Created by Антон Лобанов on 02.02.2022.
//

import Foundation

public struct ApiRequest: Hashable {
	public let name: String

	public init(name: String) {
		self.name = name
	}

	public static let `default` = ApiRequest(name: "default")
}
