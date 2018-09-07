import RxSwift
import RxCocoa

struct ProductImagesViewBinder {
  func bind(_ view: ProductImagesView, to viewModel: ProductImagesViewModelType, using bag: DisposeBag) {
    
    viewModel.output.nextStepEnabled
      .drive(view.rx.nextButtonIsEnabled)
      .disposed(by: bag)
    
    view.imageSelectionRelay.subscribe(onNext: { image in
      guard let image = image else { return }
      viewModel.input.onAdd(image: image)
    }).disposed(by: bag)
    
    view.imageDeselectionRelay.subscribe(onNext: { image in
      guard let image = image else { return }
      viewModel.input.onRemove(image: image)
    }).disposed(by: bag)
    
    view.rx.nextButtonWasTapped.subscribe { _ in
      viewModel.input.onNextStepPressed()
    }.disposed(by: bag)
  }
}
