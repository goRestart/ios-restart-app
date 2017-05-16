//
//  PushManagerSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 16/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxTest
import Result
@testable import LGCoreKit
@testable import LetGoGodMode

class PushManagerSpec: QuickSpec {
    
    override func spec() {
        var sut: PushManager!
        
        var application: Application!
        var pushPermissionsManager: MockPushPermissionsManager!
        var installationRepository: MockInstallationRepository!
        var deepLinksRouter: MockDeepLinksRouter!
        var notificationsManager: MockNotificationsManager!
       
        fdescribe("PushManager") {
            beforeEach {
                application = MockApplication()
                pushPermissionsManager = MockPushPermissionsManager()
                installationRepository = MockInstallationRepository()
                deepLinksRouter = MockDeepLinksRouter()
                notificationsManager = MockNotificationsManager()
                
                sut = PushManager(pushPermissionManager: pushPermissionsManager,
                                  installationRepository: installationRepository,
                                  deepLinksRouter: deepLinksRouter,
                                  notificationsManager: notificationsManager)
            }
            
            describe("didReceiveRemoteNotification") {
                beforeEach {
                    let notification =  [AnyHashable: Any]()
                    sut.application(application, didReceiveRemoteNotification: notification)
                }
                
                it("calls didReceiveRemoteNotification on deep links router") {
                    expect(deepLinksRouter.didReceiveRemoteNotificationCalled) == true
                }
                
                it("calls update counters on notifications manager") {
                    expect(notificationsManager.updateCountersCalled) == true
                }
            }
        }
    }
}
