import UIKit
import LGComponents
import RxSwift
import RxCocoa

final class P2PPaymentsOfferStatusBuyerView: UIView {
    private enum Layout {
        static let contentHorizontalMargin: CGFloat = 24
        static let separatorHorizontalMargin: CGFloat = 12
        static let buttonHeight: CGFloat = 55
        static let buttonBottomMargin: CGFloat = 16
        static let headerTopMargin: CGFloat = 4
        static let separatorTopMargin: CGFloat = 24
        static let separatorBottomMargin: CGFloat = 12
    }

    fileprivate let headerView = P2PPaymentsListingHeaderView()
    private let lineSeparatorView = P2PPaymentsLineSeparatorView()
    fileprivate let stepListView = P2PPaymentsOfferStatusStepListView()
    fileprivate let actionButton = LetgoButton(withStyle: .primary(fontSize: .big))
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewsForAutoLayout([headerView, lineSeparatorView, scrollView, actionButton])
        scrollView.addSubviewForAutoLayout(stepListView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeTopAnchor, constant: Layout.headerTopMargin),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.contentHorizontalMargin),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.contentHorizontalMargin),

            lineSeparatorView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Layout.separatorTopMargin),
            lineSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.separatorHorizontalMargin),
            lineSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.separatorHorizontalMargin),

            stepListView.widthAnchor.constraint(equalTo: widthAnchor, constant: -2 * Layout.contentHorizontalMargin),
            stepListView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Layout.contentHorizontalMargin),
            stepListView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: Layout.contentHorizontalMargin),
            stepListView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stepListView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: lineSeparatorView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.contentHorizontalMargin),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.contentHorizontalMargin),
            actionButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            actionButton.bottomAnchor.constraint(equalTo: safeBottomAnchor, constant: -Layout.buttonBottomMargin),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomInset: CGFloat = {
            guard !actionButton.isHidden else { return 0 }
            return bounds.maxY - actionButton.frame.minY
        }()
        scrollView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: bottomInset, right: 0)
    }
}

// MARK: - Rx

extension Reactive where Base: P2PPaymentsOfferStatusBuyerView {
    var listingImageURL: Binder<URL?> { return base.headerView.rx.imageURL }
    var listingTitle: Binder<String?> { return base.headerView.rx.title }
    var stepList: Binder<P2PPaymentsOfferStatusStepListState> { return base.stepListView.rx.state }
    var actionButtonTitle: Binder<String?> { return base.actionButton.rx.title() }
    var actionButtonIsHidden: Binder<Bool> { return base.actionButton.rx.isHidden }
}

