//
//  Created by Антон Лобанов on 29.11.2021.
//

import Foundation

public struct MultipartData {
	public let data: Data
	public let name: String
	public let fileName: String
	public let mimeType: String

	/// Instantiates multipart data struct
	///
	/// - Parameters:
	/// - data: data representation of an object
	/// - name: name of object
	/// - fileName: name of file to be created
	/// - mimeType: type of content
	public init(data: Data, name: String, fileName: String, mimeType: String) {
		self.data = data
		self.name = name
		self.fileName = fileName
		self.mimeType = mimeType
	}

	// swiftlint:disable force_unwrapping
	func formData(with boundary: String) -> Data {
		var body = ""

		body += "--\(boundary)\r\n"
		body += "Content-Disposition: form-data; "
		body += "name=\"\(self.name)\""
		body += "; filename=\"\(self.fileName)\""
		body += "\r\n"
		body += "Content-Type: \(self.mimeType)\r\n\r\n"

		var bodyData = Data()

		bodyData.append(body.data(using: .utf8)!)
		bodyData.append(self.data)
		bodyData.append("\r\n".data(using: .utf8)!)

		return bodyData
	}
}
