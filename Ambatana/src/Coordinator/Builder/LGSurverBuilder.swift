import Foundation

protocol SurveyAssembly {
    func buildWebSurvey(with url : URL) -> WebSurveyViewController
}

enum LGSurveyBuilder {
    case modal(root: UIViewController)
}

extension LGSurveyBuilder: SurveyAssembly {
    func buildWebSurvey(with url: URL) -> WebSurveyViewController {
        switch self {
        case .modal(let root):
            let vm = WebSurveyViewModel(surveyUrl: url)
            vm.navigator = WebSurveyRouter(root: root)
            return WebSurveyViewController(viewModel: vm)
        }
    }
}
