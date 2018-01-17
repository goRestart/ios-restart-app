//
//  DailyCountIncrementer.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 15/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class DailyCountIncrementer {
    
    // MARK: - Search count
    
    static func randomizeSearchCount(baseSearchCount: Int, itemIndex: Int) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        let value = NSNumber(value: baseSearchCount + incrementSearchCount(baseSearchCount,
                                                                           itemIndex: itemIndex))
        return numberFormatter.string(from: value)
    }
    
    
    // MARK: - Helpers
    
    private static func incrementSearchCount(_ baseSearchCount: Int, itemIndex: Int) -> Int {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.month,.day], from: date)
        let month = components.month ?? 1
        let day = components.day ?? 1
        let dailyIncrement = baseSearchCount/200
        let monthDivision = max(month / max(itemIndex, 1), 1)
        let increment = dailyIncrement + (itemIndex * day) / monthDivision // "randomizing" like a baws
        return increment
    }
    
}
