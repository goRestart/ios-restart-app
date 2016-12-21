//
//  MockInstallationRepository.swift
//  LetGo
//
//  Created by Eli Kohen on 15/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

class MockInstallationRepository: InstallationRepository {

    var installation: Installation? {
        return installationVar.value
    }
    var rx_installation: Observable<Installation?> {
        return installationVar.asObservable()
    }

    let installationVar = Variable<Installation?>(nil)
    var installationResult: InstallationResult?

    func updatePushToken(token: String, completion: InstallationCompletion?) {
        guard let result = installationResult else { return }
        completion?(result)
    }
}
