//
//  Product+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension Listing {
    func belongsTo(userId: String?) -> Bool {
        let ownerId = user.objectId
        guard user.objectId != nil && userId != nil else { return false }
        return ownerId == userId
    }

    func isMine(myUserRepository: MyUserRepository) -> Bool {
        return belongsTo(userId: myUserRepository.myUser?.objectId)
    }

    func containsVideo() -> Bool {
        return media.contains(where: { $0.type == .video })
    }
    
    var isCarWithEmptyAttributes: Bool {
        guard isCar else { return false }
        return car?.carAttributes.isAllExtraFieldsEmpty ?? false
    }
    
    var isRealEstateWithEmptyAttributes: Bool {
        guard isRealEstate else { return false }
        return realEstate?.realEstateAttributes == RealEstateAttributes.emptyRealEstateAttributes()
    }
    
    var isServiceWithEmptyAttributes: Bool {
        guard isService else { return false }
        return service?.servicesAttributes == ServiceAttributes.emptyServicesAttributes()
    }

    var shouldShowFeaturedStripe: Bool {
        return featured ?? false
    }

    var sellerIsProfessional: Bool {
        return user.type.isProfessional
    }
}

extension Listing {
    func tags(postingFlowType: PostingFlowType) -> [String]? {
        switch self {
        case .product, .car:
            return nil
        case .realEstate(let realEstate):
            return realEstate.realEstateAttributes.generateTags(postingFlowType: postingFlowType)
        case .service(_):
            return nil
        }
    }
    
    
    var paymentFrequencyString: String? {
        guard price.value > 0 else { return nil }
        
        return service?.servicesAttributes.paymentFrequency?.perValueDisplayName
    }
}

extension Product {
    func belongsTo(userId: String?) -> Bool {
        let ownerId = user.objectId
        guard user.objectId != nil && userId != nil else { return false }
        return ownerId == userId
    }

    func isMine(myUserRepository: MyUserRepository) -> Bool {
        return belongsTo(userId: myUserRepository.myUser?.objectId)
    }

    var shouldShowFeaturedStripe: Bool {
        return featured ?? false
    }
}

extension Listing {
    var isVertical: Bool {
        return category.isCar || category.isServices || category.isRealEstate
    }
}

extension Listing {
    func interestedState(myUserRepository: MyUserRepository,
                         listingInterestStates: Set<String>) -> InterestedState {
        guard let listingId = objectId else { return .none  }
        guard !isMine(myUserRepository: myUserRepository) else { return .none }
        guard !listingInterestStates.contains(listingId) else { return .seeConversation }
        return .send(enabled: true)
    }
    
    func listingUser(userRepository: UserRepository, completion: @escaping (User?) -> Void) {
        guard let userId = user.objectId else {
            completion(nil)
            return
        }
        userRepository.show(userId) { result in
            completion(result.value)
        }
    }
}
