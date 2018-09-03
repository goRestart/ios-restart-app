import Foundation

protocol LeanplumAssembly {
    func buildLeanplumMessage(with message: LPMessage) -> LPMessageViewController
}

enum LGLeanplumBuilder {
    case modal(root: UIViewController)
}

extension LGLeanplumBuilder: LeanplumAssembly {
    func buildLeanplumMessage(with message: LPMessage) -> LPMessageViewController {
        switch self {
        case .modal(let root):
            let vm = LPMessageViewModel(type: message.type,
                                        action: message.action,
                                        headline: message.headline,
                                        subHeadline: message.subHeadline,
                                        image: message.image)
            let vc = LPMessageViewController(vm: vm)
            vc.modalPresentationStyle = .overCurrentContext
            vm.navigator = LPMessageWireframe(root: root)

            return vc
        }
    }

}
