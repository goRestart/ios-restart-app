//
//  EditUserBioViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 5/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift
import RxCocoa

final class EditUserBioViewModel: BaseViewModel {

    private let myUserRepository: MyUserRepository
    private let tracker: Tracker

    weak var navigator: EditUserBioNavigator?
    weak var delegate: BaseViewModelDelegate?

    var userBio: String? {
        return myUserRepository.myUser?.biography
    }

    init(myUserRepository: MyUserRepository, tracker: Tracker) {
        self.myUserRepository = myUserRepository
        self.tracker = tracker
    }

    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository,
                  tracker: TrackerProxy.sharedInstance)
    }

    func saveBio(text: String) {
        myUserRepository.updateBiography(text) { [weak self] result in
            if let value = result.value {
                self?.navigator?.closeEditUserBio()
                if let userId = value.objectId {
                    self?.trackBioUpdate(userId)
                }
            } else if let _ = result.error {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.changeBioErrorMessage, completion: nil)
            }
        }
    }
}

extension EditUserBioViewModel {

    func trackBioUpdate(_ userId: String) {
        let event = TrackerEvent.profileEditBioComplete(userId: userId)
        tracker.trackEvent(event)
    }
}
