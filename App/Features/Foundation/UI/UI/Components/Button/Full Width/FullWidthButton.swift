import UIKit
import SnapKit

private struct AnimationDuration {
  static let highlight = 0.3
}

open class FullWidthButton: UIButton {
  
  public struct Layout {
    public static let height = CGFloat(56)
  }
  
  enum State {
    case normal
    case highlighted
    case disabled
    case loading
  }
 
  private let backgroundGradientLayer: CAGradientLayer = {
    let layer = CAGradientLayer.default
    layer.cornerRadius = Radius.big
    return layer
  }()
  
  private let highlightedView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    view.isUserInteractionEnabled = false
    view.layer.cornerRadius = Radius.big
    return view
  }()
 
  private lazy var loadingActivity: UIActivityIndicatorView = {
    let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    indicatorView.hidesWhenStopped = true
    return indicatorView
  }()
  
  open var isLoading: Bool = false {
    didSet {
      if isLoading { configure(state: .loading) }
      if !isLoading { configure(state: .normal) }
    }
  }
  
  open override var isEnabled: Bool {
    didSet {
      if isEnabled { configure(state: .normal) }
      if !isEnabled { configure(state: .disabled) }
    }
  }
  
  open override var isHighlighted: Bool {
    didSet {
      if isHighlighted { highlight() }
      if !isHighlighted { unhighlight() }
    }
  }
  
  public var radiusDisabled: Bool = false
  
  // MARK: - Init
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  // MARK: - Setup
  
  private func setup() {
    titleLabel?.font = .button
    titleLabel?.textAlignment = .center
    configure(state: .normal)
  }
  
  // MARK: - Title
  
  open override func setTitle(_ title: String?, for state: UIControlState) {
    setAttributedTitle(attributed(title), for: state)
  }
  
  open override func setAttributedTitle(_ title: NSAttributedString?, for state: UIControlState) {
    super.setAttributedTitle(attributed(title?.string), for: state)
  }
  
  private func attributed(_ title: String?) -> NSAttributedString {
    let attributes: [NSAttributedStringKey: Any] = [
      .font: UIFont.button,
      .foregroundColor: UIColor.white
    ]
    guard let title = title else { fatalError("Empty title") }
    return NSAttributedString(string: title, attributes: attributes)
  }
 
  // MARK: - State
  
  private func configure(state: State) {
    switch state {
    case .normal:
      endLoading()
      isUserInteractionEnabled = true
      layer.insertSublayer(backgroundGradientLayer, at: 0)
    case .disabled:
      endLoading()
      isUserInteractionEnabled = false
      backgroundColor = .darkGrey
      backgroundGradientLayer.removeFromSuperlayer()
    case .loading:
      startLoading()
    default: break
    }
    applyConstraints()
  }
  
  // MARK: - Highlight
  
  private func highlight() {
    UIView.animate(withDuration: AnimationDuration.highlight) {
      self.insertSubview(self.highlightedView, belowSubview: self.titleLabel!)
      self.highlightedView.snp.makeConstraints { make in
        make.edges.equalTo(self)
      }
    }
  }
  
  private func unhighlight() {
    UIView.animate(withDuration: AnimationDuration.highlight) {
      self.highlightedView.removeFromSuperview()
    }
  }
  
  // MARK: - Loading
  
  private func startLoading() {
    titleLabel?.alpha = 0
    addSubview(loadingActivity)
    
    loadingActivity.startAnimating()
    loadingActivity.snp.makeConstraints { make in
      make.center.equalTo(self)
    }
  }
  
  private func endLoading() {
    guard loadingActivity.isAnimating else { return }
    loadingActivity.stopAnimating()
    titleLabel?.alpha = 1
    loadingActivity.removeFromSuperview()
  }
  
  // MARK: - Layout
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    let cornerRadius = radiusDisabled ? 0 : Radius.big
    
    backgroundGradientLayer.frame = bounds
    backgroundGradientLayer.cornerRadius = cornerRadius
    
    highlightedView.layer.cornerRadius = cornerRadius
    
    layer.cornerRadius = cornerRadius
  }
  
  private func applyConstraints() {
    titleLabel?.snp.remakeConstraints { make in
      let edge = UIEdgeInsets(top: Margin.medium, left: Margin.small, bottom: Margin.medium, right: Margin.small)
      make.edges.equalTo(self).inset(edge)
    }
    snp.makeConstraints { make in
      make.height.equalTo(Layout.height)
    }
  }
}
