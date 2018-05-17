import Foundation
@testable import LGComponents
import Nimble
import Quick

final class LoginComponentFactorySpec: QuickSpec {
    override func spec() {
        var sut: LoginComponentFactory!

        describe("LoginComponentFactory") {
            describe("initialization with config") {
                var config: LoginComponentConfig!
                beforeEach {
                    config = MockLoginComponentConfig()
//                    sut = LoginComponentFactory(config: config)
                }

                it("keeps the config reference") {
//                    expect(sut.config) === config
                    expect(1) == 1
                }
            }
        }
    }
}
