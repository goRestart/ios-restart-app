//
//  BooleanDAO.swift
//  LetGo
//
//  Created by Eli Kohen on 14/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

protocol BooleanDAO {
    func bool(forKey defaultName: String) -> Bool
    func set(_ value: Bool, forKey defaultName: String)
}

extension UserDefaults: BooleanDAO {}
