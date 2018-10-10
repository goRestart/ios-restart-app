import RxSwift
import LGComponents

class ChatBaseViewController: BaseViewController {
    
    let bag = DisposeBag()

    init(viewModel: ChatBaseViewModel,
         featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        super.init(viewModel: viewModel, nibName: nil)
        showConnectionToastView = !featureFlags.showChatConnectionStatusBar.isActive
        setupBaseRx(viewModel: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBaseRx(viewModel: ChatBaseViewModel) {
        viewModel.rx_vmPresentActionSheet
            .asObservable()
            .bind { [weak self] vmActionSheet in
                self?.showActionSheet(vmActionSheet.cancelTitle,
                                      actions: vmActionSheet.actions)
            }
            .disposed(by: bag)
        
        viewModel.rx_vmPresentAlert
            .asObserver()
            .bind { [weak self] vmPresentAlert in
                let alertController = UIAlertController(title: vmPresentAlert.title,
                                                        message: vmPresentAlert.message,
                                                        preferredStyle: .alert)
                vmPresentAlert.actions.forEach { vmAction in
                    alertController.addAction(UIAlertAction(title: vmAction.title,
                                                            style: vmAction.style.alertActionStyle) { (_) -> Void in
                                                                vmAction.handler?()
                    })
                }
                self?.present(alertController,
                              animated: vmPresentAlert.animated,
                              completion: vmPresentAlert.completion)
            }
            .disposed(by: bag)
        
        viewModel.rx_vmPresentLoadingMessage
            .asObserver()
            .bind { [weak self] vmPresentLoadingMessage in
                self?.showLoadingMessageAlert(vmPresentLoadingMessage.message)
            }
            .disposed(by: bag)
        
        viewModel.rx_vmDismissLoadingMessage
            .asObserver()
            .bind { [weak self] vmDismissLoadingMessage in
                self?.dismissLoadingMessageAlert(vmDismissLoadingMessage.endingMessage,
                                                 afterMessageCompletion: vmDismissLoadingMessage.completion)
            }
            .disposed(by: bag)

        viewModel.rx_vmPresentAutofadingAlert
        .asObserver()
            .bind { [weak self] vmAutofadingAlert in
                self?.showAutoFadingOutMessageAlert(title: vmAutofadingAlert.title,
                                                    message: vmAutofadingAlert.message,
                                                    time: vmAutofadingAlert.time)
        }.disposed(by: bag)
    }
    
}
