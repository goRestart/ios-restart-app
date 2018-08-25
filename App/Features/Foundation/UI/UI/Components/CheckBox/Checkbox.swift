import UIKit

private enum ViewLayout {
  static let size = CGSize(width: 20, height: 20)
}

public final class Checkbox: View {
  private let checkboxImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .softScript
    return imageView
  }()
  
  public var isChecked = false {
    didSet {
      configure()
    }
  }
  
  override public func setupView() {
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnCheckbox))
    addGestureRecognizer(tapGestureRecognizer)
    addSubview(checkboxImageView)
    configure()
  }
  
  override public func setupConstraints() {
    checkboxImageView.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
    snp.makeConstraints { make in
      make.size.equalTo(ViewLayout.size)
    }
  }
  
  @objc private func didTapOnCheckbox() {
    isChecked = !isChecked
  }
  
  private func configure() {
    guard isChecked else {
      checkboxImageView.image = UIImage(named: "icon.checkbox.unchecked", in: .framework, compatibleWith: nil)
      return
    }
    checkboxImageView.image = UIImage(named: "icon.checkbox.checked", in: .framework, compatibleWith: nil)
  }
}
