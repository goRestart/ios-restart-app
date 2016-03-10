//
//  UserViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol UserViewModelDelegate: class {

}


class UserViewModel: BaseViewModel {

    weak var delegate: UserViewModelDelegate?


    // MARK: - Lifecycle

    convenience override init() {
        let myUserRepository = Core.myUserRepository
        let productRepository = Core.productRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, productRepository: productRepository, tracker: tracker)
    }

    init(myUserRepository: MyUserRepository, productRepository: ProductRepository, tracker: Tracker) {
        super.init()
    }
}
