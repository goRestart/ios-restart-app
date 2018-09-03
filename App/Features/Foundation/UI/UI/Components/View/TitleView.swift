import UIKit

public final class TitleView: View {
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .h1
    label.textColor = .darkScript
    label.numberOfLines = 0
    return label
  }()
  
  public var title: String? {
    get { return titleLabel.text }
    set { titleLabel.text = newValue }
  }
  
  override public func setupView() {
    addSubview(titleLabel)
  }
  
  override public func setupConstraints() {
    titleLabel.snp.makeConstraints { make in
      make.edges.equalTo(self)
        .inset(UIEdgeInsets.init(top: 0, left: Margin.medium, bottom: 0, right: Margin.medium))
    }
  }
}
