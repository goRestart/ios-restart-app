import UI
import RxSwift
import RxCocoa

typealias ImageSelection = (image: UIImage, index: Int)

final class ProductImagesView: View {
  let imageSelectionRelay = PublishRelay<ImageSelection>()
  let imageDeselectionRelay = PublishRelay<Int>()
  
  private let titleView: TitleView = {
    let titleView = TitleView()
    titleView.title = Localize("product_images.title", table: Table.productImages)
    return titleView
  }()
  
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = Margin.small
    return stackView
  }()
  
  private let bottomStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.spacing = Margin.small
    stackView.distribution = .fillEqually
    return stackView
  }()
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    return scrollView
  }()
  
  fileprivate let closeButton: UIBarButtonItem = {
    let button = UIBarButtonItem(image: Images.Navigation.close, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    button.tintColor = .primary
    return button
  }()
  
  fileprivate let addPhotoBottom1 = AddPhotoButton()
  fileprivate let addPhotoBottom2 = AddPhotoButton()
  fileprivate let addPhotoBottom3 = AddPhotoButton()
  fileprivate let addPhotoBottom4 = AddPhotoButton()
  fileprivate let addPhotoBottom5 = AddPhotoButton()

  fileprivate let nextButton: FullWidthButton = {
    let button = FullWidthButton()
    let title = Localize("product_images.next_button.title", table: Table.productImages)
    button.setTitle(title, for: .normal)
    return button
  }()
  
  override func setupView() {
    addSubview(titleView)

    bottomStackView.addArrangedSubview(addPhotoBottom2)
    bottomStackView.addArrangedSubview(addPhotoBottom3)
    bottomStackView.addArrangedSubview(addPhotoBottom4)
    bottomStackView.addArrangedSubview(addPhotoBottom5)
    
    stackView.addArrangedSubview(addPhotoBottom1)
    stackView.addArrangedSubview(bottomStackView)
    
    scrollView.addSubview(stackView)
    addSubview(scrollView)
    addSubview(nextButton)
    
    configureCloseButton()
  }
  
  override func setupConstraints() {
    titleView.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(safeAreaLayoutGuide.snp.top)
    }
    scrollView.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(titleView.snp.bottom).offset(Margin.medium)
      make.bottom.equalTo(nextButton.snp.top).offset(-Margin.small)
    }
    stackView.snp.makeConstraints { make in
      make.leading.equalTo(self).offset(Margin.medium)
      make.trailing.equalTo(self).offset(-Margin.medium)
      make.top.equalTo(scrollView)
      make.bottom.lessThanOrEqualTo(scrollView)
    }
    addPhotoBottom1.snp.makeConstraints { make in
      make.height.equalTo(snp.width).offset(-Margin.super)
    }
    bottomStackView.subviews.forEach { view in
      view.snp.makeConstraints { make in
        let numberOfBottomImages = CGFloat(4)
        let numberOfSpaces = CGFloat(3)
        let height = ((UIScreen.main.bounds.width - Margin.big) - (Margin.small * numberOfSpaces)) / numberOfBottomImages
        make.height.equalTo(height)
      }
    }
    nextButton.snp.makeConstraints { make in
      make.leading.equalTo(self).offset(Margin.medium)
      make.trailing.equalTo(self).offset(-Margin.medium)
      make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-Margin.medium)
    }
  }
  
  // MARK: - Public

  func onImageSelected(image: UIImage, with index: Int) {
    switch index {
    case 1:
      addPhotoBottom1.set(state: .filled(image))
    case 2:
      addPhotoBottom2.set(state: .filled(image))
    case 3:
      addPhotoBottom3.set(state: .filled(image))
    case 4:
      addPhotoBottom4.set(state: .filled(image))
    case 5:
      addPhotoBottom5.set(state: .filled(image))
    default:
      break
    }
  }

  func showImageRemoveAlert(for index: Int) {
    let alert = UIAlertController(
      title: Localize("product_images.delete_confirmation_alert.title", Table.productImages),
      message: Localize("product_images.delete_confirmation_alert.message", Table.productImages),
      preferredStyle: .alert
    )
    
    let deleteAction = UIAlertAction(title: Localize("generic.action.delete", Table.generic), style: .destructive) { [weak self] _ in
      self?.removeImage(at: index)
      self?.imageDeselectionRelay.accept(index)
    }
    let cancelAction = UIAlertAction(title: Localize("generic.action.cancel", Table.generic), style: .cancel)
    
    alert.addAction(deleteAction)
    alert.addAction(cancelAction)
    
    parentViewController?.present(alert, animated: true)
  }
  
  func configureCloseButton() {
    parentViewController?.navigationItem.leftBarButtonItem = closeButton
  }
  
  // MARK: - Private
  
  private func removeImage(at index: Int) {
    switch index {
    case 1:
      addPhotoBottom1.set(state: .empty)
    case 2:
      addPhotoBottom2.set(state: .empty)
    case 3:
      addPhotoBottom3.set(state: .empty)
    case 4:
      addPhotoBottom4.set(state: .empty)
    case 5:
      addPhotoBottom5.set(state: .empty)
    default:
      break
    }
  }
}

// MARK: - View Bindings

extension Reactive where Base: ProductImagesView {
  var nextButtonIsEnabled: Binder<Bool> {
    return base.nextButton.rx.isEnabled
  }
  
  var closeButtonWasTapped: ControlEvent<Void> {
    return base.closeButton.rx.tap
  }
  
  var nextButtonWasTapped: Observable<Void> {
    return base.nextButton.rx.buttonWasTapped
  }
  
  var addImage1WasTapped: Observable<Void> {
    return base.addPhotoBottom1.rx.buttonWasTapped
  }
  
  var addImage2WasTapped: Observable<Void> {
    return base.addPhotoBottom2.rx.buttonWasTapped
  }
  
  var addImage3WasTapped: Observable<Void> {
    return base.addPhotoBottom3.rx.buttonWasTapped
  }
  
  var addImage4WasTapped: Observable<Void> {
    return base.addPhotoBottom4.rx.buttonWasTapped
  }
  
  var addImage5WasTapped: Observable<Void> {
    return base.addPhotoBottom5.rx.buttonWasTapped
  }
}
