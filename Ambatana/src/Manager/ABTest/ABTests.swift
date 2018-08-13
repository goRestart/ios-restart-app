import RxSwift

protocol LeamplumSyncerType {
    func sync(variables: [ABRegistrable])
    func trackingData(variables: [ABTrackable]) -> [(String, ABGroup)]
}

final class LeamplumSyncer: LeamplumSyncerType {
    func sync(variables: [ABRegistrable]) {
        variables.forEach { $0.register() }
    }

    func trackingData(variables: [ABTrackable]) -> [(String, ABGroup)] {
        return mapTrackingData(variables)
    }

    private func mapTrackingData(_ array: [ABTrackable]) -> [(String, ABGroup)] { return array.map { $0.nameAndGroup } }
}

protocol ABGroupType {
    var group: ABGroup { get }
    var intVariables: [LeanplumABVariable<Int>] { get }
    var stringVariables: [LeanplumABVariable<String>] { get }
    var floatVariables: [LeanplumABVariable<Float>] { get }
    var boolVariables: [LeanplumABVariable<Bool>] { get }
}

class ABTests {
    private let syncer: LeamplumSyncerType
    let trackingData = Variable<[(String, ABGroup)]?>(nil)

    let legacy = LegacyABGroup.make()
    let realEstate = RealEstateABGroup.make()
    let verticals = VerticalsABGroup.make()
    let retention = RetentionABGroup.make()
    let money = MoneyABGroup.make()
    let chat = ChatABGroup.make()
    let core = CoreABGroup.make()
    let users = UsersABGroup.make()
    let discovery = DiscoveryABGroup.make()
    let products = ProductsABGroup.make()


    convenience init() {
        self.init(syncer: LeamplumSyncer())
    }

    init(syncer: LeamplumSyncerType) {
        self.syncer = syncer
    }

    private var intVariables: [LeanplumABVariable<Int>] {
        var result = [LeanplumABVariable<Int>]()

        result.append(contentsOf: legacy.intVariables)
        result.append(contentsOf: money.intVariables)
        result.append(contentsOf: retention.intVariables)
        result.append(contentsOf: realEstate.intVariables)
        result.append(contentsOf: verticals.intVariables)
        result.append(contentsOf: chat.intVariables)
        result.append(contentsOf: core.intVariables)
        result.append(contentsOf: users.intVariables)
        result.append(contentsOf: discovery.intVariables)
        result.append(contentsOf: products.intVariables)
        return result
    }

    private var boolVariables: [LeanplumABVariable<Bool>] {
        var result = [LeanplumABVariable<Bool>]()
        result.append(contentsOf: legacy.boolVariables)
        result.append(contentsOf: money.boolVariables)
        result.append(contentsOf: retention.boolVariables)
        result.append(contentsOf: realEstate.boolVariables)
        result.append(contentsOf: verticals.boolVariables)
        result.append(contentsOf: chat.boolVariables)
        result.append(contentsOf: core.boolVariables)
        result.append(contentsOf: users.boolVariables)
        result.append(contentsOf: discovery.boolVariables)
        result.append(contentsOf: products.boolVariables)
        return result
    }

    private var stringVariables: [LeanplumABVariable<String>] { return legacy.stringVariables }
    private var floatVariables: [LeanplumABVariable<Float>] { return [] }

    func registerVariables() {
        syncer.sync(variables: intVariables)
        syncer.sync(variables: boolVariables)
        syncer.sync(variables: floatVariables)
        syncer.sync(variables: stringVariables)
    }

    func variablesUpdated() {
        let uniquesInt = Array(Set<LeanplumABVariable<Int>>.init(intVariables))
        let uniquesFloat = Array(Set<LeanplumABVariable<Float>>.init(floatVariables))
        let uniquesBool = Array(Set<LeanplumABVariable<Bool>>.init(boolVariables))
        let uniquesString = Array(Set<LeanplumABVariable<String>>.init(stringVariables))

        var trackingData: [(String, ABGroup)] = syncer.trackingData(variables: uniquesString)
        trackingData.append(contentsOf: syncer.trackingData(variables: uniquesBool))
        trackingData.append(contentsOf: syncer.trackingData(variables: uniquesInt))
        trackingData.append(contentsOf: syncer.trackingData(variables: uniquesFloat))

        self.trackingData.value = trackingData
    }
}

// MARK: Discovery

extension ABTests {
    var sectionedMainFeed: LeanplumABVariable<Int> { return discovery.sectionedMainFeed }
}
    
extension ABTests {
    var personalizedFeed: LeanplumABVariable<Int> {
        return discovery.personalizedFeed
    }
    
