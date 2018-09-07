import UI
import RxSwift
import RxCocoa

final class ProductImagesView: View {
  let imageSelectionRelay = BehaviorRelay<UIImage?>(value: nil)
  let imageDeselectionRelay = BehaviorRelay<UIImage?>(value: nil)
  
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
  
  private let addPhotoBottom1 = AddPhotoButton()
  private let addPhotoBottom2 = AddPhotoButton()
  private let addPhotoBottom3 = AddPhotoButton()
  private let addPhotoBottom4 = AddPhotoButton()
  private let addPhotoBottom5 = AddPhotoButton()

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
}

// MARK: - View Bindings

extension Reactive where Base: ProductImagesView {
  var nextButtonIsEnabled: Binder<Bool> {
    return base.nextButton.rx.isEnabled
  }
  
  var nextButtonWasTapped: Observable<Void> {
    return base.nextButton.rx.buttonWasTapped
  }
}
