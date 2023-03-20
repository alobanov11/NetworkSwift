//
//  Created by Антон Лобанов on 14.10.2021.
//

public enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case patch = "PATCH"
	case delete = "DELETE"
}

extension HTTPMethod {
	var isAllowedToContainBody: Bool {
		[HTTPMethod.post, .put, .patch].contains(self)
	}
}
