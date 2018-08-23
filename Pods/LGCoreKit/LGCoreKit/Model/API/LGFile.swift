//
//  LGFile.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public struct LGFile: File, Equatable {
    public var objectId: String?
    public var fileURL: URL?
}

extension LGFile {
    public init(id: String?, urlString: String?) {
        self.objectId = id
        if let urlString = urlString {
            self.fileURL = URL(string: urlString)
        }
    }

    public init(id: String?, url: URL?) {
        self.objectId = id
        self.fileURL = url
    }
}

extension LGFile {
    static func mapToImages(_ array: [LGFile]) -> [LGListingImage] {
        return array.compactMap {
            guard let id = $0.objectId, let url = $0.fileURL else { return nil }
            return LGListingImage(id: id, url: url)
        }
    }
}

extension LGFile: CustomStringConvertible {
    public var description: String {
        return "fileURL: \(String(describing: fileURL)); token: \(String(describing: objectId)); isSaved: \(isSaved);"
    }
}

public func ==(lhs: LGFile, rhs: LGFile) -> Bool {
    return lhs.fileURL == rhs.fileURL &&
        lhs.objectId == rhs.objectId
}
