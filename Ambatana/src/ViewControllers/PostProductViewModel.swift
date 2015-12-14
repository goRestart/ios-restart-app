//
//  PostProductViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

protocol PostProductViewModelDelegate: class {

}

class PostProductViewModel: BaseViewModel {

    weak var delegate: PostProductViewModelDelegate?

}
