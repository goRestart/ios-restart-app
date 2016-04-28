//
//  NotificationsApiDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo

class NotificationsApiDataSource: NotificationsDataSource {

    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    
    // MARK: - Actions

    func index(completion: NotificationsDataSourceCompletion?) {
        let request = NotificationsRouter.Index
        apiClient.request(request, decoder: NotificationsApiDataSource.decoderArray, completion: completion)
    }

    func markAllAsRead(completion: NotificationsDataSourceEmptyCompletion?) {
        let request = NotificationsRouter.Patch(params: ["action":"mark-all-as-read"])
        apiClient.request(request, completion: completion)
    }

    func markAsRead(notificationIds: [String], completion: NotificationsDataSourceEmptyCompletion?) {
        let request = NotificationsRouter.Patch(params: ["action":"mark-as-read", "ids" : notificationIds])
        apiClient.request(request, completion: completion)
    }


    // MARK: - Decoders

    private static func decoderArray(object: AnyObject) -> [Notification]? {
        //If any notification object fails we don't want the entire list fail -> filteredDecode
        guard let notifications = Array<LGNotification>.filteredDecode(JSON(object)).value else { return nil }
        return notifications.map{ $0 }
    }
}
