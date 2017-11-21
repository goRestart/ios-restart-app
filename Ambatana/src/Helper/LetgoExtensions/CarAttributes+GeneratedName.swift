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
        
        var yearString: String? = nil
        if let year = year {
            yearString = String(year)
        }
        
        carTitle = [make, model, yearString].flatMap{$0}.filter { $0 != CarAttributes.emptyMake && $0 != CarAttributes.emptyModel && $0 != String(CarAttributes.emptyYear) }.joined(separator: separator)
        
        return carTitle
    }
}
