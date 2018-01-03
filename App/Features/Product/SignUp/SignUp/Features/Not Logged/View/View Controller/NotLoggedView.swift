import UI
import SnapKit

private struct ViewLayout {
  static let logoWidth = 65.8
  static let logoHeight = 79.2
  static let buttonHeight = 48.0
}

final class NotLoggedView: View {
  
  private let logoImageView: UIImageView = {
    let bundle = Bundle(for: NotLoggedView.self)
    let image = UIImage(named: "icon_logo", in: bundle, compatibleWith: nil)
    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .h2
    label.textColor = .darkScript
    label.textAlignment = .center
    label.numberOfLines = 0
    label.text = Localize("not_logged.label.welcome.title", Table.signUp)
    return label
  }()

  let createAccountButton: LargeButton = {
    let button = LargeButton()
    let title = Localize("not_logged.button.create_account.title", Table.signUp).uppercased()
    button.setTitle(title, for: .normal)
    return button
  }()
  
  let loginButton: LargeButton = {
    let button = LargeButton()
    button.type = .alt
    let title = Localize("not_logged.button.login.title", Table.signUp).uppercased()
    button.setTitle(title, for: .normal)
    return button
  }()
  
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.distribution = .equalSpacing
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.spacing = Margin.huge
    return stackView
  }()
  
  private let topElementsStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.distribution = .equalSpacing
    stackView.axis = .vertical
    stackView.spacing = Margin.medium
    return stackView
  }()
  
  private let buttonsStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.distribution = .equalSpacing
    stackView.axis = .vertical
    stackView.spacing = Margin.small
    return stackView
  }()
  
  override func setupView() {
    stackView.addArrangedSubview(logoImageView)
    topElementsStackView.addArrangedSubview(titleLabel)
    
    buttonsStackView.addArrangedSubview(createAccountButton)
    buttonsStackView.addArrangedSubview(loginButton)
  
    stackView.addArrangedSubview(topElementsStackView)
    stackView.addArrangedSubview(buttonsStackView)
    
    addSubview(stackView)
  }
  
  override func setupConstraints() {
    logoImageView.snp.makeConstraints { make in
      make.width.equalTo(ViewLayout.logoWidth)
      make.height.equalTo(ViewLayout.logoHeight)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(self).offset(Margin.super)
      make.right.equalTo(self).offset(-Margin.super)
    }
    
    [createAccountButton, loginButton].forEach { button in
      button.snp.makeConstraints { make in
        make.left.equalTo(self).offset(Margin.super)
        make.right.equalTo(self).offset(-Margin.super)
        make.height.equalTo(ViewLayout.buttonHeight)
      }
    }
    
    stackView.snp.makeConstraints { make in
      make.center.equalTo(self)
    }
  }
}
