//
//  VersionCheckerSpec.swift
//  LetGo
//
//  Created by Dídac on 05/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble

class VersionCheckerSpec: QuickSpec {
    override func spec() {
        var sut: VersionChecker!

        beforeEach {
            sut = VersionChecker(appVersion: MockAppVersion(version: "0.0.0"), lastAppVersion: "0.0.0")
        }
        describe("check version change") {
            it("major changed") {
                sut = VersionChecker(appVersion: MockAppVersion(version: "2.1.1"), lastAppVersion: "1.1.1")
                expect(sut.versionChange) == VersionChange.Major
            }
            it("minor changed") {
                sut = VersionChecker(appVersion: MockAppVersion(version: "1.2.1"), lastAppVersion: "1.1.1")
                expect(sut.versionChange) == VersionChange.Minor
            }
            it("patch changed") {
                sut = VersionChecker(appVersion: MockAppVersion(version: "1.1.2"), lastAppVersion: "1.1.1")
                expect(sut.versionChange) == VersionChange.Patch
            }
            it("no changes") {
                sut = VersionChecker(appVersion: MockAppVersion(version: "1.1.1"), lastAppVersion: "1.1.1")
                expect(sut.versionChange) == VersionChange.None
            }
            it("weird current version") {
                sut = VersionChecker(appVersion: MockAppVersion(version: "1.1"), lastAppVersion: "1.1.0")
                expect(sut.versionChange) == VersionChange.None
            }
            it("weird last version") {
                sut = VersionChecker(appVersion: MockAppVersion(version: "1.1.1"), lastAppVersion: "1.1")
                expect(sut.versionChange) == VersionChange.None
            }
        }
    }
}