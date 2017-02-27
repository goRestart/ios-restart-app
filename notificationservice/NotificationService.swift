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
}


fileprivate func loadAttachment(withUrlString urlString: String?, completionHandler: @escaping ((UNNotificationAttachment?) -> Void)) {
    guard let urlString = urlString,
        let url = URL(string: urlString) else {
            completionHandler(nil)
        return
    }
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    
    session.downloadTask(with: url, completionHandler: { (temporaryLocation: URL?, _ response: URLResponse?, _ error: Error?) -> Void in
        if error != nil {
            print("Error with downloading rich push: \(error?.localizedDescription)")
            completionHandler(nil)
            return
        }
        guard var temporalyDirectoryURL = temporaryLocation else {
            completionHandler(nil)
            return
        }
        let pathExtensionFromURL = url.pathExtension
        let pathExtensionFromResponse = determineType(response?.mimeType)
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
        
        let fileName: String = temporalyDirectoryURL.lastPathComponent + pathExtension
        do {
            let fileManager = FileManager.default
            temporalyDirectoryURL.deleteLastPathComponent()
            let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(temporalyDirectoryURL.lastPathComponent, isDirectory: true)
            
            
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let fileURL = tmpSubFolderURL.appendingPathComponent(fileName)
            
            if let data = try? Data(contentsOf: url) {
                try? data.write(to: fileURL)
            }
            let attachment = try UNNotificationAttachment(identifier: "", url: fileURL, options: nil)
            completionHandler(attachment)
        }
        catch let error {
            completionHandler(nil)
            print(error)
        }
    }).resume()
}


func determineType(_ fileType: String?) -> String {
    // Determines the file type of the attachment to append to NSURL.
    if (fileType == "image/jpeg") {
        return ".jpg"
    }
    if (fileType == "image/gif") {
        return ".gif"
    }
    if (fileType == "image/png") {
        return ".png"
    }
    else {
        return ""
    }
}
