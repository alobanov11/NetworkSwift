//
//  Created by Антон Лобанов on 14.10.2021.
//

import Foundation

public final class RequestTask {
	public let urlSessionDataTask: URLSessionDataTask

	init(urlSessionDataTask: URLSessionDataTask) {
		self.urlSessionDataTask = urlSessionDataTask
	}

	public func cancel() {
		self.urlSessionDataTask.cancel()
	}
}

open class Request<ReturnType> {
	open var api: ApiRequest { .default }

	public init() {}

	// swiftlint:disable unavailable_function
	open func parameters() -> RequestParameters {
		fatalError("Must be overriden in subclass")
	}

	// swiftlint:disable unavailable_function
	open func encode(_: Data?) throws -> ReturnType {
		fatalError("Must be overriden in subclass")
	}
}

public struct RequestParameters {
	public var boundary: String {
		Data(self.path.utf8).base64EncodedString()
	}

	public let path: String
	public let method: HTTPMethod
	public let contentType: ContentType
	public let query: [String: Any]?
	public let body: [String: Any]?
	public let headers: [String: String]?

	public init(
		path: String,
		method: HTTPMethod,
		contentType: ContentType,
		query: [String: Any]? = nil,
		body: [String: Any]? = nil,
		headers: [String: String]? = nil
	) {
		self.path = path
		self.method = method
		self.contentType = contentType
		self.query = query
		self.body = body
		self.headers = headers
	}

	public func urlRequest(baseURL: String, baseHeaders: [String: String]) -> URLRequest? {
		guard var urlComponents = URLComponents(string: baseURL) else { return nil }

		urlComponents.path = "\(urlComponents.path)\(self.path)"
		urlComponents.queryItems = self.queryItems(params: self.query)

		guard let finalURL = urlComponents.url else { return nil }

		var request = URLRequest(url: finalURL)

		var headers = baseHeaders

		self.headers?.forEach {
			headers[$0.key] = $0.value
		}

		request.httpMethod = self.method.rawValue
		request.allHTTPHeaderFields = headers

		switch self.contentType {
		case let .multipartData(data):
			request.setValue(
				"\(self.contentType.value); boundary=\(self.boundary)",
				forHTTPHeaderField: "Content-Type"
			)
			request.httpBody = self.bodyFrom(multipartData: data, params: self.body)
		default:
			request.setValue("\(self.contentType.value)", forHTTPHeaderField: "Content-Type")
			request.httpBody = self.bodyFrom(params: self.body)
		}

		return request
	}
}

private extension RequestParameters {
	func queryItems(params: [String: Any]?) -> [URLQueryItem] {
		params?.compactMap { key, value -> [URLQueryItem]? in
			if let value = value as? NSNumber {
				return [URLQueryItem(name: key, value: String(value.stringValue))]
			}
			else if let value = value as? NSString {
				return [URLQueryItem(name: key, value: String(value))]
			}
			else if let value = value as? [String: Any] {
				let items = self.queryItems(params: value)
				return items.map {
					URLQueryItem(name: "\(key)[\($0.name)]", value: $0.value)
				}
			}
			return nil
		}.flatMap { $0 } ?? []
	}

	func bodyFrom(params: [String: Any]?) -> Data {
		guard let params = params,
			  JSONSerialization.isValidJSONObject(params),
			  let httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
		else {
			return Data()
		}
		return httpBody
	}

	// swiftlint:disable force_unwrapping
	func bodyFrom(multipartData: [MultipartData], params: [String: Any]?) -> Data {
		var bodyData = Data()

		if let parameters = params {
			for (key, value) in parameters {
				let usedValue: Any = value is NSNull ? "null" : value
				var body = ""
				body += "--\(self.boundary)\r\n"
				body += "Content-Disposition: form-data; name=\"\(key)\""
				body += "\r\n\r\n\(usedValue)\r\n"
				bodyData.append(body.data(using: .utf8)!)
			}
		}

		multipartData.forEach {
			bodyData.append($0.formData(with: self.boundary))
		}

		bodyData.append("--\(self.boundary)--\r\n".data(using: .utf8)!)

		return bodyData
	}
}

private extension Data {
	mutating func appendString(_ string: String) {
		if let data = string.data(using: .utf8) {
			self.append(data)
		}
	}
}
