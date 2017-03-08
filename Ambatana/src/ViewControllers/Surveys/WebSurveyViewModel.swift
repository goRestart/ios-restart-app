//
//  WebSurveyViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 08/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

protocol WebSurveyViewModelDelegate: BaseViewModelDelegate {

}

class WebSurveyViewModel: BaseViewModel {

    weak var delegate: WebSurveyViewModelDelegate?

    let url: URL?

    init(featureFlags: FeatureFlaggeable) {
        self.url = URL(string: "https://letgo1.typeform.com/to/e9Ndb4")
    }

    func closeButtonPressed() {
        delegate?.vmDismiss(nil)
    }
}
