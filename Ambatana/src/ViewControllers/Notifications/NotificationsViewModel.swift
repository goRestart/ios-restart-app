//
//  NotificationsViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 26/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

protocol NotificationsViewModelDelegate: BaseViewModelDelegate {
}

class NotificationsViewModel: BaseViewModel {

    weak var delegate: NotificationsViewModelDelegate?

    

}