import Foundation
import LGComponents

extension Coordinator {
    
    func openLoginIfNeeded(from source: EventParameterLoginSourceValue, style: LoginStyle,
                           loggedInAction: @escaping (() -> Void), cancelAction: (() -> Void)?) {
        guard !sessionManager.loggedIn else {
            loggedInAction()
            return
        }
        let coordinator = LoginCoordinator(source: source,
                                           style: style,
                                           loggedInAction: loggedInAction,
                                           cancelAction: cancelAction)
        openChild(coordinator: coordinator,
                  parent: viewController,
                  animated: true,
                  forceCloseChild: true,
                  completion: nil)
    }
}
