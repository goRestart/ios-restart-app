//
//  CarCreationParams+GeneratedName.swift
//  LetGo
//
//  Created by Dídac on 03/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension CarAttributes {
    func generatedCarName() -> String {
        var carTitle: String = ""
        if let makeName = make, !makeName.isEmpty {
            carTitle += makeName + " "
        }
        if let modelName = model, !modelName.isEmpty {
            carTitle += modelName + " "
        }
        if let year = year, year != 0 {
            carTitle += String(year)
        }
        return carTitle
    }
}
