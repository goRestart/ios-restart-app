//
//  FeatureFlagsDAO.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/06/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

protocol FeatureFlagsDAO {
    func retrieveEmergencyLocate() -> EmergencyLocate?
    func save(emergencyLocate: EmergencyLocate)
    func retrieveCommunity() -> ShowCommunity?
    func save(community: ShowCommunity)
    func retrieveAdvancedReputationSystem11() -> AdvancedReputationSystem11?
    func save(advancedReputationSystem11: AdvancedReputationSystem11)
    func retrieveAdvancedReputationSystem12() -> AdvancedReputationSystem12?
    func save(advancedReputationSystem12: AdvancedReputationSystem12)
    func retrieveAdvancedReputationSystem13() -> AdvancedReputationSystem13?
    func save(advancedReputationSystem13: AdvancedReputationSystem13)
    func retrieveMutePushNotifications() -> (MutePushNotifications, hourStart: Int, hourEnd: Int)?
    func save(mutePushNotifications: MutePushNotifications, hourStart: Int, hourEnd: Int)
}
