//
//  Created by Антон Лобанов on 14.10.2021.
//

import Foundation

public protocol INetworkSession: AnyObject {
	@discardableResult
	func perform(_ urlRequest: URLRequest, completion: @escaping (Data?, Error?) -> Void) -> Cancellable
}

public protocol Cancellable {
	func cancel()
}

struct EmptyCancellable: Cancellable {
	func cancel() {}
}

public final class NetworkSession {
	private final class NetworkDataTask: Cancellable {
		private let dataTask: URLSessionDataTask

		init(_ dataTask: URLSessionDataTask) {
			self.dataTask = dataTask
		}

		func cancel() {
			self.dataTask.cancel()
		}
	}

	private let urlSession: URLSession

	public init(urlSession: URLSession = .shared) {
		self.urlSession = urlSession
	}
}

extension NetworkSession: INetworkSession {
	@discardableResult
	public func perform(_ urlRequest: URLRequest, completion: @escaping (Data?, Error?) -> Void) -> Cancellable {
		let dataTask = self.urlSession.dataTask(with: urlRequest) { data, response, error in
			NetworkLogger.log([
				"Finish request: \(urlRequest.url?.absoluteString ?? "#")",
				"Code - \((response as? HTTPURLResponse)?.statusCode ?? 0)",
				"Error - \(String(describing: error))",
				"Data:",
				data.map { String(data: $0, encoding: .utf8) ?? "#" } ?? "#",
			])

			if let error {
				completion(data, error)
				return
			}

			if let response = response as? HTTPURLResponse, (200 ... 299).contains(response.statusCode) == false {
				completion(data, NetworkError(code: response.statusCode))
				return
			}

			completion(data, nil)
		}
		dataTask.resume()
		return NetworkDataTask(dataTask)
	}
}