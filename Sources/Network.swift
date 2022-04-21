//
//  Created by Антон Лобанов on 02.02.2022.
//

import Foundation

public protocol INetwork: AnyObject {
	@discardableResult
	func dispatch<R>(_ request: Request<R>, completion: @escaping (Result<R, NetworkError>) -> Void) -> RequestTask?
}

public final class Network {
	private let dataProvider: INetworkDataProvider
	private let dispatcher: INetworkDispatcher

	public init(
		dataProvider: INetworkDataProvider,
		dispatcher: INetworkDispatcher
	) {
		self.dataProvider = dataProvider
		self.dispatcher = dispatcher
	}
}

extension Network: INetwork {
	@discardableResult
	public func dispatch<R>(_ request: Request<R>, completion: @escaping (Result<R, NetworkError>) -> Void) -> RequestTask? {
		let baseHeaders = self.dataProvider.baseHeaders(for: request.api)
		let parameters = request.parameters()

		guard let baseURL = self.dataProvider.baseURL(for: request.api),
			  let urlRequest = parameters.urlRequest(baseURL: baseURL, baseHeaders: baseHeaders)
		else {
			completion(.failure(.invalidRequest))
			return nil
		}

		NetworkLogger.log([
			"Call request: \(parameters.path)",
			urlRequest.allHTTPHeaderFields,
			parameters.body,
			parameters.contentType.value,
			parameters.method.rawValue,
		])

		return self.dispatcher.dispatch(urlRequest) { result in
			switch result {
			case let .success(data):
				do {
					completion(.success(try request.encode(data)))
				}
				catch {
					completion(.failure(.decodingError(error)))
				}
			case let .failure(error):
				completion(.failure(error))
			}
		}
	}
}
