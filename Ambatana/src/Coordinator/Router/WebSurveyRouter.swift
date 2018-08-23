import Foundation
import LGComponents

protocol WebSurveyNavigator: class {
    func closeWebSurvey()
    func webSurveyFinished()
}

final class WebSurveyRouter: WebSurveyNavigator {
    private weak var root: UIViewController?

    required init(root: UIViewController) {
        self.root = root
    }

    func closeWebSurvey() {
        root?.dismiss(animated: true, completion: nil)
    }

    func webSurveyFinished() {
        root?.dismiss(animated: true, completion: { [weak root] in
            root?.showAutoFadingOutMessageAlert(message: R.Strings.surveyConfirmation)
        })
    }
}
