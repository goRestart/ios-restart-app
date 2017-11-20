//
//  CarCreationParams+GeneratedName.swift
//  LetGo
//
//  Created by Dídac on 03/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension CarAttributes {
    var generatedCarName: String {
        let separator = " - "
        var carTitle: String = ""
        
        if let makeName = make, makeName != CarAttributes.emptyMake {
            carTitle = makeName
        }
        if let modelName = model, modelName != CarAttributes.emptyModel {
            let separator = carTitle.isEmpty ? "" : separator
            carTitle += separator + modelName
        }
        if let yearName = year, yearName != CarAttributes.emptyYear {
            let separator = carTitle.isEmpty ? "" : separator
            carTitle += separator + String(yearName)
        }
        return carTitle
    }
}
