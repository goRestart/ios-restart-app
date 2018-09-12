import UI
import RxSwift
import RxCocoa

final class ProductSummaryView: View {
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    return scrollView
  }()
 
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = Margin.small
    return stackView
  }()

  fileprivate let imageCarousel = ImageCarousel()
  
  fileprivate let priceLabel: UILabel = {
    let label = UILabel()
    label.font = .h1
    label.textColor = .primary
    return label
  }()
  
  fileprivate let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .h2
    label.textColor = .darkScript
    label.numberOfLines = 0
    return label
  }()
  
  fileprivate let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .body(.regular)
    label.textColor = .darkScript
    label.numberOfLines = 0
    return label
  }()
  
  fileprivate let publishButton: FullWidthButton = {
    let button = FullWidthButton()
    let title = Localize("product_summary.button.publish.title", Table.productSummary).uppercased()
    button.setTitle(title, for: .normal)
    return button
  }()
  
  override func setupView() {
    addSubview(scrollView)
    
    scrollView.addSubview(imageCarousel)
    
    stackView.addArrangedSubview(priceLabel)
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(descriptionLabel)
    
    scrollView.addSubview(stackView)
    addSubview(publishButton)
  }
  
  override func setupConstraints() {
    scrollView.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(self)
      make.bottom.equalTo(publishButton.snp.top).offset(-Margin.small)
    }
    imageCarousel.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(scrollView.snp.top)
    }
    stackView.snp.makeConstraints { make in
      make.leading.equalTo(self).offset(Margin.medium)
      make.trailing.equalTo(self).offset(-Margin.medium)
      make.top.equalTo(imageCarousel.snp.bottom)
      make.bottom.lessThanOrEqualTo(scrollView.snp.bottom)
    }
    publishButton.snp.makeConstraints { make  in
      make.leading.equalTo(self).offset(Margin.medium)
      make.trailing.equalTo(self).offset(-Margin.medium)
      make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-Margin.medium)
    }
  }
}

// MARK: - View bindings

extension Reactive where Base: ProductSummaryView {
  var productDraft: Binder<ProductDraftUIModel?> {
    return Binder(self.base) { view, productDraft in
      view.titleLabel.text = productDraft?.title
      view.descriptionLabel.text = productDraft?.description
      view.priceLabel.text = productDraft?.price
      
      guard let images = productDraft?.images else { return }
      view.imageCarousel.set(images)
    }
  }
}
