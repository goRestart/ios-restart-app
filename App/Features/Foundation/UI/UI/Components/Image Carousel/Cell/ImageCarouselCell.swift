import UIKit

final class ImageCarouselCell: CollectionViewCell {
  static let height = UIScreen.main.bounds.width - Margin.super - 20
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = .grease
    return imageView
  }()
  
  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.cancel()
  }
  
  override func setupView() {
    clipsToBounds = true
    layer.cornerRadius = Radius.big
    
    addSubview(imageView)
  }
  
  override func setupConstraints() {
    imageView.snp.makeConstraints { make in
      make.edges.equalTo(self)
    }
  }
  
  func configure(with image: Image) {
    guard let url = image.url else { return }
    imageView.set(url: url)
  }
}
