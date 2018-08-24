import UIKit
import RxSwift
import RxCocoa

final class P2PPaymentsListingHeaderView: UIView {
    private enum Layout {
        static let imageSize: CGFloat = 74
        static let textLeadingMargin: CGFloat = 12
        static let textTopMargin: CGFloat = 4
    }

    fileprivate let listingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    fileprivate let listingTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .lgBlack
        label.font = UIFont.systemBoldFont(size: 20)
        return label
    }()

    init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewsForAutoLayout([listingImageView, listingTitle])
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            listingImageView.widthAnchor.constraint(equalToConstant: Layout.imageSize),
            listingImageView.heightAnchor.constraint(equalToConstant: Layout.imageSize),
            listingImageView.topAnchor.constraint(equalTo: topAnchor),
            listingImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            listingImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            listingTitle.leadingAnchor.constraint(equalTo: listingImageView.trailingAnchor, constant: Layout.textLeadingMargin),
            listingTitle.trailingAnchor.constraint(equalTo: trailingAnchor),
            listingTitle.topAnchor.constraint(equalTo: listingImageView.topAnchor, constant: Layout.textTopMargin)
        ])
    }
}

extension Reactive where Base: P2PPaymentsListingHeaderView {
    var imageURL: Binder<URL?> {
        return Binder(self.base) { view, imageURL in
            guard let imageURL = imageURL else { return }
            view.listingImageView.lg_setImageWithURL(imageURL)
        }
    }

    var title: Binder<String?> {
        return base.listingTitle.rx.text
    }
}
