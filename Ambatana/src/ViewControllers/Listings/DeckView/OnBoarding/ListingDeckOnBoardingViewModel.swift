//
//  ListingDeckOnBoardingViewModel.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol ListingDeckOnBoardingNavigator: class {
    func close()
}

final class ListingDeckOnBoardingViewModel: BaseViewModel, ListingDeckOnBoardingViewModelType {

    weak var navigator: ListingDeckOnBoardingNavigator?
    func close() { navigator?.close() }

}
