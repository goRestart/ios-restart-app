//
//  CrashManagerSpec.swift
//  LetGo
//
//  Created by Dídac on 05/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble

class CrashManagerSpec: QuickSpec {
    override func spec() {
        var sut: CrashManager!

        describe("check app crash") {
            it("no crash") {
                sut = CrashManager(appCrashed: false, versionChange: .None)
                expect(CrashManager.appCrashed) == false
            }
            it("app crashed and no version change") {
                sut = CrashManager(appCrashed: true, versionChange: .None)
                expect(CrashManager.appCrashed) == true
            }
            it("app crashed and version change") {
                sut = CrashManager(appCrashed: true, versionChange: .Minor)
                expect(CrashManager.appCrashed) == false
            }
        }
    }
}
