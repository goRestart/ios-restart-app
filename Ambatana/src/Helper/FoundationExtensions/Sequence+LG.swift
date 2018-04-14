//
//  Sequence+LG.swift
//  LetGo
//
//  Created by Dídac on 11/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

extension Sequence {
    func first(matching: (Element) -> Bool) -> Element? {
        for element in self {
            if matching(element) { return element }
        }
        return nil
    }
}
