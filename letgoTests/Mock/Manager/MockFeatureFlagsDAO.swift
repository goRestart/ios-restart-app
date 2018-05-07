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
    var newUserProfile: NewUserProfileView?
    var showAdvancedReputationSystem: ShowAdvancedReputationSystem?
    var emergencyLocate: EmergencyLocate?

    func retrieveTimeoutForRequests() -> TimeInterval? {
        return timeoutForRequests
    }

    func save(timeoutForRequests: TimeInterval) {
        self.timeoutForRequests = timeoutForRequests
    }

    func retrieveNewUserProfile() -> NewUserProfileView? {
        return newUserProfile
    }

    func save(newUserProfile: NewUserProfileView) {
        self.newUserProfile = newUserProfile
    }

    func retrieveShowAdvanceReputationSystem() -> ShowAdvancedReputationSystem? {
        return showAdvancedReputationSystem
    }

    func save(showAdvanceReputationSystem: ShowAdvancedReputationSystem) {
        self.showAdvancedReputationSystem = showAdvanceReputationSystem
    }

    func retrieveEmergencyLocate() -> EmergencyLocate? {
        return emergencyLocate
    }

    func save(emergencyLocate: EmergencyLocate) {
        self.emergencyLocate = emergencyLocate
    }
}
