//
//  Character+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 8/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


extension Character {
    func isEmoji() -> Bool {
        return Character(UnicodeScalar(0x1d000))...Character(UnicodeScalar(0x1f77f)) ~= self
            ||  Character(UnicodeScalar(0x2100))...Character(UnicodeScalar(0x3299)) ~= self
    }
}
