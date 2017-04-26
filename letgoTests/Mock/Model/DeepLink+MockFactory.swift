//
//  DeepLink+MockFactory.swift
//  LetGo
//
//  Created by Eli Kohen on 20/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit

extension DeepLink: MockFactory {
    public static func makeMock() -> DeepLink {
        return DeepLink(action: .conversations,
                        origin: .push(appActive: false, alert: String.makeRandom()),
                        campaign: String?.makeRandom(),
                        medium: String?.makeRandom(),
                        source: .push,
                        cardActionParameter: String?.makeRandom())
    }

    public static func makeChatMock() -> DeepLink {
        return DeepLink(action: .conversations,
                        origin: .push(appActive: false, alert: String.makeRandom()),
                        campaign: String?.makeRandom(),
                        medium: String?.makeRandom(),
                        source: .push,
                        cardActionParameter: String?.makeRandom())
    }
}
