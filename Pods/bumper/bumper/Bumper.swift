//
//  Bumper.swift
//  Pods
//
//  Created by Eli Kohen on 21/09/16.
//  Copyright © 2016 Letgo. All rights reserved.
//

import Foundation
import RxSwift

public class Bumper {

    // MARK: - Public static

    public static var enabled: Bool {
        return Bumper.sharedInstance.enabled
    }

    public static func initialize(_ bumperFeatures: [BumperFeature.Type]) {
        Bumper.sharedInstance.initialize(bumperFeatures)
    }

    public static func value(for key: String) -> String? {
        return Bumper.sharedInstance.value(for: key)
    }


    // MARK: - Internal

    static let sharedInstance: Bumper = Bumper(bumperDAO: UserDefaults.standard)

    private static let bumperEnabledKey = "bumper_enabled"
    private static let bumperPrefix = "bumper_"

    var enabled: Bool = false {
        didSet {
            bumperDAO.set(enabled, forKey: Bumper.bumperEnabledKey)
        }
    }
    private var cache = [String: String]()
    private var features: [BumperFeature.Type] = []

    var bumperViewData: [BumperViewData] {
        return features.flatMap { featureType in
            let value = self.value(for: featureType.key) ?? featureType.defaultValue
            return BumperViewData(key: featureType.key,
                                  description: featureType.description,
                                  value: value,
                                  options: featureType.values)
        }
    }

    private let bumperDAO: BumperDAO
    
    init(bumperDAO: BumperDAO) {
        self.bumperDAO = bumperDAO
    }

    func initialize(_ bumperFeatures: [BumperFeature.Type]) {
        enabled = bumperDAO.bool(forKey: Bumper.bumperEnabledKey)

        cache.removeAll()
        features = bumperFeatures
        features.forEach({
            guard let value = bumperDAO.string(forKey: Bumper.bumperPrefix + $0.key) else { return }
            cache[$0.key] = $0.values.contains(value) ? value : $0.defaultValue
        })
    }

    func update(with values: [[String: Any]]) {
        values.forEach { dict in
            guard let value = dict["value"] as? String,
                let key = dict["key"] as? String else { return }
            cache[key] = value
        }
    }

    func value(for key: String) -> String? {
        return cache[key]
    }

    func setValue(for key: String, value: String) {
        cache[key] = value
        bumperDAO.set(value, forKey: Bumper.bumperPrefix + key)
    }
}

extension Bumper {

    public static var enabledObservable: Observable<Bool> {
        return Bumper.sharedInstance.enabledObservable
    }

    public static func observeValue(for key: String) -> Observable<String?> {
        return Bumper.sharedInstance.observeValue(for: key)
    }

    var enabledObservable: Observable<Bool> {
        return bumperDAO.boolObservable(for: Bumper.bumperEnabledKey).map { $0 ?? false }
    }

    func observeValue(for key: String) -> Observable<String?> {
        return bumperDAO.stringObservable(for: Bumper.bumperPrefix + key)
    }
}

