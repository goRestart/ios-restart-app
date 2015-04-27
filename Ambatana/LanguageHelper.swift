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
    private static let PREPOSITIONS_FILENAME = "words_lowercase.json"
 
    // Singleton
    static let sharedInstance = LanguageHelper()
    
    // iVars
    var prepositions: [String]
    
    // MARK: - Lifecycle
    
    init() {
        let fileName = LanguageHelper.PREPOSITIONS_FILENAME
        var error: NSError?
        if let filePath = NSBundle.mainBundle().pathForResource(fileName.stringByDeletingPathExtension, ofType: fileName.pathExtension),
           let data = NSData(contentsOfFile: filePath),
           let preps = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? [String] {
            prepositions = preps
        }
        else {
            prepositions = []
        }
    }
}