//
//  Created by Антон Лобанов on 02.02.2022.
//

import Foundation

public protocol INetworkDataProvider {
	func baseURL(for api: API) -> String?
	func baseHeaders(for api: API) -> [String: String]
}

public protocol INetwork: AnyObject {
	@discardableResult
	func dispatch<R>(_ request: Request<R>, completion: @escaping (NetworkResult<R>) -> Void) -> URLSessionDataTask?
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
	public func dispatch<R>(_ request: Request<R>, completion: @escaping (NetworkResult<R>) -> Void) -> URLSessionDataTask? {
		let baseHeaders = self.dataProvider.baseHeaders(for: request.api)
		let parameters = request.parameters()

		guard let baseURL = self.dataProvider.baseURL(for: request.api),
			  let urlRequest = parameters.urlRequest(baseURL: baseURL, baseHeaders: baseHeaders)
		else {
			completion(.failure(nil, NetworkError.invalidRequest))
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
			if let error {
				return completion(.failure(data, error))
			}
			do {
				completion(.success(try request.encode(data)))
			}
			catch {
				completion(.failure(data, error))
			}
		}
	}
}
