//
//  BumperDAO.swift
//  Pods
//
//  Created by Eli Kohen on 22/09/16.
//
//

import Foundation

protocol BumperDAO {
    func set(_ value: Bool, forKey defaultName: String)
    func bool(forKey defaultName: String) -> Bool
    func string(forKey defaultName: String) -> String?
    func set(_ value: Any?, forKey defaultName: String)
}
