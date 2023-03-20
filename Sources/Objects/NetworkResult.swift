//
//  Created by Антон Лобанов on 17.01.2023.
//

import Foundation

public enum NetworkResult<Model> {
	case success(Model)
	case failure(Data?, NetworkError)
}
