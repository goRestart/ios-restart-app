//
//  CrashManagerSpec.swift
//  LetGo
//
//  Created by Dídac on 05/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

class CrashManagerSpec: QuickSpec {
    override func spec() {
        var sut: CrashManager!

        describe("initialization") {
            context("no crash with no version change") {
                beforeEach {
                    sut = CrashManager(appCrashed: false, versionChange: .none)
                }
                it("indicates that crash flags shouldn't be resetted") {
                    expect(sut.shouldResetCrashFlags) == false
                }
            }
            context("no crash with patch version change") {
                beforeEach {
                    sut = CrashManager(appCrashed: false, versionChange: .patch)
                }
                it("indicates that crash flags should be resetted") {
                    expect(sut.shouldResetCrashFlags) == true
                }
            }
            context("no crash with minor version change") {
                beforeEach {
                    sut = CrashManager(appCrashed: false, versionChange: .minor)
                }
                it("indicates that crash flags should be resetted") {
                    expect(sut.shouldResetCrashFlags) == true
                }
            }
            context("no crash with major version change") {
                beforeEach {
                    sut = CrashManager(appCrashed: false, versionChange: .major)
                }
                it("indicates that crash flags should be resetted") {
                    expect(sut.shouldResetCrashFlags) == true
                }
            }
            context("crashed with no version change") {
                beforeEach {
                    sut = CrashManager(appCrashed: true, versionChange: .none)
                }
                it("indicates that crash flags shouldn't be resetted") {
                    expect(sut.shouldResetCrashFlags) == false
                }
            }
            context("crashed with patch version change") {
                beforeEach {
                    sut = CrashManager(appCrashed: true, versionChange: .patch)
                }
                it("indicates that crash flags should be resetted") {
                    expect(sut.shouldResetCrashFlags) == true
                }
            }
            context("crashed with minor version change") {
                beforeEach {
                    sut = CrashManager(appCrashed: true, versionChange: .minor)
                }
                it("indicates that crash flags should be resetted") {
                    expect(sut.shouldResetCrashFlags) == true
                }
            }
            context("crashed with major version change") {
                beforeEach {
                    sut = CrashManager(appCrashed: true, versionChange: .major)
                }
                it("indicates that crash flags should be resetted") {
                    expect(sut.shouldResetCrashFlags) == true
                }
            }
        }
    }
}
