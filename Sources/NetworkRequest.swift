//
//  Created by Антон Лобанов on 24.01.2023.
//

import Foundation

public protocol AnyNetworkRequest {
	var api: API { get }
	var path: String { get }
	var method: HTTPMethod { get }
	var contentType: ContentType { get }
	var query: [String: Any]? { get }
	var body: [String: Any]? { get }
	var headers: [String: String]? { get }
}

public extension AnyNetworkRequest {
	var boundary: String {
		Data(self.path.utf8).base64EncodedString().replacingOccurrences(of: "=", with: "-")
	}
}

public protocol INetworkRequest: AnyNetworkRequest {
	associatedtype Model

	func decode(_ data: Data) throws -> Model
}

public extension INetworkRequest {
	var api: API { .default }
	var method: HTTPMethod { .get }
	var contentType: ContentType { .json }
	var query: [String: Any]? { nil }
	var body: [String: Any]? { nil }
	var headers: [String: String]? { nil }
}

public extension INetworkRequest where Model == Void {
	func decode(_: Data?) throws { () }
}
