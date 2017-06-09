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
    var editLocationBubble: EditLocationBubble?
    
    init() {
        websocketChatEnabled = Bool?.makeRandom()
        editLocationBubble = EditLocationBubble.enumValues.random()
    }
    
    func retrieveWebsocketChatEnabled() -> Bool? {
        return websocketChatEnabled
    }
    
    func save(websocketChatEnabled: Bool) {
        self.websocketChatEnabled = websocketChatEnabled
    }
    
    func retrieveEditLocationBubble() -> EditLocationBubble? {
        return editLocationBubble
    }
    
    func save(editLocationBubble: EditLocationBubble) {
        self.editLocationBubble = editLocationBubble
    }
}
