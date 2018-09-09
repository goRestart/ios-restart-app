import UIKit
import SnapKit
import RxSwift
import RxCocoa

public enum AddPhotoButtonState {
  case filled(UIImage)
  case empty
}

public final class AddPhotoButton: View {
  fileprivate let addButton: UIButton = {
    let button = UIButton()
    button.setImage(Images.Buttons.addPlus , for: .normal)
    button.tintColor = .softScript
    return button
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.isHidden = true
    return imageView
  }()

  @available(*, unavailable)
  public override func setupView() {
    backgroundColor = .grease
    layer.cornerRadius = Radius.big
    clipsToBounds = true
    addSubview(addButton)
    addSubview(imageView)
  }

  @available(*, unavailable)
  public override func setupConstraints() {
    addButton.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
    imageView.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
  }
  
  public func set(state: AddPhotoButtonState) {
    switch state {
    case .filled(let image):
      imageView.isHidden = false
      imageView.image = image
    case .empty:
      imageView.isHidden = true
      imageView.image = nil
    }
  }
}

// MARK: - View Bindings

extension Reactive where Base: AddPhotoButton {
  public var buttonWasTapped: Observable<Void> {
    return base.addButton.rx.buttonWasTapped
  }
}
