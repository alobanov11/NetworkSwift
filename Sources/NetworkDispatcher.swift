//
//  Created by Антон Лобанов on 14.10.2021.
//

import Foundation

public protocol INetworkDispatcher: AnyObject {
	/// Dispatches an URLRequest and returns a publisher
	/// - Parameter request: URLRequest
	/// - Returns: A publisher with the provided decoded data or an error
	@discardableResult
	func dispatch(_ urlRequest: URLRequest, completion: @escaping (Data?, Error?) -> Void) -> RequestTask
}

public final class NetworkDispatcher {
	private let urlSession: URLSession

	public init(urlSession: URLSession = .shared) {
		self.urlSession = urlSession
	}
}

extension NetworkDispatcher: INetworkDispatcher {
	@discardableResult
	public func dispatch(
		_ urlRequest: URLRequest,
		completion: @escaping (Data?, Error?) -> Void
	) -> RequestTask {
		let sessionTask = self.urlSession.dataTask(with: urlRequest) { data, response, error in
			NetworkLogger.log([
				"Finish request: \(urlRequest.url?.absoluteString ?? "#")",
				"Code - \((response as? HTTPURLResponse)?.statusCode ?? 0)",
				"Error - \(String(describing: error))",
				"Data:",
				data.map { String(data: $0, encoding: .utf8) ?? "#" } ?? "#",
			])

			if let error = error {
				completion(data, error)
				return
			}

			if let response = response as? HTTPURLResponse, (200 ... 299).contains(response.statusCode) == false {
				completion(data, NetworkError(code: response.statusCode))
				return
			}

			completion(data, nil)
		}
		sessionTask.resume()
		return .init(urlSessionDataTask: sessionTask)
	}
}
