//
//  UserRatingViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol UserRatingViewModelDelegate: BaseViewModelDelegate {

}

class UserRatingViewModel: BaseViewModel {

    weak var delegate: UserRatingViewModelDelegate?

}