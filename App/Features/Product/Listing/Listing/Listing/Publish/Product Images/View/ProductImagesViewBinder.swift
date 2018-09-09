import RxSwift
import RxCocoa

struct ProductImagesViewBinder {
  func bind(_ view: ProductImagesView, to viewModel: ProductImagesViewModelType, using bag: DisposeBag) {
    viewModel.output.nextStepEnabled
      .drive(view.rx.nextButtonIsEnabled)
      .disposed(by: bag)
    
    viewModel.output.imageIndexShouldBeRemoved
      .asObservable()
      .subscribe(onNext: { index in
        view.showImageRemoveAlert(for: index)
    }).disposed(by: bag)
    
    view.imageSelectionRelay.subscribe(onNext: { imageSelection in
      viewModel.input.onAdd(image: imageSelection.image, with: imageSelection.index)
    }).disposed(by: bag)
    
    view.imageDeselectionRelay.subscribe(onNext: { index in
      viewModel.input.onRemoveImage(with: index)
    }).disposed(by: bag)
    
    view.rx.addImage1WasTapped.subscribe { _ in
      viewModel.input.onImageSelected(with: 1)
    }.disposed(by: bag)
    
    view.rx.addImage2WasTapped.subscribe { _ in
      viewModel.input.onImageSelected(with: 2)
    }.disposed(by: bag)
    
    view.rx.addImage3WasTapped.subscribe { _ in
      viewModel.input.onImageSelected(with: 3)
    }.disposed(by: bag)
    
    view.rx.addImage4WasTapped.subscribe { _ in
      viewModel.input.onImageSelected(with: 4)
    }.disposed(by: bag)
    
    view.rx.addImage5WasTapped.subscribe { _ in
      viewModel.input.onImageSelected(with: 5)
    }.disposed(by: bag)

    view.rx.closeButtonWasTapped.subscribe { _ in
      viewModel.input.onCloseButtonPressed()
    }.disposed(by: bag)
    
    view.rx.nextButtonWasTapped.subscribe { _ in
      viewModel.input.onNextStepPressed()
    }.disposed(by: bag)
  }
}
