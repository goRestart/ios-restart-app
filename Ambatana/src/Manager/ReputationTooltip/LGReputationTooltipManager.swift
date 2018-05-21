//
//  LGReputationTooltipManager.swift
//  LetGo
//
//  Created by Isaac Roldan on 21/5/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class LGReputationTooltipManager: ReputationTooltipManager {

    static let sharedInstance = LGReputationTooltipManager()
    private let keyValueStorage: KeyValueStorage

    init(keyValueStorage: KeyValueStorage) {
        self.keyValueStorage = keyValueStorage
    }

    convenience init() {
        self.init(keyValueStorage: KeyValueStorage.sharedInstance)
    }

    func shouldShowTooltip() -> Bool {
        if !keyValueStorage[.reputationTooltipShown] { return true }
        guard let lastShownDate = keyValueStorage[.lastShownReputationTooltipDate] else { return true }
        return lastShownDate.isOlderThan(days: 30)
    }

    func didShowTooltip() {
        keyValueStorage[.reputationTooltipShown] = true
        keyValueStorage[.lastShownReputationTooltipDate] = Date()
    }
}
