//
//  Media.swift
//  LetGo
//
//  Created by Juan Iglesias on 17/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UserNotifications
import UIKit

public enum MediaType: String {
    case image = "image"
    case gif = "gif"
    case video = "video"
    case audio = "audio"
}

struct Media {
    private var data: Data
    private var ext: String
    private var type: MediaType
    
    init(forMediaType mediaType: MediaType, withData data: Data, fileExtension ext: String) {
        self.type = mediaType
        self.data = data
        self.ext = ext
    }
    
    var attachmentOptions: [String: Any?] {
        switch(self.type) {
        case .image:
            return [UNNotificationAttachmentOptionsThumbnailClippingRectKey: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.50).dictionaryRepresentation]
        case .gif:
            return [UNNotificationAttachmentOptionsThumbnailTimeKey: 0]
        case .video:
            return [UNNotificationAttachmentOptionsThumbnailTimeKey: 0]
        case .audio:
            return [UNNotificationAttachmentOptionsThumbnailHiddenKey: 1]
        }
    }
    
    var fileIdentifier: String {
        return self.type.rawValue
    }
    
    var fileExt: String {
        if self.ext.characters.count > 0 {
            return self.ext
        } else {
            switch(self.type) {
            case .image:
                return "jpg"
            case .gif:
                return "gif"
            case .video:
                return "mp4"
            case .audio:
                return "mp3"
            }
        }
    }
    
    var mediaData: Data? {
        return self.data
    }
}

