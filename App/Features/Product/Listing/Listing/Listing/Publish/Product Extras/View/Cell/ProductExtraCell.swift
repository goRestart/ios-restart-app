import UI
import SnapKit

final class ProductExtraCell: CollectionViewCell {
  
  static let height = CGFloat(48)
  
  private let typeLabel: UILabel = {
    let label = UILabel()
    label.font = .body(.semibold)
    label.textColor = .darkScript
    label.numberOfLines = 0
    return label
  }()
  
  private let selectionCheckBox = Checkbox()
  
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
