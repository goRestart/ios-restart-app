//
//  NotificationService.swift
//  notificationservice
//
//  Created by Juan Iglesias on 17/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import UIKit
import UserNotifications

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

    fileprivate func loadAttachment(withUrlString urlString: String?, completionHandler: @escaping ((UNNotificationAttachment?) -> Void)) {
        guard let urlString = urlString,
            let url = URL(string: urlString) else {
                completionHandler(nil)
                return
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.downloadTask(with: url, completionHandler: { (temporaryLocation: URL?, _ response: URLResponse?, _ error: Error?) -> Void in
            guard error == nil else {
                completionHandler(nil)
                return
            }
            guard let temporaryDirectoryURL = temporaryLocation else {
                completionHandler(nil)
                return
            }
            let pathExtensionFromURL = url.pathExtension
            let pathExtensionFromResponse = response?.mimeType?.fileExtension ?? ""
            var pathExtension: String = ""
            
            if pathExtensionFromURL.isEmpty {
                if pathExtensionFromResponse.isEmpty {
                    completionHandler(nil)
                } else {
                    pathExtension = pathExtensionFromResponse
                }
            } else {
                pathExtension = ".\(pathExtensionFromURL)"
            }
            
            let fileName: String = String(Date().timeIntervalSince1970) + pathExtension
            do {
                let fileManager = FileManager.default
                let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
                try? fileManager.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
                let finalURL = tempDirURL.appendingPathComponent(fileName)
                try fileManager.moveItem(at: temporaryDirectoryURL, to: finalURL)
                let attachment = try UNNotificationAttachment(identifier: fileName, url: finalURL, options: nil)
                completionHandler(attachment)
            } catch {
                completionHandler(nil)
            }
        }).resume()
    }
}

extension String {
    var fileExtension: String {
        switch self {
        case "image/jpeg":
            return ".jpg"
        case "image/gif":
            return ".gif"
        case "image/png":
            return ".png"
        default:
            return ""
        }
    }
}
