//
//  ConfigManager.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

protocol ConfigManager {
    
    var updateTimeout: Double { get }
    var shouldForceUpdate: Bool { get }
    var myMessagesCountForRating: Int { get }
    var otherMessagesCountForRating: Int { get }
    func updateWithCompletion(_ completion: (() -> Void)?)
}
