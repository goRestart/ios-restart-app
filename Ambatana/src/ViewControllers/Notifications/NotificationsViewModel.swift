//
//  NotificationsViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 26/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol NotificationsViewModelDelegate: BaseViewModelDelegate {
}

class NotificationsViewModel: BaseViewModel {

    weak var delegate: NotificationsViewModelDelegate?

    private let notificationsRepository: NotificationsRepository

    convenience override init() {
        self.init(notificationsRepository: Core.notificationsRepository)
    }

    init(notificationsRepository: NotificationsRepository) {
        self.notificationsRepository = notificationsRepository
        super.init()
    }

    


    // MARK: - Private methods


    
}