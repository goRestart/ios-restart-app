//
//  LGFileManager.swift
//  LetGo
//
//  Created by Álvaro Murillo del Puerto on 25/4/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol FilesManager {
    func removeFile(at url: URL)
}

class LGFilesManager: FilesManager {

    func removeFile(at url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
