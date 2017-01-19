//
//  String+Randomizable.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 28/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

extension String {
    /**
    Returns a random string with the given length.
    */
    static func random(_ length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.characters.index(allowedChars.startIndex, offsetBy: randomNum)]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
    
    /**
    Returns a random e-mail string.
    */
    static func randomEmail() -> String {
        let name = random(10)
        let domain = random(10)
        return "\(name)@\(domain).com"
    }
    
    /**
    Returns a phrase with the given number of words.
    */
    static func randomPhrase(_ words: Int, wordLengthMin: Int = 2, wordLengthMax: Int = 10) -> String {
        var phrase = ""
        for _ in 0..<words {
            let length = Int.random(wordLengthMin, wordLengthMax)
            let word = random(length)
            phrase += " \(word)"
        }
        return phrase
    }

    /**
    Returns a random URL string.
    */
    static func randomURL() -> String {
        return "http://\(random(10)).com/\(random(5))"
    }
}
