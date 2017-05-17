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
    var didRegisterUserNotificationSettingsCalled: Bool!
    
    override func spec() {
        var sut: PushManager!
        
        var application: MockApplication!
        var pushPermissionsManager: MockPushPermissionsManager!
        var installationRepository: MyMockInstallationRepository!
        var deepLinksRouter: MockDeepLinksRouter!
        var notificationsManager: MockNotificationsManager!
       
        describe("PushManager") {
            beforeEach {
                self.didRegisterUserNotificationSettingsCalled = false
                
                application = MockApplication()
                pushPermissionsManager = MockPushPermissionsManager()
                installationRepository = MyMockInstallationRepository()
                installationRepository.result = Result<Installation, RepositoryError>(value: MockInstallation.makeMock())
                deepLinksRouter = MockDeepLinksRouter()
                notificationsManager = MockNotificationsManager()
                
                sut = PushManager(pushPermissionManager: pushPermissionsManager,
                                  installationRepository: installationRepository,
                                  deepLinksRouter: deepLinksRouter,
                                  notificationsManager: notificationsManager)
            }
            
            describe("app did become active") {
                context("remote notifications enabled") {
                    beforeEach {
                        application.areRemoteNotificationsEnabled = true
                        sut.applicationDidBecomeActive(application)
                    }
                    
                    it("registers the app for remote notifications") {
                        expect(application.registerForRemoteNotificationsCalled) == true
                    }
                }
                
                context("remote notifications disabled") {
                    beforeEach {
                        application.areRemoteNotificationsEnabled = false
                        sut.applicationDidBecomeActive(application)
                    }
                    
                    it("calls installation repository to update push token") {
                        expect(installationRepository.lastUpdatePushTokenCallTokenParam) == ""
                    }
                }
            }
            
            describe("app did receive remote notification") {
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
            
            describe("app did register for remote notifications with device token") {
                let deviceToken = "hello!".data(using: .utf8)!
                
                beforeEach {
                    sut.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
                }
                
                it("calls installation repository to update push token with the received one") {
                    expect(installationRepository.lastUpdatePushTokenCallTokenParam) == deviceToken.toHexString()
                }
            }
            
            describe("app did fail to register for remote notifications with error") {
                beforeEach {
                    sut.application(application, didFailToRegisterForRemoteNotificationsWithError: NSError())
                }
                
                it("calls installation repository to delete the push token") {
                    expect(installationRepository.lastUpdatePushTokenCallTokenParam) == ""
                }
            }
            
            describe("application did register user notification settings") {
                beforeEach {
                    NotificationCenter.default.addObserver(self, selector: #selector(self.didRegisterUserNotificationSettings),
                                                           name: NSNotification.Name(rawValue: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue),
                                                           object: nil)
                    
                    let settings = UIUserNotificationSettings(types: .alert, categories: nil)
                    sut.application(application, didRegisterUserNotificationSettings: settings)
                }
                
                afterEach {
                    NotificationCenter.default.removeObserver(self)
                }
                
                it("calls didRegisterUserNotificationSettingsCalled in push permission manager") {
                    expect(pushPermissionsManager.didRegisterUserNotificationSettingsCalled) == true
                }
                
                it("didRegisterUserNotificationSettingsNotificationReceived") {
                    expect(self.didRegisterUserNotificationSettingsCalled) == true
                }
            }
        }
    }
    
    dynamic func didRegisterUserNotificationSettings() {
        didRegisterUserNotificationSettingsCalled = true
    }
}


fileprivate class MyMockInstallationRepository: MockInstallationRepository {
    var lastUpdatePushTokenCallTokenParam: String?
    
    override func updatePushToken(_ token: String, completion: InstallationCompletion?) {
        lastUpdatePushTokenCallTokenParam = token
        super.updatePushToken(token, completion: completion)
    }
}
