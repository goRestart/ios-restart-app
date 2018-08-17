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
}
