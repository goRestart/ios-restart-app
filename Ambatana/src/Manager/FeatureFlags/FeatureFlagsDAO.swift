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
    func retrieveAdvanceReputationSystem() -> AdvancedReputationSystem?
    func save(advanceReputationSystem: AdvancedReputationSystem)
    func retrieveEmergencyLocate() -> EmergencyLocate?
    func save(emergencyLocate: EmergencyLocate)
    func retrieveChatConversationsListWithoutTabs() -> ChatConversationsListWithoutTabs?
    func save(chatConversationsListWithoutTabs: ChatConversationsListWithoutTabs)
}
