//
//  PostProductDetailViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 17/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol PostProductDetailViewModelDelegate: class {

}

class PostProductDetailViewModel: BaseViewModel {
    weak var delegate: PostProductDetailViewModelDelegate?
}
