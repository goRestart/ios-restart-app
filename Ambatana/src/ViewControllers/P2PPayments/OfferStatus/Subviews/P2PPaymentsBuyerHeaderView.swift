import UIKit
import RxSwift
import RxCocoa
import LGComponents

final class P2PPaymentsBuyerHeaderView: UIView {
    private enum Layout {
        static let imageSize: CGFloat = 74
        static let textLeadingMargin: CGFloat = 12
        static let textTopMargin: CGFloat = 4
    }

    fileprivate let buyerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.cornerRadius = Layout.imageSize / 2
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    fileprivate let title: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .lgBlack
        label.font = UIFont.systemBoldFont(size: 20)
        return label
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewsForAutoLayout([buyerImageView, title])
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buyerImageView.widthAnchor.constraint(equalToConstant: Layout.imageSize),
            buyerImageView.heightAnchor.constraint(equalToConstant: Layout.imageSize),
            buyerImageView.topAnchor.constraint(equalTo: topAnchor),
            buyerImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            buyerImageView.leadingAnchor.constraint(equalTo: leadingAnchor),

            title.leadingAnchor.constraint(equalTo: buyerImageView.trailingAnchor, constant: Layout.textLeadingMargin),
            title.trailingAnchor.constraint(equalTo: trailingAnchor),
            title.topAnchor.constraint(equalTo: buyerImageView.topAnchor, constant: Layout.textTopMargin)
        ])
    }
}

extension Reactive where Base: P2PPaymentsBuyerHeaderView {
    var imageURL: Binder<URL?> {
        return Binder(self.base) { view, imageURL in
            guard let imageURL = imageURL else {
                view.buyerImageView.image = R.Asset.IconsButtons.userPlaceholder.image
                return
            }
            view.buyerImageView.lg_setImageWithURL(imageURL,
                                                   placeholderImage: R.Asset.IconsButtons.userPlaceholder.image,
                                                   completion: nil)
        }
    }

    var title: Binder<String?> { return base.title.rx.text }
}
