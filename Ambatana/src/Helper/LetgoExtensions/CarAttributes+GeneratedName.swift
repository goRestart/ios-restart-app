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
        if let makeName = make, makeName != CarAttributes.emptyMake {
            carTitle += makeName + " "
        }
        if let modelName = model, modelName != CarAttributes.emptyModel {
            carTitle += modelName + " "
        }
        if let year = year, year != CarAttributes.emptyYear {
            carTitle += String(year)
        }
        return carTitle
    }
}
