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

    private static let submitRedirect = "letgo.com"

    weak var delegate: WebSurveyViewModelDelegate?

    let url: URL?

    init(featureFlags: FeatureFlaggeable) {
        self.url = URL(string: "https://letgo1.typeform.com/to/e9Ndb4")
    }

    func closeButtonPressed() {
        delegate?.vmDismiss(nil)
    }

    func failedLoad() {
        delegate?.vmDismiss(nil)
    }

    func shouldLoad(url: URL?) -> Bool {
        guard let url = url else { return false }
        if url.absoluteString.contains(WebSurveyViewModel.submitRedirect) {
            delegate?.vmDismiss(nil)
            return false
        }
        return true
    }
}
