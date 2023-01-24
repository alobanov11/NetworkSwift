//
//  Created by Антон Лобанов on 02.02.2022.
//

import Foundation

public protocol INetworkAdapter: AnyObject {
	func adapt<Request: INetworkRequest>(_ request: Request) throws -> AnyNetworkRequest
}

public protocol INetworkClient: AnyObject {
	@discardableResult
	func perform<Request: INetworkRequest>(
		_ request: Request,
		completion: @escaping (NetworkResult<Request.Model>) -> Void
	) -> Cancellable
}

public final class NetworkClient {
	private let adapter: INetworkAdapter
	private let session: INetworkSession
	private let requestBuilder: IURLRequestBuilder

	public init(
		adapter: INetworkAdapter,
		session: INetworkSession,
		requestBuilder: IURLRequestBuilder = URLRequestBuilder()
	) {
		self.adapter = adapter
		self.session = session
		self.requestBuilder = requestBuilder
	}
}

extension NetworkClient: INetworkClient {
	@discardableResult
	public func perform<Request: INetworkRequest>(
		_ request: Request,
		completion: @escaping (NetworkResult<Request.Model>) -> Void
	) -> Cancellable {
		do {
			let anyRequest = try self.adapter.adapt(request)
			let urlRequest = try self.requestBuilder.build(anyRequest)

			NetworkLogger.log([
				"Call request: \(anyRequest.absoluteString)",
				anyRequest.headers,
				anyRequest.body,
				anyRequest.contentType.value,
				anyRequest.method.rawValue,
			])

			return self.session.perform(urlRequest) { data, _, error in
				if let error {
					return completion(.failure(data, error))
				}
				do {
					completion(.success(try request.decode(data)))
				}
				catch {
					completion(.failure(data, error))
				}
			}
		}
		catch {
			completion(.failure(nil, NetworkError.invalidRequest))
			return EmptyCancellable()
		}
	}
}
