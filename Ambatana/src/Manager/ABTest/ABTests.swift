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

final class ABTests {
    private let syncer: LeamplumSyncerType
    let trackingData = Variable<[(String, ABGroup)]?>(nil)

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

        result.append(contentsOf: money.intVariables)
        result.append(contentsOf: retention.intVariables)
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
        result.append(contentsOf: money.boolVariables)
        result.append(contentsOf: retention.boolVariables)
        result.append(contentsOf: verticals.boolVariables)
        result.append(contentsOf: chat.boolVariables)
        result.append(contentsOf: core.boolVariables)
        result.append(contentsOf: users.boolVariables)
        result.append(contentsOf: discovery.boolVariables)
        result.append(contentsOf: products.boolVariables)
        return result
    }

    private var stringVariables: [LeanplumABVariable<String>] { return [] }
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
    
    var emptySearchImprovements: LeanplumABVariable<Int> {
        return discovery.emptySearchImprovements
    }
    
    var sectionedFeed: LeanplumABVariable<Int> {
        return discovery.sectionedFeed
    }
    
    var sectionedFeedIsActive: Bool {
        return sectionedFeed.value > 1
    }
    
    var newSearchAPI: LeanplumABVariable<Int> { return discovery.newSearchAPI }
}

//  MARK: Users

extension ABTests {
    var showPasswordlessLogin: LeanplumABVariable<Int> { return users.showPasswordlessLogin }
    var emergencyLocate: LeanplumABVariable<Int> { return users.emergencyLocate }
    var offensiveReportAlert: LeanplumABVariable<Int> { return users.offensiveReportAlert }
    var reportingFostaSesta: LeanplumABVariable<Int> { return users.reportingFostaSesta }
    var community: LeanplumABVariable<Int> { return users.community }
    var advancedReputationSystem11: LeanplumABVariable<Int> { return users.advancedReputationSystem11 }
    var advancedReputationSystem12: LeanplumABVariable<Int> { return users.advancedReputationSystem12 }
    var advancedReputationSystem13: LeanplumABVariable<Int> { return users.advancedReputationSystem13 }
}

//  MARK: Core

extension ABTests {
    var searchImprovements: LeanplumABVariable<Int> { return core.searchImprovements }
    var relaxedSearch: LeanplumABVariable<Int> { return core.relaxedSearch }
    var mutePushNotifications: LeanplumABVariable<Int> { return core.mutePushNotifications }
    var mutePushNotificationsStartHour: LeanplumABVariable<Int> { return core.mutePushNotificationsStartHour }
    var mutePushNotificationsEndHour: LeanplumABVariable<Int> { return core.mutePushNotificationsEndHour }
    var facebookUnavailable: LeanplumABVariable<Bool> { return core.facebookUnavailable }
}

//  MARK: Chat

extension ABTests {
    var showInactiveConversations: LeanplumABVariable<Bool> { return chat.showInactiveConversations }
    var showChatSafetyTips: LeanplumABVariable<Bool> { return chat.showChatSafetyTips }
    var chatNorris: LeanplumABVariable<Int> { return chat.chatNorris }
    var showChatConnectionStatusBar: LeanplumABVariable<Int> { return chat.showChatConnectionStatusBar }
    var showChatHeaderWithoutUser: LeanplumABVariable<Bool> { return chat.showChatHeaderWithoutUser }
    var enableCTAMessageType: LeanplumABVariable<Bool> { return chat.enableCTAMessageType }
    var expressChatImprovement: LeanplumABVariable<Int> { return chat.expressChatImprovement }
    var smartQuickAnswers: LeanplumABVariable<Int> { return chat.smartQuickAnswers }
    var openChatFromUserProfile: LeanplumABVariable<Int> { return chat.openChatFromUserProfile }
    var markAsSoldQuickAnswerNewFlow: LeanplumABVariable<Int> { return chat.markAsSoldQuickAnswerNewFlow }
    var shouldMoveLetsMeetAction: LeanplumABVariable<Bool> { return chat.shouldMoveLetsMeetAction }
}

//  MARK: Money

