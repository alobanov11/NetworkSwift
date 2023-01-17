//
//  Created by Антон Лобанов on 17.01.2023.
//

import Foundation

public enum NetworkResult<R> {
	case success(R)
	case failure(Data?, Error)
}
