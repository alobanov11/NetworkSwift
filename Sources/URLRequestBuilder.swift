//
//  Created by Антон Лобанов on 24.01.2023.
//

import Foundation

public protocol INetworkDataProvider {
	func baseURL(for api: API) -> String?
	func baseHeaders(for api: API) -> [String: String]
}

final class URLRequestBuilder {
	private let dataProvider: INetworkDataProvider

	init(dataProvider: INetworkDataProvider) {
		self.dataProvider = dataProvider
	}

	func build(with request: AnyNetworkRequest) throws -> URLRequest {
		let baseHeaders = self.dataProvider.baseHeaders(for: request.api)

		guard let baseURL = self.dataProvider.baseURL(for: request.api) else {
			throw NSError()
		}

		guard var urlComponents = URLComponents(string: baseURL) else {
			throw NSError()
		}

		urlComponents.path = "\(urlComponents.path)\(request.path)"

		if let query = request.query {
			urlComponents.queryItems = self.queryItems(with: query)
		}

		guard let finalURL = urlComponents.url else {
			throw NSError()
		}

		var urlRequest = URLRequest(url: finalURL)
		urlRequest.httpMethod = request.method.rawValue

		request.headers?.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
		baseHeaders.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
		urlRequest.setValue("\(request.contentType.value)", forHTTPHeaderField: "Content-Type")

		if request.method.isAllowedToContainBody {
			switch request.contentType {
			case let .multipartData(data):
				urlRequest.setValue(
					"\(request.contentType.value); boundary=\(request.boundary)",
					forHTTPHeaderField: "Content-Type"
				)
				urlRequest.httpBody = self.encodeMultipart(with: data, boundary: request.boundary, params: request.body)
			case .formURLEncoded:
				urlRequest.httpBody = try self.encodeURLForm(with: try request.body.orThrow(NSError()))
			default:
				urlRequest.httpBody = try JSONSerialization.data(
					withJSONObject: try request.body.orThrow(NSError()),
					options: []
				)
			}
		}

		return urlRequest
	}
}

private extension URLRequestBuilder {
	func queryItems(with params: [String: Any], nested: Bool = false) -> [URLQueryItem] {
		params.compactMap { key, value -> [URLQueryItem]? in
			let key = nested ? "[\(key)]" : key

			if let value = value as? Bool {
				return [URLQueryItem(name: key, value: value.description)]
			}
			else if let value = value as? NSNumber {
				return [URLQueryItem(name: key, value: String(value.stringValue))]
			}
			else if let value = value as? NSString {
				return [URLQueryItem(name: key, value: String(value))]
			}
			else if let value = value as? [String: Any] {
				let items = self.queryItems(with: value, nested: true)
				return items.map {
					URLQueryItem(name: "\(key)\($0.name)", value: $0.value)
				}
			}

			return nil
		}.flatMap { $0 }
	}
}

private extension URLRequestBuilder {
	func encodeMultipart(
		with multipartData: [MultipartData],
		boundary: String,
		params: [String: Any]?
	) -> Data {
		var bodyData = Data()

		if let parameters = params {
			for (key, value) in parameters {
				let usedValue: Any = value is NSNull ? "null" : value
				var body = ""
				body += "--\(boundary)\r\n"
				body += "Content-Disposition: form-data; name=\"\(key)\""
				body += "\r\n\r\n\(usedValue)\r\n"
				bodyData.append(body.data(using: .utf8)!)
			}
		}

		multipartData.forEach {
			bodyData.append($0.formData(with: boundary))
		}

		bodyData.appendString("--\(boundary)--\r\n")

		return bodyData
	}

	func encodeURLForm(with params: [String: Any]) throws -> Data {
		let allowedCharacters = CharacterSet(charactersIn: " \"#%/:<>?@[\\]^`{|}+=").inverted

		let bodyString = params
			.sorted { $0.key < $1.key }
			.map { key, value in
				let value = "\(value)".addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? value
				return "\(key)=\(value)"
			}.joined(separator: "&")

		return try bodyString.data(using: .utf8).orThrow(NSError())
	}
}

private extension MultipartData {
	func formData(with boundary: String) -> Data {
		var body = ""

		body += "--\(boundary)\r\n"
		body += "Content-Disposition: form-data; "
		body += "name=\"\(self.name)\""
		body += "; filename=\"\(self.fileName)\""
		body += "\r\n"
		body += "Content-Type: \(self.mimeType)\r\n\r\n"

		var bodyData = Data()

		bodyData.appendString(body)
		bodyData.append(self.data)
		bodyData.appendString("\r\n")

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
