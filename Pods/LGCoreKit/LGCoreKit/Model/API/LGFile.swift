//
//  LGFile.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public struct LGFile: File {
    
    public var objectId: String?
    
    public var fileURL: NSURL?
}

extension LGFile {
    public init?(string: String?) {
        if let urlString = string {
            self.fileURL = NSURL(string: urlString)
        }
        else {
            return nil
        }
    }
    
    public init(url: NSURL?) {
        self.fileURL = url
    }
}

extension LGFile: CustomStringConvertible {
    public var description: String {
        return "fileURL: \(fileURL); token: \(objectId); isSaved: \(isSaved);"
    }
}
