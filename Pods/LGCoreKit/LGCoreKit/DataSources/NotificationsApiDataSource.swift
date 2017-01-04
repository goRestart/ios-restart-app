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

    func index(_ completion: NotificationsDataSourceCompletion?) {
        let request = NotificationsRouter.index
        apiClient.request(request, decoder: NotificationsApiDataSource.decoderArray, completion: completion)
    }

    func unreadCount(_ completion: NotificationsDataSourceUnreadCountCompletion?) {
        let request = NotificationsRouter.unreadCount
        apiClient.request(request, decoder: NotificationsApiDataSource.unreadCountDecoder, completion: completion)
    }



    // MARK: - Decoders

    private static func decoderArray(_ object: Any) -> [NotificationModel]? {
        //If any notification object fails we don't want the entire list fail -> filteredDecode
        guard let notifications = Array<LGNotification>.filteredDecode(JSON(object)).value else { return nil }
        return notifications.map{ $0 }
    }

    private static func unreadCountDecoder(_ object: Any) -> LGUnreadNotificationsCounts? {
        let result: Decoded<LGUnreadNotificationsCounts> = JSON(object) <| "counts"
        return result.value
    }
}
