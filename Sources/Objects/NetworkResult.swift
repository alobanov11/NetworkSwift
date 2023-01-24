//
//  Created by Антон Лобанов on 17.01.2023.
//

import Foundation

public enum NetworkResult<Payload> {
	case success(Payload)
	case failure(Data?, Error)
}
