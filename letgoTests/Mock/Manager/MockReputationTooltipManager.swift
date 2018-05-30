//
//  MockReputationTooltipManager.swift
//  letgoTests
//
//  Created by Isaac Roldan on 23/5/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Foundation

class MockReputationTooltipManager: ReputationTooltipManager {

    private var tooltipShown = false

    func shouldShowTooltip() -> Bool {
        return !tooltipShown
    }

    func didShowTooltip() {
        tooltipShown = true
    }
}
