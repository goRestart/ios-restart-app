//
//  Media.swift
//  LetGo
//
//  Created by Juan Iglesias on 17/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import UserNotifications
import UIKit


struct Media {
    private var data: Data
    private var ext: String
    
    init(withData data: Data, fileExtension ext: String) {
        self.data = data
        self.ext = ext
    }
    
    var attachmentOptions: [String: Any?] {
        return [UNNotificationAttachmentOptionsThumbnailTimeKey: 0]
    }
    
    var fileIdentifier: String {
        return self.ext
    }
    
    var fileExt: String? {
        if self.ext.characters.count > 0 {
            return self.ext
        }
        return nil
    }
    
    var mediaData: Data? {
        return self.data
    }
}

