//
//  LanguageHelper.swift
//  LetGo
//
//  Created by AHL on 27/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

final public class LanguageHelper {
    
    // Constants
    private static let prepositionsFilename = "words_lowercase.json"
 
    // Singleton
    static let sharedInstance = LanguageHelper()
    
    // iVars
    var prepositions: [String]
    
    // MARK: - Lifecycle
    
    init() {
        
        if let fileName = NSBundle.mainBundle().URLForResource(LanguageHelper.prepositionsFilename, withExtension: ""),
           let filePath = NSBundle.mainBundle().pathForResource(fileName.URLByDeletingPathExtension?.lastPathComponent, ofType: fileName.pathExtension),
            let data = NSData(contentsOfFile: filePath) {
                
                do {
                    if let preps = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String] {
                        prepositions = preps
                    }
                    else {
                        prepositions = []
                    }
                } catch {
                    prepositions = []
                }
        }
        else {
            prepositions = []
        }
    }
}