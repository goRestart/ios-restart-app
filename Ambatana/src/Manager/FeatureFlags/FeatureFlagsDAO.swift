//
//  FeatureFlagsDAO.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/06/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

protocol FeatureFlagsDAO {
    func retrieveWebsocketChatEnabled() -> Bool?
    func retrieveTimeoutForRequests() -> TimeInterval?

    func save(websocketChatEnabled: Bool)
    func save(timeoutForRequests: TimeInterval)
}
