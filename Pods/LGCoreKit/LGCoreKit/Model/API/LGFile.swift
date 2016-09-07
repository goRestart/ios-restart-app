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
    public init(id: String?, urlString: String?) {
        self.objectId = id
        if let urlString = urlString {
            self.fileURL = NSURL(string: urlString)
        }
    }

    public init(id: String?, url: NSURL?) {
        self.objectId = id
        self.fileURL = url
    }
}

extension LGFile: CustomStringConvertible {
    public var description: String {
        return "fileURL: \(fileURL); token: \(objectId); isSaved: \(isSaved);"
    }
}
