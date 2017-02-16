//
//  NotificationService.swift
//  LGPushNotification
//
//  Created by Juan Iglesias on 16/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//



import UIKit
import UserNotifications

public enum MediaType: String {
    case image = "image"
    case gif = "gif"
    case video = "video"
    case audio = "audio"
}

fileprivate struct Media {
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

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            var urlResource: String?
            var mediaType: MediaType?
            
            if let leanplumURL = request.content.userInfo["LP_URL"] as? String {
                urlResource = leanplumURL
                mediaType = .image
            } else if let notificationData = request.content.userInfo["aps"] as? [String : Any], let notiData = notificationData["data"] as? [String : String] {
                if let urlString = notiData["attachment-url"], let rawMediaType = notificationData["media-type"] as? String {
                    urlResource = urlString
                    mediaType = MediaType(rawValue: rawMediaType)
                }
        }
        loadAttachment(forMediaType: mediaType, withUrlString: urlResource, completionHandler: { attachment in
            if let attachment = attachment {
                bestAttemptContent.attachments = [attachment]
            }
            contentHandler(bestAttemptContent)
        })
    }
}
    
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

fileprivate extension UNNotificationAttachment {
    static func create(fromMedia media: Media) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let fileIdentifier = "\(media.fileIdentifier).\(media.fileExt)"
            let fileURL = tmpSubFolderURL.appendingPathComponent(fileIdentifier)
            
            guard let data = media.mediaData else {
                return nil
            }
            
            try data.write(to: fileURL)
            return self.create(fileIdentifier: fileIdentifier, fileUrl: fileURL, options: media.attachmentOptions)
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
    
    static func create(fileIdentifier: String, fileUrl: URL, options: [String : Any]? = nil) -> UNNotificationAttachment? {
        let attachment = try? UNNotificationAttachment(identifier: fileIdentifier, url: fileUrl, options: options)
        return attachment
    }
}

private func resourceURL(forUrlString urlString: String) -> URL? {
    return URL(string: urlString)
}

fileprivate func loadAttachment(forMediaType mediaType: MediaType?, withUrlString urlString: String?, completionHandler: ((UNNotificationAttachment?) -> Void)) {
    guard let mediaType = mediaType, let urlString = urlString else { return }
    guard let url = resourceURL(forUrlString: urlString) else {
        completionHandler(nil)
        return
    }
    
    do {
        let data = try Data(contentsOf: url)
        let media = Media(forMediaType: mediaType, withData: data, fileExtension: url.pathExtension)
        if let attachment = UNNotificationAttachment.create(fromMedia: media) {
            completionHandler(attachment)
            return
        }
        completionHandler(nil)
    } catch {
        print("error " + error.localizedDescription)
        completionHandler(nil)
    }
}

