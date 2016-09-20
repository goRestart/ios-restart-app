//
//  TourLoginViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

final class TourLoginViewModel: BaseViewModel {
    weak var navigator: TourLoginNavigator?

    func nextStep() {
        navigator?.tourLoginFinish()
    }
}