extension ABTests {
    var copyForChatNowInTurkey: LeanplumABVariable<Int> { return money.copyForChatNowInTurkey }
    var showProTagUserProfile: LeanplumABVariable<Bool> { return money.showProTagUserProfile }
    var copyForChatNowInEnglish: LeanplumABVariable<Int> { return money.copyForChatNowInEnglish }
    var showExactLocationForPros: LeanplumABVariable<Bool> { return money.showExactLocationForPros }
    var copyForSellFasterNowInEnglish : LeanplumABVariable<Int> { return money.copyForSellFasterNowInEnglish }
    var fullScreenAdsWhenBrowsingForUS: LeanplumABVariable<Int> { return money.fullScreenAdsWhenBrowsingForUS }
    var preventMessagesFromFeedToProUsers: LeanplumABVariable<Int> { return money.preventMessagesFromFeedToProUsers }
    var appInstallAdsInFeed: LeanplumABVariable<Int> { return money.appInstallAdsInFeed }
    var alwaysShowBumpBannerWithLoading: LeanplumABVariable<Int> { return money.alwaysShowBumpBannerWithLoading }
    var showSellFasterInProfileCells: LeanplumABVariable<Int> { return money.showSellFasterInProfileCells }
    var bumpInEditCopys: LeanplumABVariable<Int> { return money.bumpInEditCopys }
    var copyForSellFasterNowInTurkish : LeanplumABVariable<Int> { return money.copyForSellFasterNowInTurkish }
    var multiAdRequestMoreInfo: LeanplumABVariable<Int> { return money.multiAdRequestMoreInfo }
    var multiDayBumpUp: LeanplumABVariable<Int> { return money.multiDayBumpUp }
    var multiAdRequestInChatSectionForUS: LeanplumABVariable<Int> { return money.multiAdRequestInChatSectionForUS }
    var multiAdRequestInChatSectionForTR: LeanplumABVariable<Int> { return money.multiAdRequestInChatSectionForTR }
    var bumpPromoAfterSellNoLimit: LeanplumABVariable<Int> { return money.bumpPromoAfterSellNoLimit }
    var polymorphFeedAdsUSA: LeanplumABVariable<Int> { return money.polymorphFeedAdsUSA }
    var showAdsInFeedWithRatio: LeanplumABVariable<Int> { return money.showAdsInFeedWithRatio }
}

//  MARK: Retention

extension ABTests {
    var dummyUsersInfoProfile: LeanplumABVariable<Int> { return retention.dummyUsersInfoProfile }
    var onboardingIncentivizePosting: LeanplumABVariable<Int> { return retention.onboardingIncentivizePosting }
    var searchAlertsInSearchSuggestions: LeanplumABVariable<Int> { return retention.searchAlertsInSearchSuggestions }
    var engagementBadging: LeanplumABVariable<Int> { return retention.engagementBadging }
    var searchAlertsDisableOldestIfMaximumReached: LeanplumABVariable<Int> { return retention.searchAlertsDisableOldestIfMaximumReached }
    var randomImInterestedMessages: LeanplumABVariable<Int> { return retention.randomImInterestedMessages }
    var imInterestedInProfile: LeanplumABVariable<Int> { return retention.imInterestedInProfile }
    var shareAfterScreenshot: LeanplumABVariable<Int> { return retention.shareAfterScreenshot }
    var affiliationCampaign: LeanplumABVariable<Int> { return retention.affiliationCampaign }
    var imageSizesNotificationCenter: LeanplumABVariable<Int> { return retention.imageSizesNotificationCenter }
    var blockingSignUp: LeanplumABVariable<Int> { return retention.blockingSignUp }
}

//  MARK: Verticals

extension ABTests {
    var jobsAndServicesEnabled: LeanplumABVariable<Int> { return verticals.jobsAndServicesEnabled }
    var servicesPaymentFrequency: LeanplumABVariable<Int> { return verticals.servicesPaymentFrequency }
    var carPromoCells: LeanplumABVariable<Int> { return verticals.carPromoCells }
    var servicesPromoCells: LeanplumABVariable<Int> { return verticals.servicesPromoCells }
    var realEstatePromoCells: LeanplumABVariable<Int> { return verticals.realEstatePromoCells }
    var proUserExtraImages: LeanplumABVariable<Int> { return verticals.proUsersExtraImages }
    var clickToTalk: LeanplumABVariable<Int> { return verticals.clickToTalk }
    var realEstateEnabled: LeanplumABVariable<Int> { return verticals.realEstateEnabled }
}

//  MARK: Products

extension ABTests {
    var simplifiedChatButton: LeanplumABVariable<Int> { return products.simplifiedChatButton }
    var deckItemPage: LeanplumABVariable<Int> { return products.deckItemPage }
    var frictionlessShare: LeanplumABVariable<Int> { return products.frictionlessShare }
    var turkeyFreePosting: LeanplumABVariable<Int> { return products.turkeyFreePosting }
    var bulkPosting: LeanplumABVariable<Int> { return products.bulkPosting }
    var makeAnOfferButton: LeanplumABVariable<Int> { return products.makeAnOfferButton }
}
