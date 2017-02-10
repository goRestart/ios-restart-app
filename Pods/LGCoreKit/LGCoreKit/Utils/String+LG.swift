//
//  String+LG.swift
//  LGCoreKit
//
//  Created by Nestor Garcia on 19/12/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

extension String {
    func lastComponentSeparatedByCharacter(_ character: Character) -> String? {
        return self.characters.split(separator: character).last.map { String($0) }
    }
    
    func getBinaryValues() -> (String,String) {
        var latBin = ""
        var lonBin = ""
        guard !isEmpty else { return (latBin,lonBin) }
        for i in 0...characters.count - 1 {
            let quadCharInt = getCharInt(at: i)
            latBin += String(quadCharInt >> 1)
            lonBin += String(quadCharInt & 1)
        }
        
        return (latBin,lonBin)
    }
    
    func getBinaryValue() -> Double {
        let oneVal = self + "1"
        let decimal = strtoul(oneVal, nil, 2)
        return Double(decimal) / pow(2.0, Double(oneVal.characters.count))
    }
    
    func getCharInt(at index: Int) -> Int {
        if !isEmpty && index < characters.count {
            let singleChar = Array(characters)[index]
            if let singleInt = Int(String(singleChar)) {
                return singleInt
            } else {
                return 0
            }
        }
        return 0
    }

}
