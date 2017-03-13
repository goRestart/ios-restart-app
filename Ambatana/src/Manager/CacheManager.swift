//
//  CacheManager.swift
//  LetGo
//
//  Created by Eli Kohen on 13/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

protocol CacheManager {
    func cleanIfNeeded()
}

class LGCacheManager: CacheManager {

    private static let settingsKey = "cleanup_cache"

    private let booleanDao: BooleanDao
    private let fileManager: FileManager

    convenience init() {
        self.init(booleanDao: UserDefaults.standard,
                  fileManager: FileManager.default)
    }

    init(booleanDao: BooleanDao, fileManager: FileManager) {
        self.booleanDao = booleanDao
        self.fileManager = fileManager
    }

    func cleanIfNeeded() {
        let shouldClean = booleanDao.bool(forKey: LGCacheManager.settingsKey)
        guard shouldClean else { return }
        clearCacheDir()
        clearTmpDir()
        booleanDao.set(false, forKey: LGCacheManager.settingsKey)
    }

    private func clearCacheDir() {
        guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return }
        let cacheFileUrl = URL(fileURLWithPath: cachePath, isDirectory: true)
        removeFilesIn(dirURL: cacheFileUrl)
    }

    private func clearTmpDir() {
        let tempDirUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        removeFilesIn(dirURL: tempDirUrl)
    }

    private func removeFilesIn(dirURL: URL) {
        guard let filesInDir = try? fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil, options: []) else { return }
        filesInDir.forEach { [weak self] in
            try? self?.fileManager.removeItem(at: $0)
        }
    }
}
