import UI

final class ProductSummaryView: View {
  private let scrollView = UIScrollView()
  private let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = Margin.small
    return stackView
  }()

  private let imageCarousel = ImageCarousel()
  
  private let priceLabel: UILabel = {
    let label = UILabel()
    label.font = .h1
    label.textColor = .primary
    label.text = "35€"
    return label
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .h2
    label.textColor = .darkScript
    label.numberOfLines = 0
    label.text = "StarCraft II: Wings of Liberty el mejor de todos los tiempos"
    return label
  }()
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .body(.regular)
    label.textColor = .darkScript
    label.numberOfLines = 0
    label.text = "Juego en perfecto estado, solamente una semana de uso, solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso., solamente una semana de uso.. (Escucho ofertas/No cambios)"
    return label
  }()
  
  fileprivate let publishButton: FullWidthButton = {
    let button = FullWidthButton()
    let title = "Publicar anuncio ➞"//Localize("signup.button.signup.title", Table.signUp).uppercased()
    button.setTitle(title, for: .normal)
    return button
  }()
  
  override func setupView() {
    addSubview(scrollView)
    
    scrollView.addSubview(imageCarousel)
    
    stackView.addArrangedSubview(priceLabel)
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(descriptionLabel)
    
    scrollView.addSubview(stackView)
    addSubview(publishButton)
  }
  
  override func setupConstraints() {
    scrollView.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(self)
      make.bottom.equalTo(publishButton.snp.top).offset(-Margin.small)
    }
    imageCarousel.snp.makeConstraints { make in
      make.leading.equalTo(self)
      make.trailing.equalTo(self)
      make.top.equalTo(scrollView.snp.top)
    }
    stackView.snp.makeConstraints { make in
      make.leading.equalTo(self).offset(Margin.medium)
      make.trailing.equalTo(self).offset(-Margin.medium)
      make.top.equalTo(imageCarousel.snp.bottom)
      make.bottom.lessThanOrEqualTo(scrollView.snp.bottom)
    }
    publishButton.snp.makeConstraints { make  in
      make.leading.equalTo(self).offset(Margin.medium)
      make.trailing.equalTo(self).offset(-Margin.medium)
      make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-Margin.medium)
    }
  }
}
