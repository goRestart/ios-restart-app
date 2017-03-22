//
//  KeychainCheckerSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 23/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble

class GodModeManagerSpec: QuickSpec {
    override func spec() {
        describe("GodModeManagerSpec") {
            var sut: GodModeManager!
            var booleanDAO: MockBooleanDAO!
            var storageCleaner: MockStorageCleaner!

            beforeEach {
                booleanDAO = MockBooleanDAO()
                storageCleaner = MockStorageCleaner()
                sut = GodModeManager(booleanDAO: booleanDAO, storageCleaner: storageCleaner, enabled: true)
            }
            describe("check keychain") {
                context("switch in settings to off") {
                    beforeEach {
                        booleanDAO.values["god_mode_cleanup_keychain"] = false
                        sut.applicationDidFinishLaunching()
                    }
                    it("doesn't call cleanup") {
                        expect(storageCleaner.calledCleanKeychain) == false
                        expect(storageCleaner.calledCleanKeyValueStorage) == false
                    }
                    it("doesn't set any ud value") {
                        expect(booleanDAO.lastSetValue).to(beNil())
                    }
                }
                context("switch in settings to on") {
                    beforeEach {
                        booleanDAO.values["god_mode_cleanup_keychain"] = true
                        sut.applicationDidFinishLaunching()
                    }
                    it("calls cleanup") {
                        expect(storageCleaner.calledCleanKeychain) == true
                        expect(storageCleaner.calledCleanKeyValueStorage) == false
                    }
                    it("sets the correct ud value") {
                        expect(booleanDAO.lastSetKey) == "god_mode_cleanup_keychain"
                    }
                    it("sets the ud value to false") {
                        expect(booleanDAO.lastSetValue) == false
                    }
                }
            }
            describe("full cleanup") {
                context("switch in admin panel to off") {
                    beforeEach {
                        booleanDAO.values["god_mode_full_cleanup"] = false
                        sut.applicationDidFinishLaunching()
                    }
                    it("doesn't call cleanup") {
                        expect(storageCleaner.calledCleanKeychain) == false
                        expect(storageCleaner.calledCleanKeyValueStorage) == false
                    }
                    it("doesn't set any ud value") {
                        expect(booleanDAO.lastSetValue).to(beNil())
                    }
                }
                context("switch in admin panel to on") {
                    beforeEach {
                        booleanDAO.values["god_mode_full_cleanup"] = true
                        sut.applicationDidFinishLaunching()
                    }
                    it("calls cleanup") {
                        expect(storageCleaner.calledCleanKeychain) == true
                        expect(storageCleaner.calledCleanKeyValueStorage) == true
                    }
                }
            }
            describe("storage cleanup") {
                context("switch in admin panel to off") {
                    beforeEach {
                        booleanDAO.values["god_mode_reinstall_cleanup"] = false
                        sut.applicationDidFinishLaunching()
                    }
                    it("doesn't call cleanup") {
                        expect(storageCleaner.calledCleanKeychain) == false
                        expect(storageCleaner.calledCleanKeyValueStorage) == false
                    }
                    it("doesn't set any ud value") {
                        expect(booleanDAO.lastSetValue).to(beNil())
                    }
                }
                context("switch in admin panel to on") {
                    beforeEach {
                        booleanDAO.values["god_mode_reinstall_cleanup"] = true
                        sut.applicationDidFinishLaunching()
                    }
                    it("calls cleanup") {
                        expect(storageCleaner.calledCleanKeychain) == false
                        expect(storageCleaner.calledCleanKeyValueStorage) == true
                    }
                }
            }
        }
    }
}
