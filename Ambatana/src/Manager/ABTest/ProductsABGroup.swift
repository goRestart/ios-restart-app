import Foundation

struct ProductsABGroup: ABGroupType {

    private struct Keys {
        static let simplifiedChatButton = "20181003SimplifiedChatButton"
        static let deckItemPage = "20180704DeckItemPage"
        static let frictionlessShare = "20180716FrictionlessShare"
        static let freePostingTurkey = "20180817FreePostingTurkey"
        static let bulkPosting = "20180726BulkPosting"
        static let makeAnOfferButton = "20180904MakeAnOfferButton"
    }

    let simplifiedChatButton: LeanplumABVariable<Int>
    let deckItemPage: LeanplumABVariable<Int>
    let frictionlessShare: LeanplumABVariable<Int>
    let turkeyFreePosting: LeanplumABVariable<Int>
    let bulkPosting: LeanplumABVariable<Int>
    let makeAnOfferButton: LeanplumABVariable<Int>

    let group: ABGroup = .products
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(simplifiedChatButton: LeanplumABVariable<Int>,
         deckItemPage: LeanplumABVariable<Int>,
         frictionlessShare: LeanplumABVariable<Int>,
         turkeyFreePosting: LeanplumABVariable<Int>,
         bulkPosting:  LeanplumABVariable<Int>,
         makeAnOfferButton: LeanplumABVariable<Int>) {
        self.simplifiedChatButton = simplifiedChatButton
        self.deckItemPage = deckItemPage
        self.frictionlessShare = frictionlessShare
        self.turkeyFreePosting = turkeyFreePosting
        self.bulkPosting = bulkPosting
        self.makeAnOfferButton = makeAnOfferButton
        intVariables.append(contentsOf: [simplifiedChatButton,
                                         deckItemPage,
                                         frictionlessShare,
                                         turkeyFreePosting,
                                            bulkPosting,
                                         makeAnOfferButton])
    }

    static func make() -> ProductsABGroup {
        return ProductsABGroup(simplifiedChatButton: .makeInt(key: Keys.simplifiedChatButton,
                                                              defaultValue: 0,
                                                              groupType: .products),
                               deckItemPage: .makeInt(key: Keys.deckItemPage,
                                                      defaultValue: 0,
                                                      groupType: .products),
                               frictionlessShare: .makeInt(key: Keys.frictionlessShare,
                                                           defaultValue: 0,
                                                           groupType: .products),
                               turkeyFreePosting: .makeInt(key: Keys.freePostingTurkey,
                                                           defaultValue: 0,
                                                           groupType: .products),
                               bulkPosting: .makeInt(key: Keys.bulkPosting,
                                                      defaultValue: 0,
                                                           groupType: .products),
                               makeAnOfferButton: .makeInt(key: Keys.makeAnOfferButton,
                                                           defaultValue: 0,
                                                           groupType: .products))
    }
}
