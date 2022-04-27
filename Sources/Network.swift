//
//  Created by Антон Лобанов on 02.02.2022.
//

import Foundation

public protocol INetworkDataProvider {
	func baseURL(for api: RequestAPI) -> String?
	func baseHeaders(for api: RequestAPI) -> [String: String]
}

public protocol INetworkMiddleware: AnyObject {
	func process<R>(
		_ error: Error,
		_ data: Data?,
		_ request: Request<R>,
		_ completion: @escaping (Result<R, Error>) -> Void
	) -> Bool
}

public protocol INetwork: AnyObject {
	@discardableResult
	func dispatch<R>(_ request: Request<R>, completion: @escaping (Result<R, Error>) -> Void) -> RequestTask?
}

public final class Network {
	private var middlewares: [Weak<INetworkMiddleware>] = []

	private let dataProvider: INetworkDataProvider
	private let dispatcher: INetworkDispatcher

	public init(
		dataProvider: INetworkDataProvider,
		dispatcher: INetworkDispatcher
	) {
		self.dataProvider = dataProvider
		self.dispatcher = dispatcher
	}

	func middleware(_ object: INetworkMiddleware) {
		self.middlewares.append(Weak(object))
	}
}

extension Network: INetwork {
	@discardableResult
	public func dispatch<R>(_ request: Request<R>, completion: @escaping (Result<R, Error>) -> Void) -> RequestTask? {
		let baseHeaders = self.dataProvider.baseHeaders(for: request.api)
		let parameters = request.parameters()

		guard let baseURL = self.dataProvider.baseURL(for: request.api),
			  let urlRequest = parameters.urlRequest(baseURL: baseURL, baseHeaders: baseHeaders)
		else {
			completion(.failure(NetworkError.invalidRequest))
			return nil
		}

		NetworkLogger.log([
			"Call request: \(parameters.path)",
			urlRequest.allHTTPHeaderFields,
			parameters.body,
			parameters.contentType.value,
			parameters.method.rawValue,
		])

		return self.dispatcher.dispatch(urlRequest) { data, error in
			if let error = error {
				for middleware in self.middlewares {
					if middleware.element?.process(error, data, request, completion) == true {
						return
					}
				}
				completion(.failure(error))
				return
			}
			do {
				completion(.success(try request.encode(data)))
			}
			catch {
				completion(.failure(error))
			}
		}
	}
}
