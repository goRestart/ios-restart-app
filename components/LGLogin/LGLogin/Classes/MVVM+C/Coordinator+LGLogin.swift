extension Coordinator {
    public func openLoginIfNeeded(from source: EventParameterLoginSourceValue,
                                  style: LoginStyle,
                                  loggedInAction: @escaping (() -> Void),
                                  cancelAction: (() -> Void)?,
                                  factory: LoginComponentFactory) {
        guard !sessionManager.loggedIn else {
            loggedInAction()
            return
        }
        let coordinator = factory.makeLoginCoordinator(source: source,
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

