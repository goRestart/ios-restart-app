//
//  StringExtensions.swift
//  LetGo
//
//  Created by AHL on 27/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

// MARK: - Capitalization

extension String {
    
    func lg_capitalizedWord() -> String {
        let prepositions = LanguageHelper.sharedInstance.prepositions
        if !prepositions.contains(self) {
            return self.capitalizedString
        }
        return self
    }
    
    func lg_capitalizedWords() -> String {
        let words = self.componentsSeparatedByString(" ") as [String]
        let capitalizedWords = words.map({ (let word) -> String in
            return word.lg_capitalizedWord()
        })
        let wordsArray = capitalizedWords as NSArray
        return wordsArray.componentsJoinedByString(" ")
    }
    
    func lg_capitalizedSentence() -> String {
        let words = self.componentsSeparatedByString(" ") as [String]
        if let first = words.first {
            let firstCapitalized = first.capitalizedString    // The first one is always capitalized
            let capitalizedWords = [firstCapitalized] + words[1 ..< words.count]
            let wordsArray = capitalizedWords as NSArray
            return wordsArray.componentsJoinedByString(" ")
        }
        return ""
    }
    
    func lg_capitalizedParagraph() -> String {
        let sentences = self.componentsSeparatedByString(".") as [String]
        let capitalizedSentences = sentences.map({ (let sentence) -> String in
            return sentence.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lg_capitalizedSentence()
        })
        let sentencesArray = capitalizedSentences as NSArray
        return sentencesArray.componentsJoinedByString(". ")
    }
}
