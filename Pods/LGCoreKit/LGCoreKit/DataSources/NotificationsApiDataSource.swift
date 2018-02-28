//
//  NotificationsApiDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

class NotificationsApiDataSource: NotificationsDataSource {

    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    
    // MARK: - Actions

    func index(allowEditDiscarded: Bool, completion: NotificationsDataSourceCompletion?) {
        let params: [String: Any] = allowEditDiscarded ? ["allow_edit_discarded": "1"] : [:]
        let request = NotificationsRouter.index(params: params)
        apiClient.request(request, decoder: NotificationsApiDataSource.decoderArray, completion: completion)
    }

    func unreadCount(_ completion: NotificationsDataSourceUnreadCountCompletion?) {
        let request = NotificationsRouter.unreadCount
        apiClient.request(request, decoder: NotificationsApiDataSource.unreadCountDecoder, completion: completion)
    }


    // MARK: - Decoders

    private static func decoderArray(_ object: Any) -> [NotificationModel]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        
        // Ignore notification that can't be decoded
        do {
            let ratings = try JSONDecoder().decode(FailableDecodableArray<LGNotification>.self, from: data)
            return ratings.validElements
        } catch {
            logAndReportParseError(object: object, entity: .notifications,
                                   comment: "could not parse [LGNotification]")
        }
        return nil
    }

    private static func unreadCountDecoder(_ object: Any) -> Int? {
        struct Keys {
            static let counts = "counts"
            static let modular = "modular"
        }
        guard let dict = object as? [String: Any],
            let counts = dict[Keys.counts] as? [String: Any],
            let modular = counts[Keys.modular] as? Int
            else { return nil }
        return modular
    }
}
