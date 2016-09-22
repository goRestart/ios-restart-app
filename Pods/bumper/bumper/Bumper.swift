//
//  Bumper.swift
//  Pods
//
//  Created by Eli Kohen on 21/09/16.
//  Copyright © 2016 Letgo. All rights reserved.
//

import Foundation

public class Bumper {

    // MARK: - Public static

    public static var enabled: Bool {
        return Bumper.sharedInstance.enabled
    }

    public static func initialize(bumperFlags: [BumperFlag.Type]) {
        Bumper.sharedInstance.initialize(bumperFlags)
    }

    public static func valueForKey(key: String) -> String? {
        return Bumper.sharedInstance.valueForKey(key)
    }

    // MARK: - Internal

    static let sharedInstance: Bumper = Bumper(bumperDAO: NSUserDefaults.standardUserDefaults())

    private static let bumperEnabledKey = "bumper_enabled"
    private static let bumperPrefix = "bumper_"

    var enabled: Bool = false {
        didSet {
            bumperDAO.setBool(enabled, forKey: Bumper.bumperEnabledKey)
            bumperDAO.synchronize()
        }
    }
    private var cache = [String: String]()
    private var flags: [BumperFlag.Type] = []

    var bumperViewData: [BumperViewData] {
        return flags.flatMap { flagType in
            let value = valueForKey(flagType.key) ?? flagType.defaultValue
            return BumperViewData(key: flagType.key, description: flagType.description, value: value, options: flagType.values)
        }
    }

    private let bumperDAO: BumperDAO

    init(bumperDAO: BumperDAO) {
        self.bumperDAO = bumperDAO
    }

    func initialize(bumperFlags: [BumperFlag.Type]) {
        enabled = bumperDAO.boolForKey(Bumper.bumperEnabledKey)

        cache.removeAll()
        flags = bumperFlags
        flags.forEach({
            guard let value = bumperDAO.stringForKey(Bumper.bumperPrefix + $0.key) else { return }
            cache[$0.key] = value
        })
    }

    func valueForKey(key: String) -> String? {
        return cache[key]
    }

    func setValueForKey(key: String, value: String) {
        cache[key] = value
        bumperDAO.setObject(value, forKey: Bumper.bumperPrefix + key)
        bumperDAO.synchronize()
    }
}

extension NSUserDefaults: BumperDAO {}
