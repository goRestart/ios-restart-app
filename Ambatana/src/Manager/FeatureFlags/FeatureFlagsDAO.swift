//
//  FeatureFlagsDAO.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/06/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

protocol FeatureFlagsDAO {
    func retrieveTimeoutForRequests() -> TimeInterval?
    func save(timeoutForRequests: TimeInterval)
    func retrieveNewUserProfile() -> NewUserProfileView?
    func save(newUserProfile: NewUserProfileView)
    func retrieveShowAdvanceReputationSystem() -> ShowAdvancedReputationSystem?
    func save(showAdvanceReputationSystem: ShowAdvancedReputationSystem)
}
