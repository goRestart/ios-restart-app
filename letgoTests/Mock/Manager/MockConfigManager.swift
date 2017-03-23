//
//  MockConfigManager.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


@testable import LetGoGodMode

struct MockConfigManager: ConfigManager {
    var updateTimeout: Double = 1.0
    var shouldForceUpdate: Bool = false
    var myMessagesCountForRating: Int = 10
    var otherMessagesCountForRating: Int = 10
    func updateWithCompletion(_ completion: (() -> Void)?) { }
}
