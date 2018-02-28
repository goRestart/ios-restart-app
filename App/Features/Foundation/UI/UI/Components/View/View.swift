import UIKit

open class View: UIView {

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  @available(*, unavailable)
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public init() {
    super.init(frame: .zero)
    setup()
  }
  
  private func setup() {
    backgroundColor = .white
    setupView()
    setupConstraints()
  }
  
  open func setupView() {
    fatalError("`View` subclasses should implement \(#function) ⚠️")
  }
  
  open func setupConstraints() {
    fatalError("`View` subclasses should implement \(#function) ⚠️")
  }
}
