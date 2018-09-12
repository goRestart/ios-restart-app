import UIKit
import LGComponents
import RxSwift
import RxCocoa

// TODO: @juolgon Localize all texts

final class P2PPaymentsOfferStatusSellerView: UIView {
    private enum Layout {
        static let contentHorizontalMargin: CGFloat = 24
        static let separatorHorizontalMargin: CGFloat = 12
        static let buttonHeight: CGFloat = 55
        static let buttonBottomMargin: CGFloat = 16
        static let headerTopMargin: CGFloat = 4
        static let separatorTopMargin: CGFloat = 24
        static let separatorBottomMargin: CGFloat = 12
        static let declineButtonWidth: CGFloat = 120
    }

    fileprivate let headerView = P2PPaymentsBuyerHeaderView()
    private let firstLineSeparatorView = P2PPaymentsLineSeparatorView()
    fileprivate let offerFeesView = P2PPaymentsOfferFeesSellerView()
    private let secondLineSeparatorView = P2PPaymentsLineSeparatorView()
    fileprivate let stepListView = P2PPaymentsOfferStatusStepListView()

    fileprivate let declineButton: LetgoButton = {
        let button = LetgoButton(withStyle: .secondary(fontSize: .big, withBorder: true))
        button.setTitle("Decline", for: .normal)
        return button
    }()

    fileprivate let acceptButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.setTitle("Accept", for: .normal)
        return button
    }()

    fileprivate let enterCodeButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.setTitle("Enter code", for: .normal)
        return button
    }()

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
        addSubviewsForAutoLayout([headerView, firstLineSeparatorView, scrollView, declineButton, acceptButton, enterCodeButton])
        scrollView.addSubviewsForAutoLayout([offerFeesView, secondLineSeparatorView, stepListView])
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeTopAnchor, constant: Layout.headerTopMargin),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.contentHorizontalMargin),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.contentHorizontalMargin),

            firstLineSeparatorView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Layout.separatorTopMargin),
            firstLineSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.separatorHorizontalMargin),
            firstLineSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.separatorHorizontalMargin),

            scrollView.topAnchor.constraint(equalTo: firstLineSeparatorView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),

            offerFeesView.widthAnchor.constraint(equalTo: widthAnchor, constant: -2 * Layout.contentHorizontalMargin),
            offerFeesView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Layout.contentHorizontalMargin),
            offerFeesView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: Layout.contentHorizontalMargin),
            offerFeesView.topAnchor.constraint(equalTo: scrollView.topAnchor),

            secondLineSeparatorView.widthAnchor.constraint(equalTo: widthAnchor, constant: -2 * Layout.separatorHorizontalMargin),
            secondLineSeparatorView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Layout.separatorHorizontalMargin),
            secondLineSeparatorView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: Layout.separatorHorizontalMargin),
            secondLineSeparatorView.topAnchor.constraint(equalTo: offerFeesView.bottomAnchor, constant: Layout.separatorTopMargin),

            stepListView.widthAnchor.constraint(equalTo: widthAnchor, constant: -2 * Layout.contentHorizontalMargin),
            stepListView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Layout.contentHorizontalMargin),
            stepListView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: Layout.contentHorizontalMargin),
            stepListView.topAnchor.constraint(equalTo: secondLineSeparatorView.bottomAnchor, constant: Layout.separatorBottomMargin),
            stepListView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            declineButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.contentHorizontalMargin),
            declineButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            declineButton.bottomAnchor.constraint(equalTo: safeBottomAnchor, constant: -Layout.buttonBottomMargin),
            declineButton.widthAnchor.constraint(equalToConstant: Layout.declineButtonWidth),

            acceptButton.leadingAnchor.constraint(equalTo: declineButton.trailingAnchor, constant: Layout.contentHorizontalMargin),
            acceptButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.contentHorizontalMargin),
            acceptButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            acceptButton.bottomAnchor.constraint(equalTo: safeBottomAnchor, constant: -Layout.buttonBottomMargin),

            enterCodeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.contentHorizontalMargin),
            enterCodeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.contentHorizontalMargin),
            enterCodeButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            enterCodeButton.bottomAnchor.constraint(equalTo: safeBottomAnchor, constant: -Layout.buttonBottomMargin),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomInset: CGFloat = {
            guard !acceptButton.isHidden || !enterCodeButton.isHidden else { return 0 }
            return bounds.maxY - acceptButton.frame.minY
        }()
        scrollView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: bottomInset, right: 0)
    }
}

// MARK: - Rx

extension Reactive where Base: P2PPaymentsOfferStatusSellerView {
    var buyerImageURL: Binder<URL?> { return base.headerView.rx.imageURL }
    var headerTitle: Binder<String?> { return base.headerView.rx.title }
    var stepList: Binder<P2PPaymentsOfferStatusStepListState> { return base.stepListView.rx.state }
    var acceptButtonIsHidden: Binder<Bool> { return base.acceptButton.rx.isHidden }
    var declineButtonIsHidden: Binder<Bool> { return base.declineButton.rx.isHidden }
    var enterCodeButtonIsHidden: Binder<Bool> { return base.enterCodeButton.rx.isHidden }
    var grossText: Binder<String?> { return base.offerFeesView.rx.grossText }
    var feeText: Binder<String?> { return base.offerFeesView.rx.feeText }
    var netText: Binder<String?> { return base.offerFeesView.rx.netText }
    var feePercentageText: Binder<String?> { return base.offerFeesView.rx.feePercentageText }
}
