//
//  ConfigManager.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

protocol ConfigManager {
    var updateTimeout: Double { get }
    var shouldForceUpdate: Bool { get }
    func updateWithCompletion(_ completion: (() -> Void)?)
}
