//
//  VideoUpload.swift
//  LetGo
//
//  Created by Álvaro Murillo del Puerto on 21/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

struct VideoUpload {
    let recordedVideo: RecordedVideo
    let snapshot: File?
    let videoId: String?
}

extension LGVideo {
    init?(videoUpload: VideoUpload) {
        guard let path = videoUpload.videoId, let snapshot = videoUpload.snapshot?.objectId else { return nil }
        self.path = path
        self.snapshot = snapshot
    }
}
