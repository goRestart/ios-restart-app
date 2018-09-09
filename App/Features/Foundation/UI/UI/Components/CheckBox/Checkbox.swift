import UIKit
import RxSwift
import RxCocoa

private enum ViewLayout {
  static let size = CGSize(width: 20, height: 20)
}

public final class Checkbox: UIControl {
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
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupConstraints()
  }
  
  required public init?(coder aDecoder: NSCoder) { fatalError() }
  
  private func setupView() {
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnCheckbox))
    addGestureRecognizer(tapGestureRecognizer)
    addSubview(checkboxImageView)
    configure()
  }
  
  private func setupConstraints() {
    checkboxImageView.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
    snp.makeConstraints { make in
      make.size.equalTo(ViewLayout.size)
    }
  }
  
  @objc private func didTapOnCheckbox() {
    isChecked = !isChecked
    sendActions(for: .valueChanged)
  }
  
  private func configure() {
    guard isChecked else {
      checkboxImageView.image = Images.Checkbox.unchecked
      return
    }
    checkboxImageView.image = Images.Checkbox.checked
  }
}

// MARK: - View Bindings

extension Reactive where Base: Checkbox {
  public var isChecked: ControlProperty<Bool> {
    return base.rx.controlProperty(editingEvents: .valueChanged, getter: { checkbox in
      checkbox.isChecked
    }, setter: { (checkbox, value) in
      checkbox.isChecked = value
    })
  }
}
