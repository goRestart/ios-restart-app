//
//  NotificationService.swift
//  LGPushNotification
//
//  Created by Juan Iglesias on 16/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//



import UIKit
import UserNotifications
import MobileCoreServices

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            var urlResource: String?
            
            // Check if it is a leanplum notification
            if let leanplumURL = request.content.userInfo["LP_URL"] as? String {
                urlResource = leanplumURL
            } else if let notificationData = request.content.userInfo["aps"] as? [String : Any], let notiData = notificationData["data"] as? [String : String] {
                if let urlString = notiData["attachment-url"] {
                    urlResource = urlString
                }
            }
            loadAttachment(withUrlString: urlResource, completionHandler: { attachment in
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
        guard let fileExtension = media.fileExt else { return nil }
        guard let data = media.mediaData else { return nil }
        
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)

        try? fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
        let fileIdentifier = "\(media.fileIdentifier).\(fileExtension)"
        let fileURL = tmpSubFolderURL.appendingPathComponent(fileIdentifier)
        
        try? data.write(to: fileURL)
        return self.create(fileIdentifier: fileIdentifier, fileUrl: fileURL, options: media.attachmentOptions)

    }
    
    static func create(fileIdentifier: String, fileUrl: URL, options: [String : Any]? = nil) -> UNNotificationAttachment? {
        let attachment = try? UNNotificationAttachment(identifier: fileIdentifier, url: fileUrl, options: options)
        return attachment
    }
}

private func resourceURL(forUrlString urlString: String) -> URL? {
    return URL(string: urlString)
}

fileprivate func loadAttachment(withUrlString urlString: String?, completionHandler: ((UNNotificationAttachment?) -> Void)) {
    guard let urlString = urlString, let url = resourceURL(forUrlString: urlString) else {
        completionHandler(nil)
        return
    }
    
    if let data = try? Data(contentsOf: url) {
        let media = Media(withData: data, fileExtension: url.pathExtension)
        if let attachment = UNNotificationAttachment.create(fromMedia: media) {
            completionHandler(attachment)
            return
        }
    }
    completionHandler(nil)
}

