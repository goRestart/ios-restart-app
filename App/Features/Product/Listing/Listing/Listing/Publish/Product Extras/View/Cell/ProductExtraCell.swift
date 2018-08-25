import UI
import SnapKit
import RxSwift
import RxCocoa

final class ProductExtraCell: CollectionViewCell {
  
  static let height = CGFloat(48)
  
  private let typeLabel: UILabel = {
    let label = UILabel()
    label.font = .body(.semibold)
    label.textColor = .darkScript
    label.numberOfLines = 0
    return label
  }()
  
  fileprivate let selectionCheckBox = Checkbox()

  override func setupView() {
    addSubview(typeLabel)
    addSubview(selectionCheckBox)
    
    backgroundColor = .darkWhite
    layer.cornerRadius = Radius.big
  }
  
  override func setupConstraints() {
    typeLabel.snp.makeConstraints { make in
      make.leading.equalTo(self).offset(Margin.medium)
      make.centerY.equalTo(self)
      make.trailing.equalTo(selectionCheckBox.snp.leading).offset(-Margin.medium)
    }
    selectionCheckBox.snp.makeConstraints { make in
      make.trailing.equalTo(self).offset(-Margin.medium)
      make.centerY.equalTo(self)
    }
  }
  
  func configure(with productExtra: ProductExtraUIModel) {
    typeLabel.text = productExtra.type
    selectionCheckBox.isChecked = productExtra.isSelected
  }
}

// MARK: - View bindings

extension Reactive where Base: ProductExtraCell {
  var isChecked: ControlProperty<Bool> {
    return base.selectionCheckBox.rx.isChecked
  }
}
