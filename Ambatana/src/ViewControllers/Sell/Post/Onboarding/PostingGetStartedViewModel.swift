//
//  PostingGetStartedViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 20/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

class PostingGetStartedViewModel: BaseViewModel {
    
    weak var navigator: PostingHastenedCreateProductNavigator?

    
    // MARK: - Lifecycle
    
    override init() {
    }
    
    
    // MARK: - Navigation
    
    func nextAction() {
        navigator?.openCamera()
    }
}

