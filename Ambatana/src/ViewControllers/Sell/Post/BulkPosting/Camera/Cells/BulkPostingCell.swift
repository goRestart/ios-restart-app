import LGCoreKit
import LGComponents

class BulkPostingCell: UICollectionViewCell, ReusableCell {

    private enum Layout {
        static let cornerRadius: CGFloat = 10
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let postedCheckImageView: UIImageView = {
        let imageView = UIImageView(image: R.Asset.IconsButtons.icBulkPostingTick.image)
        return imageView
    }()

    private let imageMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blackTextHighAlpha
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func setupUI() {
        cornerRadius = Layout.cornerRadius
        addSubviewsForAutoLayout([imageView, imageMaskView, postedCheckImageView])
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: imageView.topAnchor),
            bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            trailingAnchor.constraint(equalTo: imageView.trailingAnchor),

            centerXAnchor.constraint(equalTo: postedCheckImageView.centerXAnchor),
            centerYAnchor.constraint(equalTo: postedCheckImageView.centerYAnchor),

            topAnchor.constraint(equalTo: imageMaskView.topAnchor),
            bottomAnchor.constraint(equalTo: imageMaskView.bottomAnchor),
            leadingAnchor.constraint(equalTo: imageMaskView.leadingAnchor),
            trailingAnchor.constraint(equalTo: imageMaskView.trailingAnchor)
        ])
    }

    func setupWith(imageURL: URL?) {
        guard let imageURL = imageURL else { return }
        imageView.lg_setImageWithURL(imageURL)
    }
}