    /**
     It is for a special request from Discovery team.
     
     This AB test has 3 cases: control(0), baseline(1) and active(2)
     But they want to be able to send values that are larger than 2 without us touching the code.
     
     Therefore, the test is considered active if the value is > 1
     ABIOS-4113 https://ambatana.atlassian.net/browse/ABIOS-4113
    */
    var personlizedFeedIsActive: Bool {
        return personalizedFeed.value > 1
    }
    
    var multiContactAfterSearch: LeanplumABVariable<Int> {
        return discovery.multiContact
    }
    
    var emptySearchImprovements: LeanplumABVariable<Int> {
        return discovery.emptySearchImprovements
    }
}

//  MARK: Users

extension ABTests {
    var advancedReputationSystem: LeanplumABVariable<Int> { return users.advancedReputationSystem }
    var showPasswordlessLogin: LeanplumABVariable<Int> { return users.showPasswordlessLogin }
    var emergencyLocate: LeanplumABVariable<Int> { return users.emergencyLocate }
    var offensiveReportAlert: LeanplumABVariable<Int> { return users.offensiveReportAlert }
    var reportingFostaSesta: LeanplumABVariable<Int> { return users.reportingFostaSesta }
    var community: LeanplumABVariable<Int> { return users.community }
}

//  MARK: Core

extension ABTests {
    var searchImprovements: LeanplumABVariable<Int> { return core.searchImprovements }
    var relaxedSearch: LeanplumABVariable<Int> { return core.relaxedSearch }
    var cachedFeed: LeanplumABVariable<Int> { return core.cachedFeed }
}

//  MARK: Chat

extension ABTests {
    var showInactiveConversations: LeanplumABVariable<Bool> { return chat.showInactiveConversations }
    var showChatSafetyTips: LeanplumABVariable<Bool> { return chat.showChatSafetyTips }
    var userIsTyping: LeanplumABVariable<Int> { return chat.userIsTyping }
    var chatNorris: LeanplumABVariable<Int> { return chat.chatNorris }
    var showChatConnectionStatusBar: LeanplumABVariable<Int> { return chat.showChatConnectionStatusBar }
    var showChatHeaderWithoutListingForAssistant: LeanplumABVariable<Bool> { return chat.showChatHeaderWithoutListingForAssistant }
    var showChatHeaderWithoutUser: LeanplumABVariable<Bool> { return chat.showChatHeaderWithoutUser }
    var enableCTAMessageType: LeanplumABVariable<Bool> { return chat.enableCTAMessageType }
    var expressChatImprovement: LeanplumABVariable<Int> { return chat.expressChatImprovement }
    var smartQuickAnswers: LeanplumABVariable<Int> { return chat.smartQuickAnswers }
    var openChatFromUserProfile: LeanplumABVariable<Int> { return chat.openChatFromUserProfile }
}

//  MARK: Money

extension ABTests {
    var noAdsInFeedForNewUsers: LeanplumABVariable<Int> { return money.noAdsInFeedForNewUsers }
    var copyForChatNowInTurkey: LeanplumABVariable<Int> { return money.copyForChatNowInTurkey }
    var showProTagUserProfile: LeanplumABVariable<Bool> { return money.showProTagUserProfile }
    var feedAdsProviderForUS: LeanplumABVariable<Int> { return money.feedAdsProviderForUS }
    var copyForChatNowInEnglish: LeanplumABVariable<Int> { return money.copyForChatNowInEnglish }
    var feedAdsProviderForTR: LeanplumABVariable<Int> { return money.feedAdsProviderForTR }
    var bumpUpBoost: LeanplumABVariable<Int> { return money.bumpUpBoost }
    var showExactLocationForPros: LeanplumABVariable<Bool> { return money.showExactLocationForPros }
    var copyForSellFasterNowInEnglish : LeanplumABVariable<Int> { return money.copyForSellFasterNowInEnglish }
    var googleAdxForTR: LeanplumABVariable<Int> { return money.googleAdxForTR }
    var fullScreenAdsWhenBrowsingForUS: LeanplumABVariable<Int> { return money.fullScreenAdsWhenBrowsingForUS }
    var preventMessagesFromFeedToProUsers: LeanplumABVariable<Int> { return money.preventMessagesFromFeedToProUsers }
    var appInstallAdsInFeed: LeanplumABVariable<Int> { return money.appInstallAdsInFeed }
    var alwaysShowBumpBannerWithLoading: LeanplumABVariable<Int> { return money.alwaysShowBumpBannerWithLoading }
    var showSellFasterInProfileCells: LeanplumABVariable<Int> { return money.showSellFasterInProfileCells }
    var bumpInEditCopys: LeanplumABVariable<Int> { return money.bumpInEditCopys }
    var copyForSellFasterNowInTurkish : LeanplumABVariable<Int> { return money.copyForSellFasterNowInTurkish }
    var multiAdRequestMoreInfo: LeanplumABVariable<Int> { return money.multiAdRequestMoreInfo }
}

