import Foundation
import Quick
import Nimble
@testable import LetGoGodMode

final class ABTestsSpec: QuickSpec {

    override func spec() {
        var syncer: LeamplumSyncerCounter!
        var uniqueSyncer: LeamplumSyncerCounter!

        var sut: ABTests!

        var legacy: LegacyABGroup!
        var realEstate: RealEstateABGroup!
        var verticals: VerticalsABGroup!
        var retention: RetentionABGroup!
        var money: MoneyABGroup!
        var chat: ChatABGroup!
        var core: CoreABGroup!
        var users: UsersABGroup!
        var discovery: DiscoveryABGroup!
        var products: ProductsABGroup!

        afterEach { syncer.clear() }

        describe("ABTests") {
            beforeEach {
                syncer = LeamplumSyncerCounter()
                sut = ABTests(syncer: syncer)

                legacy = LegacyABGroup.make()
                realEstate = RealEstateABGroup.make()
                verticals = VerticalsABGroup.make()
                core = CoreABGroup.make()
                chat = ChatABGroup.make()
                money = MoneyABGroup.make()
                retention = RetentionABGroup.make()
                users = UsersABGroup.make()
                discovery = DiscoveryABGroup.make()
                products = ProductsABGroup.make()
            }

            context("registering all the variables") {
                beforeEach {
                    sut.registerVariables()
                }
                it("registers all the variables") {
                    expect(syncer.syncedCount) == 64
                }
            }
             context("registering all the variables") {
                beforeEach {
                    sut.registerVariables()
                    uniqueSyncer = LeamplumSyncerCounter()

                    let abGroups: [ABGroupType] = [legacy, realEstate, verticals, retention, core, chat, money, users, products, discovery]
                    abGroups.forEach {
                        uniqueSyncer.sync(variables: Array(Set($0.intVariables)))
                        uniqueSyncer.sync(variables: Array(Set($0.boolVariables)))
                        uniqueSyncer.sync(variables: Array(Set($0.stringVariables)))
                        uniqueSyncer.sync(variables: Array(Set($0.floatVariables)))
                    }
                }
                it("the registered variables are unique") {
                    expect(syncer.syncedCount) == uniqueSyncer.syncedCount
                }
            }
            
            context("registering all the discovery variables") {
                it("the discovery int variable registered are 3") {
                    expect(discovery.intVariables.count) == 3
                }
                
                it("the discovery bool variable registered are 0") {
                    expect(discovery.boolVariables.count) == 0
                }
                
                it("the discovery string variable registered are 0") {
                    expect(discovery.stringVariables.count) == 0
                }
                
                it("the discovery float variable registered are 0") {
                    expect(discovery.floatVariables.count) == 0
                }
            }
            
            context("manually registering all the discovery variables") {
                beforeEach {
                    syncer.sync(variables: discovery.intVariables)
                    syncer.sync(variables: discovery.boolVariables)
                    syncer.sync(variables: discovery.stringVariables)
                    syncer.sync(variables: discovery.floatVariables)
                }
                it("the variables registered are 3") {
                    expect(syncer.syncedCount) == 3
                }
            }

            context("registering all the  legacy variables") {
                it("the legacy int variables registered are 4") {
                    expect(legacy.intVariables.count) == 4
                }

                it("the legacy bool variables registered are 4") {
                    expect(legacy.boolVariables.count) == 4
                }

                it("the legacy string variables registered are 0") {
                    expect(legacy.stringVariables.count) == 0
                }

                it("the legacy float variables registered are 0") {
                    expect(legacy.floatVariables.count) == 0
                }
            }
            
            context("manually registering all the legacy variables") {
                beforeEach {
                    syncer.sync(variables: legacy.intVariables)
                    syncer.sync(variables: legacy.boolVariables)
                    syncer.sync(variables: legacy.stringVariables)
                    syncer.sync(variables: legacy.floatVariables)
                }
                it("the variables registered are 8") {
                    expect(syncer.syncedCount) == 8
                }
            }
            
            context("registering all the real estate variables") {
                it("the realestate int variable registered is 1") {
                    expect(realEstate.intVariables.count) == 1
                }
                
                it("the realestate bool variable registered are 0") {
                    expect(realEstate.boolVariables.count) == 0
                }
                
                it("the realestate string variable registered are 0") {
                    expect(realEstate.stringVariables.count) == 0
                }
                
                it("the realestate float variable registered are 0") {
                    expect(realEstate.floatVariables.count) == 0
                }
            }

            context("manually registering all the real estate variables") {
                beforeEach {
                    syncer.sync(variables: realEstate.intVariables)
                    syncer.sync(variables: realEstate.boolVariables)
                    syncer.sync(variables: realEstate.stringVariables)
                    syncer.sync(variables: realEstate.floatVariables)
                }
                it("the variables registered is 1") {
                    expect(syncer.syncedCount) == 1
                }
            }
            
            context("manually registering all the verticals variables") {
                beforeEach {
                    syncer.sync(variables: verticals.intVariables)
                    syncer.sync(variables: verticals.boolVariables)
                    syncer.sync(variables: verticals.stringVariables)
                    syncer.sync(variables: verticals.floatVariables)
                }
                it("the variables registered are 7") {
                    expect(syncer.syncedCount) == 7
                }
            }

            context("registering all the retention variables") {
                it("the retention int variable registered are 9") {
                    expect(retention.intVariables.count) == 9
                }

                it("the retention bool variable registered are 0") {
                    expect(retention.boolVariables.count) == 0
                }

                it("the retention string variable registered are 0") {
                    expect(retention.stringVariables.count) == 0
                }

                it("the retention float variable registered are 0") {
                    expect(retention.floatVariables.count) == 0
                }
            }

            context("manually registering all the retention variables") {
                beforeEach {
                    syncer.sync(variables: retention.intVariables)
                    syncer.sync(variables: retention.boolVariables)
                    syncer.sync(variables: retention.stringVariables)
                    syncer.sync(variables: retention.floatVariables)
                }

                it("the variables registered are 9") {
                    expect(syncer.syncedCount) == 9
                }
            }

            context("registering all the money variables") {
                it("the money int variable registered are 11") {
                    expect(money.intVariables.count) == 11
                }

                it("the money bool variable registered are 2") {
                    expect(money.boolVariables.count) == 2
                }

                it("the money string variable registered are 0") {
                    expect(money.stringVariables.count) == 0
                }

                it("the money float variable registered are 0") {
                    expect(money.floatVariables.count) == 0
                }
            }

            context("manually registering all the money variables") {
                beforeEach {
                    syncer.sync(variables: money.intVariables)
                    syncer.sync(variables: money.boolVariables)
                    syncer.sync(variables: money.stringVariables)
                    syncer.sync(variables: money.floatVariables)
                }
                it("the variables registered are 13") {
                    expect(syncer.syncedCount) == 13
                }
            }

            context("registering all the chat variables") {
                it("the chat int variable registered is 5") {
                    expect(chat.intVariables.count) == 5
                }

                it("the chat bool variable registered are 4") {
                    expect(chat.boolVariables.count) == 4
                }

                it("the chat string variable registered are 0") {
                    expect(chat.stringVariables.count) == 0
                }

                it("the chat float variable registered are 0") {
                    expect(chat.floatVariables.count) == 0
                }
            }

            context("manually registering all the chat variables") {
                beforeEach {
                    syncer.sync(variables: chat.intVariables)
                    syncer.sync(variables: chat.boolVariables)
                    syncer.sync(variables: chat.stringVariables)
                    syncer.sync(variables: chat.floatVariables)
                }
                it("the variables registered are 9") {
                    expect(syncer.syncedCount) == 9
                }
            }

            context("registering all the core variables") {
                it("the core int variable registered are 3") {
                    expect(core.intVariables.count) == 3
                }

                it("the core bool variable registered are 0") {
                    expect(core.boolVariables.count) == 0
                }

                it("the core string variable registered are 0") {
                    expect(core.stringVariables.count) == 0
                }

                it("the core float variable registered are 0") {
                    expect(core.floatVariables.count) == 0
                }
            }

            context("manually registering all the core variables") {
                beforeEach {
                    syncer.sync(variables: core.intVariables)
                    syncer.sync(variables: core.boolVariables)
                    syncer.sync(variables: core.stringVariables)
                    syncer.sync(variables: core.floatVariables)
                }
                it("the variables registered are 3") {
                    expect(syncer.syncedCount) == 3
                }
            }

            context("registering all users variables") {
                it("the users int variable registered are 5") {
                    expect(users.intVariables.count) == 5
                }

                it("the users bool variable registered are 0") {
                    expect(users.boolVariables.count) == 0
                }

                it("the users string variable registered are 0") {
                    expect(users.stringVariables.count) == 0
                }

                it("the users float variable registered are 0") {
                    expect(users.floatVariables.count) == 0
                }
            }

            context("manually registering all the users variables") {
                beforeEach {
                    syncer.sync(variables: users.intVariables)
                    syncer.sync(variables: users.boolVariables)
                    syncer.sync(variables: users.stringVariables)
                    syncer.sync(variables: users.floatVariables)
                }
                it("the variables registered are 5") {
                    expect(syncer.syncedCount) == 5
                }
            }

            context("registering all products variables") {
                it("the products int variable registered are 5") {
                    expect(products.intVariables.count) == 6
                }

                it("the products bool variable registered are 0") {
                    expect(products.boolVariables.count) == 0
                }

                it("the products string variable registered are 0") {
                    expect(products.stringVariables.count) == 0
                }

                it("the products float variable registered are 0") {
                    expect(products.floatVariables.count) == 0
                }
            }

            context("manually registering all the products variables") {
                beforeEach {
                    syncer.sync(variables: products.intVariables)
                    syncer.sync(variables: products.boolVariables)
                    syncer.sync(variables: products.stringVariables)
                    syncer.sync(variables: products.floatVariables)
                }
                it("the variables registered are 5") {
                    expect(syncer.syncedCount) == 6
                }
            }
        }
    }
}

private class LeamplumSyncerCounter: LeamplumSyncerType {
    var syncedCount: Int = 0
    var trackingCount: Int = 0

    func clear() {
        syncedCount = 0
        trackingCount = 0
    }

    func sync(variables: [ABRegistrable]) {
        syncedCount += variables.count
    }
    func trackingData(variables: [ABTrackable]) -> [(String, ABGroup)] {
        trackingCount += variables.count
        return variables.map { _ in return ("I don't care", ABGroup.core) }
    }
}


