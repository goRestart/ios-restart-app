//
//  MockChatWrapper.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit

class MockChatWrapper: ChatWrapper {

    var results = [ChatWrapperResult]()
    var currentResultIndex = 0

    func sendMessageForProduct(_ product: Product, type: ChatWrapperMessageType, completion: ChatWrapperCompletion?) {
        performAfterDelayWithCompletion(completion, result: results[currentResultIndex])
        currentResultIndex = currentResultIndex + 1
    }
}
