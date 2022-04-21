//
//  Created by Антон Лобанов on 02.02.2022.
//

import Foundation

public protocol INetworkDataProvider {
	func baseURL(for api: RequestAPI) -> String?
	func baseHeaders(for api: RequestAPI) -> [String: String]
}
