//
//  MockFeatureFlagsDAO.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/06/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode

class MockFeatureFlagsDAO: FeatureFlagsDAO {
    var websocketChatEnabled: Bool?
    var timeoutForRequests: TimeInterval?

    init() {
        websocketChatEnabled = Bool?.makeRandom()
    }
    
    func retrieveWebsocketChatEnabled() -> Bool? {
        return websocketChatEnabled
    }
    
    func save(websocketChatEnabled: Bool) {
        self.websocketChatEnabled = websocketChatEnabled
    }

    func retrieveTimeoutForRequests() -> TimeInterval? {
        return timeoutForRequests
    }

    func save(timeoutForRequests: TimeInterval) {
        self.timeoutForRequests = timeoutForRequests
    }

}
