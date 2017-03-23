//
//  ChatViewModelSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble


class ChatViewModelSpec: BaseViewModelSpec {
    override func spec() {
        
        fdescribe("ChatViewModelSpec") {
            
            var sut: ChatViewModel!
            var conversation: MockChatConversation!
            var myUserRepository: MockMyUserRepository!
            var chatRepository: MockChatRepository!
            var productRepository: MockProductRepository!
            var userRepository: MockUserRepository!
            var stickersRepository: MockStickersRepository!
            var tracker: MockTracker!
            var configManager: MockConfigManager!
            var sessionManager: MockSessionManager!
            var keyValueStorage: KeyValueStorage!
            var featureFlags: MockFeatureFlags!
            var source: EventParameterTypePage!
            var pushPermissionManager: MockPushPermissionsManager!
            var ratingManager: MockRatingManager!
           
            
            
            beforeEach {
                
                conversation = MockChatConversation.makeMock()
                myUserRepository = MockMyUserRepository()
                chatRepository = MockChatRepository()
                productRepository = MockProductRepository()
                userRepository = MockUserRepository()
                stickersRepository  = MockStickersRepository()
                tracker = MockTracker()
                configManager = MockConfigManager()
                sessionManager = MockSessionManager()
                keyValueStorage = KeyValueStorage()
                featureFlags = MockFeatureFlags()
                source = .chat
                pushPermissionManager = MockPushPermissionsManager()
                ratingManager = MockRatingManager()
                
                sut = ChatViewModel(conversation: conversation, myUserRepository: myUserRepository,
                chatRepository: chatRepository, productRepository: productRepository,
                userRepository: userRepository, stickersRepository: stickersRepository,
                tracker: tracker, configManager: configManager, sessionManager: sessionManager,
                keyValueStorage: keyValueStorage, navigator: nil, featureFlags: featureFlags,
                source: source, ratingManager: ratingManager, pushPermissionsManager: pushPermissionManager)
            }
            context("Initialization") {
              
            }
        }
    }
}
