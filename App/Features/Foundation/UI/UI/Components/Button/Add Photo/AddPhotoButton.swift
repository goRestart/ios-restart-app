import UIKit
import SnapKit
import RxSwift
import RxCocoa

public final class AddPhotoButton: View {
  fileprivate let addButton: UIButton = {
    let button = UIButton()
    let addPlusImage = UIImage(named: "add_plus.icon", in: .framework, compatibleWith: nil)!
    button.setImage(addPlusImage , for: .normal)
    button.tintColor = .softScript
    return button
  }()

  @available(*, unavailable)
  public override func setupView() {
    backgroundColor = .grease
    layer.cornerRadius = Radius.big
    addSubview(addButton)
  }

  public override func setupConstraints() {
    addButton.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
  }
}

// MARK: - View Bindings

extension Reactive where Base: AddPhotoButton {
  public var buttonWasTapped: Observable<Void> {
    return base.addButton.rx.buttonWasTapped
  }
}
