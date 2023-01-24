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
	private let requestBuilder: URLRequestBuilder
	private let session: INetworkSession

	public init(
		dataProvider: INetworkDataProvider,
		session: INetworkSession
	) {
		self.requestBuilder = .init(dataProvider: dataProvider)
		self.session = session
	}
}

extension NetworkClient: INetworkClient {
	@discardableResult
	public func perform<Request: INetworkRequest>(
		_ request: Request,
		completion: @escaping (NetworkResult<Request.Model>) -> Void
	) -> Cancellable {
		do {
			let urlRequest = try self.requestBuilder.build(with: request)

			NetworkLogger.log([
				"Call request: \(request.path)",
				urlRequest.allHTTPHeaderFields,
				request.body,
				request.contentType.value,
				request.method.rawValue,
			])

			return self.session.perform(urlRequest) { data, error in
				if let error {
					return completion(.failure(data, error))
				}
				do {
					completion(.success(try request.decode(try data.orThrow(NetworkError.emptyData))))
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
