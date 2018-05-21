//
//  ReputationTooltipManager.swift
//  LetGo
//
//  Created by Isaac Roldan on 21/5/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol ReputationTooltipManager: class {
    func shouldShowTooltip() -> Bool
    func didShowTooltip()
}
