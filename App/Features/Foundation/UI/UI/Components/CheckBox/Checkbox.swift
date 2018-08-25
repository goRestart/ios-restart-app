import UIKit

private enum ViewLayout {
  static let size = CGSize(width: 24, height: 24)
}

public final class Checkbox: View {
  
  private let checkboxImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  public var isChecked = false {
    didSet {
      configure()
    }
  }
  
  override public func setupView() {
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
  
  private func configure() {
    guard isChecked else {
      checkboxImageView.image = UIImage(named: "icon.checkbox.unchecked", in: .framework, compatibleWith: nil)
      return
    }
    checkboxImageView.image = UIImage(named: "icon.checkbox.checked", in: .framework, compatibleWith: nil)
  }
}
