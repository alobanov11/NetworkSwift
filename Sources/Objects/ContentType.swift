//
//  Created by Антон Лобанов on 14.10.2021.
//

import Foundation

public enum ContentType {
	case json
	case formURLEncoded
	case multipartData([MultipartData])
	case multipart

	var value: String {
		switch self {
		case .json: return "application/json; charset=utf-8"
		case .formURLEncoded: return "application/x-www-form-urlencoded"
		case .multipartData, .multipart: return "multipart/form-data"
		}
	}
}
