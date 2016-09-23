//
//  BumperDAO.swift
//  Pods
//
//  Created by Eli Kohen on 22/09/16.
//
//

import Foundation

protocol BumperDAO {
    func setBool(value: Bool, forKey defaultName: String)
    func boolForKey(defaultName: String) -> Bool
    func stringForKey(defaultName: String) -> String?
    func setObject(value: AnyObject?, forKey defaultName: String)
}
