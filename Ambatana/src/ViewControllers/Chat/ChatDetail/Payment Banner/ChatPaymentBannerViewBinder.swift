import RxSwift
import RxCocoa

struct ChatPaymentBannerViewBinder {
    func bind(_ view: ChatPaymentBannerView, viewModel: ChatPaymentBannerViewModel, bag: DisposeBag) {
        viewModel.offerState
            .drive(view.rx.offerState)
            .disposed(by: bag)
        
        viewModel.isHidden
            .drive(view.rx.isHidden)
            .disposed(by: bag)
        
        viewModel.buttonAction
            .drive(view.rx.buttonActionEvent)
            .disposed(by: bag)
    
        view.rx.actionButtonWasTapped.subscribe { _ in
            viewModel.actionButtonWasPressed()
        }.disposed(by: bag)
    }
}
