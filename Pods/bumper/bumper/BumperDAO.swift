//
//  BumperDAO.swift
//  Pods
//
//  Created by Eli Kohen on 22/09/16.
//
//

import Foundation

protocol BumperDAO {
    func setBool(_ value: Bool, forKey defaultName: String)
    func boolForKey(_ defaultName: String) -> Bool
    func stringForKey(_ defaultName: String) -> String?
    func setObject(_ value: Any?, forKey defaultName: String)
}
