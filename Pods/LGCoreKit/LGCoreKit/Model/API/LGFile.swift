//
//  LGFile.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public class LGFile: File {
    
    public var fileURL: NSURL?
    public var isSaved: Bool = true
    public var token: String?
    
    public init(url: NSURL?) {
        self.fileURL = url
    }
}

extension LGFile: CustomStringConvertible {
    public var description: String {
        return "fileURL: \(fileURL); token: \(token); isSaved: \(isSaved);"
    }
}
