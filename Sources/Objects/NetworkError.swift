//
//  Created by Антон Лобанов on 14.10.2021.
//

import Foundation

public enum NetworkError: Error, Equatable {
	case badRequest
	case unauthorized
	case forbidden
	case notFound
	case error4xx(_ code: Int)
	case serverError
	case error5xx(_ code: Int)
	case invalidRequest
}

public extension NetworkError {
	init(code: Int) {
		switch code {
		case 400: self = .badRequest
		case 401: self = .unauthorized
		case 403: self = .forbidden
		case 404: self = .notFound
		case 402, 405 ... 499: self = .error4xx(code)
		case 500: self = .serverError
		case 501 ... 599: self = .error5xx(code)
		default: self = .invalidRequest
		}
	}
}
