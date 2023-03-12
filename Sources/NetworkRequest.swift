//
//  Created by Антон Лобанов on 24.01.2023.
//

import Foundation

public typealias HTTPParameters = [String: Any]
public typealias HTTPHeaders = [String: String]

public protocol INetworkRequest {
	associatedtype Model

	var endpoint: Endpoint { get }
	var path: String { get }
	var method: HTTPMethod { get }
	var contentType: ContentType { get }
	var query: HTTPParameters { get }
	var body: HTTPParameters { get }
	var headers: HTTPHeaders { get }

	func decode(_ data: Data?) throws -> Model
}

public extension INetworkRequest {
	var endpoint: Endpoint { .default }
	var method: HTTPMethod { .get }
	var contentType: ContentType { .json }
	var query: HTTPParameters { [:] }
	var body: HTTPParameters { [:] }
	var headers: HTTPHeaders { [:] }
}

public extension INetworkRequest where Model == Void {
	func decode(_ data: Data?) throws { () }
}
