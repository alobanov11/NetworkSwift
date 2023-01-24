//
//  Created by Антон Лобанов on 14.10.2021.
//

import Foundation

public enum ContentType {
	case json
	case formURLEncoded
	case multipartData([MultipartData])

	var value: String {
		switch self {
		case .json: return "application/json"
		case .formURLEncoded: return "application/x-www-form-urlencoded"
		case .multipartData: return "multipart/form-data"
		}
	}
}
