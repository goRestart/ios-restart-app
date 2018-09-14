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
    var mutePushNotifications: (MutePushNotifications, Int, Int)?

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

    func retrieveMutePushNotifications() -> (MutePushNotifications, hourStart: Int, hourEnd: Int)? {
        return mutePushNotifications
    }
    
    func save(mutePushNotifications: MutePushNotifications, hourStart: Int, hourEnd: Int) {
        self.mutePushNotifications = (mutePushNotifications, hourStart, hourEnd)
    }
    
    func retrieveMutePushNotifications() -> MutePushNotificationFeatureFlagHelper? {
        return nil
    }
}
