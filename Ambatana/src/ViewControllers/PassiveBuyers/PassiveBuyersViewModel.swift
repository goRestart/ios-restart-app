//
//  PassiveBuyersViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 23/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol PassiveBuyersViewModelDelegate: BaseViewModelDelegate {

}

class PassiveBuyersViewModel: BaseViewModel {
    
    weak var delegate: PassiveBuyersViewModelDelegate?
}
