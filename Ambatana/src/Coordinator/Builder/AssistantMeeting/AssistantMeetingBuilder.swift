import LGCoreKit

protocol AssistantMeetingAssembly {
    func buildAssistantFor(listingId: String, dataDelegate: MeetingAssistantDataDelegate) -> UIViewController
    func buildMeetingSafetyTips(with closeCompletion: (()->Void)?) -> UIViewController
}

enum AssistantMeetingBuilder {
    case modal(UIViewController)
}

extension AssistantMeetingBuilder: AssistantMeetingAssembly {
    func buildAssistantFor(listingId: String, dataDelegate: MeetingAssistantDataDelegate) -> UIViewController {
        let vm = MeetingAssistantViewModel(listingId: listingId)
        vm.dataDelegate = dataDelegate
        let vc = MeetingAssistantViewController(viewModel: vm)
        switch self {
        case .modal(let root):
            let nav = UINavigationController(rootViewController: vc)
            vm.navigator = MeetingAssistantModalWireframe(root: root, nc: nav)
            return nav
        }
    }

    func buildMeetingSafetyTips(with closeCompletion: (() -> Void)?) -> UIViewController {
        let vm = MeetingSafetyTipsViewModel(closeCompletion: closeCompletion)
        let vc = MeetingSafetyTipsViewController(viewModel: vm)
        switch self {
        case .modal(let root):
            vm.navigator = MeetingAssistantModalWireframe(root: root, nc: nil)
            return vc
        }
    }
}

