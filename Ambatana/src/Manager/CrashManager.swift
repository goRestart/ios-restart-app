//
//  CrashManager.swift
//  LetGo
//
//  Created by Dídac on 04/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class CrashManager {

    static var appCrashed: Bool {
        return UserDefaultsManager.sharedInstance.loadAppCrashed()
    }


    // MARK: - Lifecycle

    init(versionChange: VersionChange) {
        switch versionChange {
        case .Major, .Minor, .Patch:
            resetCrashFlags()
        case .None:
            break
        }
        self.start()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    private func start() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CrashManager.onAppDidGoBackground(_:)), name: UIApplicationDidEnterBackgroundNotification , object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CrashManager.onAppDidBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification , object: nil)

        guard !UserDefaultsManager.sharedInstance.loadAppCrashed() else { return }
        if !UserDefaultsManager.sharedInstance.loadBackgroundSuccessfully() {
            UserDefaultsManager.sharedInstance.saveAppCrashed()
        }
        UserDefaultsManager.sharedInstance.saveBackgroundSuccessfully(false)
    }


    // MARK: - Private Methods

    private func resetCrashFlags() {
        UserDefaultsManager.sharedInstance.deleteAppCrashed()
        UserDefaultsManager.sharedInstance.saveBackgroundSuccessfully(true)
    }

    dynamic func onAppDidGoBackground(notification: NSNotification) {
        UserDefaultsManager.sharedInstance.saveBackgroundSuccessfully(true)
    }

    dynamic func onAppDidBecomeActive(notification: NSNotification) {
        UserDefaultsManager.sharedInstance.saveBackgroundSuccessfully(false)
    }
}
