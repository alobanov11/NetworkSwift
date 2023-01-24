//
//  Created by Антон Лобанов on 29.11.2021.
//

import Foundation

public struct MultipartData {
	public let data: Data
	public let name: String
	public let fileName: String
	public let mimeType: String

	public init(data: Data, name: String, fileName: String, mimeType: String) {
		self.data = data
		self.name = name
		self.fileName = fileName
		self.mimeType = mimeType
	}
}
