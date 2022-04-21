//
//  Created by Антон Лобанов on 02.02.2022.
//

import Foundation

public struct RequestAPI: Hashable {
	public let name: String

	public init(name: String) {
		self.name = name
	}

	public static let `default` = RequestAPI(name: "default")
}
