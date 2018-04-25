//
//  Video.swift
//  LGCoreKit
//
//  Created by Álvaro Murillo del Puerto on 21/4/18.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol Video: Encodable {
    var path: String { get }
    var snapshot: String  { get }
}

public struct LGVideo: Video {
    public let path: String
    public let snapshot: String

    public init(path: String, snapshot: String){
        self.path = path
        self.snapshot = snapshot
    }
}

extension LGVideo {
    init?(media: Media) {
        guard media.type == .video, let path = media.outputs.video?.lastPathComponent else { return nil }
        self.path = path
        self.snapshot = media.snapshotId
    }
}
