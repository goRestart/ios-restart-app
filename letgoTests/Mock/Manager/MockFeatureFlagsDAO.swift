//
//  MockFeatureFlagsDAO.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/06/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode

class MockFeatureFlagsDAO: FeatureFlagsDAO {
    
    var timeoutForRequests: TimeInterval?
    var emergencyLocate: EmergencyLocate?
    var community: ShowCommunity?
    var advancedReputationSystem11: AdvancedReputationSystem11?
    var advancedReputationSystem12: AdvancedReputationSystem12?
    var advancedReputationSystem13: AdvancedReputationSystem13?
    var mutePushNotifications: (MutePushNotifications, Int, Int)?
    var affiliationEnabled: AffiliationEnabled?
    var blockingSignUp: BlockingSignUp?

    func retrieveTimeoutForRequests() -> TimeInterval? {
        return timeoutForRequests
    }

    func save(timeoutForRequests: TimeInterval) {
        self.timeoutForRequests = timeoutForRequests
    }

    func retrieveEmergencyLocate() -> EmergencyLocate? {
        return emergencyLocate
    }

    func save(emergencyLocate: EmergencyLocate) {
        self.emergencyLocate = emergencyLocate
    }
    
    func retrieveCommunity() -> ShowCommunity? {
        return community
    }

    func save(community: ShowCommunity) {
        self.community = community
    }

    func retrieveAdvancedReputationSystem11() -> AdvancedReputationSystem11? {
        return advancedReputationSystem11
    }

    func save(advancedReputationSystem11: AdvancedReputationSystem11) {
        self.advancedReputationSystem11 = advancedReputationSystem11
    }
    
    func retrieveAdvancedReputationSystem12() -> AdvancedReputationSystem12? {
        return advancedReputationSystem12
    }

    func save(advancedReputationSystem12: AdvancedReputationSystem12) {
        self.advancedReputationSystem12 = advancedReputationSystem12
    }

    func retrieveAdvancedReputationSystem13() -> AdvancedReputationSystem13? {
        return advancedReputationSystem13
    }

    func save(advancedReputationSystem13: AdvancedReputationSystem13) {
        self.advancedReputationSystem13 = advancedReputationSystem13
    }

    func retrieveMutePushNotifications() -> (MutePushNotifications, hourStart: Int, hourEnd: Int)? {
        return mutePushNotifications
    }
    
    func save(mutePushNotifications: MutePushNotifications, hourStart: Int, hourEnd: Int) {
        self.mutePushNotifications = (mutePushNotifications, hourStart, hourEnd)
    }
    
    func retrieveMutePushNotifications() -> MutePushNotificationFeatureFlagHelper? {
        return nil
    }
    
    func retrieveAffiliationEnabled() -> AffiliationEnabled? {
        return affiliationEnabled
    }
    
    func save(affiliationEnabled: AffiliationEnabled) {
        self.affiliationEnabled = affiliationEnabled
    }

    func retrieveBlockingSignUp() -> BlockingSignUp? {
        return blockingSignUp
    }
    
    func save(blockingSignUp: BlockingSignUp) {
        self.blockingSignUp = blockingSignUp
    }
}