//  MARK: Retention

extension ABTests {
    var dummyUsersInfoProfile: LeanplumABVariable<Int> { return retention.dummyUsersInfoProfile }
    var onboardingIncentivizePosting: LeanplumABVariable<Int> { return retention.onboardingIncentivizePosting }
    var iAmInterestedInFeed: LeanplumABVariable<Int> { return retention.iAmInterestedInFeed }
    var highlightedIAmInterestedInFeed: LeanplumABVariable<Int> { return retention.highlightedIAmInterestedInFeed }
    var notificationSettings: LeanplumABVariable<Int> { return retention.notificationSettings }
    var searchAlertsInSearchSuggestions: LeanplumABVariable<Int> { return retention.searchAlertsInSearchSuggestions }
    var engagementBadging: LeanplumABVariable<Int> { return retention.engagementBadging }
    var searchAlertsDisableOldestIfMaximumReached: LeanplumABVariable<Int> { return retention.searchAlertsDisableOldestIfMaximumReached }
}

//  MARK: RealEstate
//  Please use Verticals from now on

extension ABTests {
    var realEstateNewCopy: LeanplumABVariable<Int> { return realEstate.realEstateNewCopy }
}

//  MARK: Verticals

extension ABTests {
    var jobsAndServicesEnabled: LeanplumABVariable<Int> { return verticals.jobsAndServicesEnabled }
    var servicesPaymentFrequency: LeanplumABVariable<Int> { return verticals.servicesPaymentFrequency }
    var carExtraFieldsEnabled: LeanplumABVariable<Int> { return verticals.carExtraFieldsEnabled }
    var realEstateMapTooltip: LeanplumABVariable<Int> { return verticals.realEstateMapTooltip }
    var servicesUnifiedFilterScreen: LeanplumABVariable<Int> { return verticals.servicesUnifiedFilterScreen }
}

//  MARK: Products

extension ABTests {
    var servicesCategoryOnSalchichasMenu: LeanplumABVariable<Int> { return products.servicesCategoryOnSalchichasMenu }
    var predictivePosting: LeanplumABVariable<Int> { return products.predictivePosting }
    var videoPosting: LeanplumABVariable<Int> { return products.videoPosting }
    var simplifiedChatButton: LeanplumABVariable<Int> { return products.simplifiedChatButton }
    var frictionlessShare: LeanplumABVariable<Int> { return products.frictionlessShare }
}

//  MARK: Legacy

extension ABTests {
    var marketingPush: LeanplumABVariable<Int> { return legacy.marketingPush }
    // Not an A/B just flags and variables for surveys
    var surveyURL: LeanplumABVariable<String> { return legacy.surveyURL }
    var surveyEnabled: LeanplumABVariable<Bool> { return legacy.surveyEnabled }
    var freeBumpUpEnabled: LeanplumABVariable<Bool> { return legacy.freeBumpUpEnabled }
    var pricedBumpUpEnabled: LeanplumABVariable<Bool> { return legacy.pricedBumpUpEnabled }
    var newCarsMultiRequesterEnabled: LeanplumABVariable<Bool> { return legacy.newCarsMultiRequesterEnabled }
    var inAppRatingIOS10: LeanplumABVariable<Bool> { return legacy.inAppRatingIOS10 }
    var userReviewsReportEnabled: LeanplumABVariable<Bool> { return legacy.userReviewsReportEnabled }
    var appRatingDialogInactive: LeanplumABVariable<Bool> { return legacy.appRatingDialogInactive }
    var locationDataSourceType: LeanplumABVariable<Int> { return legacy.locationDataSourceType }
    var realEstateEnabled: LeanplumABVariable<Int> { return legacy.realEstateEnabled }
    var deckItemPage: LeanplumABVariable<Int> { return legacy.newItemPage }
    var taxonomiesAndTaxonomyChildrenInFeed: LeanplumABVariable<Int> { return legacy.taxonomiesAndTaxonomyChildrenInFeed }
    var showClockInDirectAnswer: LeanplumABVariable<Int> { return legacy.showClockInDirectAnswer }
    var showAdsInFeedWithRatio: LeanplumABVariable<Int> { return legacy.showAdsInFeedWithRatio }
}
