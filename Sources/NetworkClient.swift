//
//  Created by Антон Лобанов on 02.02.2022.
//

import Foundation

public protocol INetworkClient: AnyObject {
	@discardableResult
	func perform<Request: INetworkRequest>(
		_ request: Request,
		completion: @escaping (NetworkResult<Request.Model>) -> Void
	) -> Cancellable
}

public final class NetworkClient {
	private let session: INetworkSession
	private let requestBuilder: IURLRequestBuilder

	public init(
		session: INetworkSession,
		requestBuilder: IURLRequestBuilder
	) {
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
			let urlRequest = try self.requestBuilder.build(request)

            LogHandler?([
				"Call request: \(urlRequest.url?.absoluteString ?? "-")",
				urlRequest.allHTTPHeaderFields,
				request.body,
				request.contentType.value,
				request.method.rawValue,
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
