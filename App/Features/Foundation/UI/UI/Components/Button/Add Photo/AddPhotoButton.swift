import UIKit
import SnapKit

private enum ViewLayout {
  static let minWidth = CGFloat(30)
  static let minHeight = CGFloat(30)
}

public final class AddPhotoButton: View {

  public typealias OnButtonSelected = (UIButton) -> Void

  private var addButton: UIButton = {
    let button = UIButton()
    let addPlusImage = UIImage(named: "add_plus.icon", in: .framework, compatibleWith: nil)!
    button.setImage(addPlusImage , for: .normal)
    button.tintColor = .softScript
    return button
  }()

  public var onSelected: OnButtonSelected?

  public override func setupView() {
    backgroundColor = .grease
    layer.cornerRadius = Radius.big
    addSubview(addButton)
    addButton.addTarget(self, action: #selector(onButtonSelected(_:)), for: .touchUpInside)
  }

  public override func setupConstraints() {
    addButton.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
  }

  @objc private func onButtonSelected(_ sender: UIButton) {
    onSelected?(sender)
  }
}
