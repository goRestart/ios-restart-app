//
//  RatingManagerSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble

class RatingManagerSpec: QuickSpec {
    override func spec() {
        var sut: RatingManager!

        var userDefaultsManager: UserDefaultsManager!
        var crashManager: CrashManager!

        describe("Rating Manager") {
            beforeEach {
                NSUserDefaults.resetStandardUserDefaults()
                userDefaultsManager = UserDefaultsManager.sharedInstance
            }

            describe("initialization") {
//                var previousAlreadyRatedValue: Bool
//                var previousRemindMeLaterDate: NSDate?

                beforeEach {
//                    previousAlreadyRatedValue = userDefaultsManager.loadAlreadyRated()
//                    previousRemindMeLaterDate = userDefaultsManager.loadRemindMeLaterDate()
                }
                context("fresh install") {
                    beforeEach {
                        let versionChange = VersionChange.Major

                        crashManager = CrashManager(appCrashed: false, versionChange: versionChange)
                        sut = RatingManager(userDefaultsManager: userDefaultsManager, crashManager: crashManager,
                            versionChange: versionChange)

//                        userDefaultsManager.loadRemindMeLaterDate()
                        userDefaultsManager.loadRemindMeLaterDate()
                    }
                }
//                it("") {
//                    
//                }

//                userDefaults.saveAlreadyRated(false)
            }


//            context("no crash with no version change") {
//                beforeEach {
//                    sut = CrashManager(appCrashed: false, versionChange: .None)
//                }
//                it("indicates that crash flags shouldn't be resetted") {
//                    expect(sut.shouldResetCrashFlags) == false
//                }
//            }
//            context("no crash with patch version change") {
//                beforeEach {
//                    sut = CrashManager(appCrashed: false, versionChange: .Patch)
//                }
//                it("indicates that crash flags should be resetted") {
//                    expect(sut.shouldResetCrashFlags) == true
//                }
//            }
//            context("no crash with minor version change") {
//                beforeEach {
//                    sut = CrashManager(appCrashed: false, versionChange: .Minor)
//                }
//                it("indicates that crash flags should be resetted") {
//                    expect(sut.shouldResetCrashFlags) == true
//                }
//            }
//            context("no crash with major version change") {
//                beforeEach {
//                    sut = CrashManager(appCrashed: false, versionChange: .Major)
//                }
//                it("indicates that crash flags should be resetted") {
//                    expect(sut.shouldResetCrashFlags) == true
//                }
//            }
//            context("crashed with no version change") {
//                beforeEach {
//                    sut = CrashManager(appCrashed: true, versionChange: .None)
//                }
//                it("indicates that crash flags shouldn't be resetted") {
//                    expect(sut.shouldResetCrashFlags) == false
//                }
//            }
//            context("crashed with patch version change") {
//                beforeEach {
//                    sut = CrashManager(appCrashed: true, versionChange: .Patch)
//                }
//                it("indicates that crash flags should be resetted") {
//                    expect(sut.shouldResetCrashFlags) == true
//                }
//            }
//            context("crashed with minor version change") {
//                beforeEach {
//                    sut = CrashManager(appCrashed: true, versionChange: .Minor)
//                }
//                it("indicates that crash flags should be resetted") {
//                    expect(sut.shouldResetCrashFlags) == true
//                }
//            }
//            context("crashed with major version change") {
//                beforeEach {
//                    sut = CrashManager(appCrashed: true, versionChange: .Major)
//                }
//                it("indicates that crash flags should be resetted") {
//                    expect(sut.shouldResetCrashFlags) == true
//                }
//            }
        }
    }
}
