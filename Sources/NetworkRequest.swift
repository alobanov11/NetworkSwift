//
//  Created by Антон Лобанов on 24.01.2023.
//

import Foundation

public typealias HTTPParameters = [String: Any]
public typealias HTTPHeaders = [String: String]

public protocol INetworkRequest {
	associatedtype Model

	var api: API { get }
	var path: String { get }
	var method: HTTPMethod { get }
	var contentType: ContentType { get }
	var query: HTTPParameters { get }
	var body: HTTPParameters { get }
	var headers: HTTPHeaders { get }

	func decode(_ data: Data?) throws -> Model
}

public extension INetworkRequest {
	var api: API { .default }
	var method: HTTPMethod { .get }
	var contentType: ContentType { .json }
	var query: HTTPParameters { [:] }
	var body: HTTPParameters { [:] }
	var headers: HTTPHeaders { [:] }

	func asAnyRequest(baseURL: URL, baseHeaders: HTTPHeaders) -> AnyNetworkRequest {
		var headers = self.headers
		baseHeaders.forEach { headers[$0.key] = $0.value }
		return .init(
			baseURL: baseURL,
			path: self.path,
			method: self.method,
			contentType: self.contentType,
			query: self.query,
			body: self.body,
			headers: headers
		)
	}
}

public extension INetworkRequest where Model == Void {
	func decode(_ data: Data?) throws { () }
}

public struct AnyNetworkRequest {
	public var boundary: String {
		Data(self.path.utf8).base64EncodedString().replacingOccurrences(of: "=", with: "-")
	}

	public var absoluteString: String {
		"\(self.baseURL.absoluteString)\(self.path)"
	}

	public let baseURL: URL
	public let path: String
	public let method: HTTPMethod
	public let contentType: ContentType
	public let query: HTTPParameters
	public let body: HTTPParameters
	public let headers: HTTPHeaders
}
