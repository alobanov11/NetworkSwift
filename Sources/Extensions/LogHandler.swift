//
//  Created by Антон Лобанов on 06.05.2023.
//

import Foundation

public var LogHandler: (([Any?]) -> Void)? = { values in
    #if DEBUG
    print(String(repeating: "_", count: 85))
    for value in values {
        if let value = value {
            print(value)
        }
    }
    print(String(repeating: "_", count: 85))
    #endif
}
