import UIKit

final class SimpleImageListingCell: UICollectionViewCell {

    private let listingImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .blue
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }

    private func setupConstraints() {
        contentView.addSubviewForAutoLayout(listingImage)
        listingImage.layout(with: contentView).fill()
    }
}
