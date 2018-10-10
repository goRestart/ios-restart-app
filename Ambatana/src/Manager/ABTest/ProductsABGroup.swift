import Foundation

struct ProductsABGroup: ABGroupType {

    private struct Keys {
        static let simplifiedChatButton = "20181003SimplifiedChatButton"
        static let deckItemPage = "20180704DeckItemPage"
        static let bulkPosting = "20180726BulkPosting"
        static let makeAnOfferButton = "20180904MakeAnOfferButton"
    }

    let simplifiedChatButton: LeanplumABVariable<Int>
    let deckItemPage: LeanplumABVariable<Int>
    let bulkPosting: LeanplumABVariable<Int>
    let makeAnOfferButton: LeanplumABVariable<Int>

    let group: ABGroup = .products
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(simplifiedChatButton: LeanplumABVariable<Int>,
         deckItemPage: LeanplumABVariable<Int>,
         bulkPosting:  LeanplumABVariable<Int>,
         makeAnOfferButton: LeanplumABVariable<Int>) {
        self.simplifiedChatButton = simplifiedChatButton
        self.deckItemPage = deckItemPage
        self.bulkPosting = bulkPosting
        self.makeAnOfferButton = makeAnOfferButton
        intVariables.append(contentsOf: [simplifiedChatButton,
                                         deckItemPage,
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
                               bulkPosting: .makeInt(key: Keys.bulkPosting,
                                                      defaultValue: 0,
                                                           groupType: .products),
                               makeAnOfferButton: .makeInt(key: Keys.makeAnOfferButton,
                                                           defaultValue: 0,
                                                           groupType: .products))
    }
}
