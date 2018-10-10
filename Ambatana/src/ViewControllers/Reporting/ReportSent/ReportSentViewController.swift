import UIKit
import LGComponents
import RxSwift
import RxCocoa

final class ReportSentViewController: BaseViewController {

    private let viewModel: ReportSentViewModel
    private let disposeBag = DisposeBag()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .reportSentTitleText
        label.textColor = .blackText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .bigBodyFont
        label.textColor = .blackText
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let blockButton: LetgoButton = {
        let button = LetgoButton()
        button.addTarget(self, action: #selector(didTapBlockButton), for: .touchUpInside)
        return button
    }()

    private let reviewButton: LetgoButton = {
        let button = LetgoButton()
        button.addTarget(self, action: #selector(didTapReviewButton), for: .touchUpInside)
        return button
    }()

    private var scrollViewBottomInset: CGFloat = 0 {
        didSet {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: scrollViewBottomInset, right: 0)
            scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: scrollViewBottomInset, right: 0)
        }
    }

    private struct Layout {
        static let verticalMargin: CGFloat = 32
        static let imageSize = CGSize(width: 159, height: 159)
        static let buttonAreaHeight: CGFloat = 80
        static let buttonHeight: CGFloat = 50
        static let buttonMarginToCenter: CGFloat = 2.5
    }

    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.9)
        view.isHidden = true
        return view
    }()

    init(viewModel: ReportSentViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
        setupAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setNavBarBackgroundStyle(.transparent(substyle: .light))
        setNavBarBackButton(R.Asset.IconsButtons.navbarClose.image, selector: #selector(didTapClose))
    }

    @objc private func didTapClose() {
        viewModel.didTapClose()
    }

    private func setupUI() {
        disableAutomaticAdjustScrollViewInsets(in: scrollView)
        view.backgroundColor = .white
        view.addSubviewsForAutoLayout([scrollView, bottomContainer])
        scrollView.addSubviewsForAutoLayout([imageView, titleLabel, messageLabel])
        setupConstraints()

        imageView.image = R.Asset.Reporting.rocket.image
    }

    private func setupConstraints() {
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: safeTopAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeBottomAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Layout.imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: Layout.imageSize.height),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Layout.verticalMargin),
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            titleLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: Metrics.margin),
            titleLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -Metrics.margin),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.verticalMargin),
            messageLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            messageLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: Metrics.margin),
            messageLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -Metrics.margin),
            messageLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            bottomContainer.topAnchor.constraint(equalTo: safeBottomAnchor, constant: -Layout.buttonAreaHeight),
            bottomContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupRx() {
        Driver
            .combineLatest(viewModel.showBlockAction.asDriver(),
                           viewModel.showReviewAction.asDriver())
            .drive(onNext: { [weak self] (showBlockAction, showReviewAction) in
                self?.setupActions(showBlockAction: showBlockAction, showReviewAction: showReviewAction)
            })
            .disposed(by: disposeBag)

        viewModel
            .title
            .asObservable()
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel
            .message
            .asObservable()
            .bind(to: messageLabel.rx.attributedText)
            .disposed(by: disposeBag)
    }

    private func setupAccessibilityIds() {
        titleLabel.set(accessibilityId: .reportSentTitle)
        messageLabel.set(accessibilityId: .reportSentMessage)
        blockButton.set(accessibilityId: .reportSentBlockButton)
        reviewButton.set(accessibilityId: .reportSentReviewButton)
    }

    private func setupActions(showBlockAction: Bool, showReviewAction: Bool) {
        let showBlockAction = viewModel.showBlockAction.value
        let showReviewAction = viewModel.showReviewAction.value

        bottomContainer.subviews.forEach { $0.removeFromSuperview() }
        bottomContainer.isHidden = !showBlockAction && !showReviewAction

        scrollViewBottomInset = showBlockAction || showReviewAction ? Layout.buttonAreaHeight : 0

        guard showBlockAction || showReviewAction else { return }

        if showBlockAction { bottomContainer.addSubviewForAutoLayout(blockButton) }
        if showReviewAction { bottomContainer.addSubviewForAutoLayout(reviewButton) }

        if showBlockAction, !showReviewAction {
            blockButton.setStyle(.primary(fontSize: .medium))
            blockButton.setTitle(R.Strings.reportingUserReportSentBlockUserBigButtonTitle, for: .normal)
        } else if showBlockAction, showReviewAction {
            blockButton.setStyle(.secondary(fontSize: .medium, withBorder: true))
            reviewButton.setStyle(.primary(fontSize: .medium))
            blockButton.setTitle(R.Strings.reportingUserReportSentBlockUserSmallButtonTitle, for: .normal)
            reviewButton.setTitle(R.Strings.reportingUserReportSentReviewButtonTitle, for: .normal)
        }

        setupActionsConstraints(showBlockAction: showBlockAction, showReviewAction: showReviewAction)
    }

    private func setupActionsConstraints(showBlockAction: Bool, showReviewAction: Bool) {
        var constraints: [NSLayoutConstraint] = []

        if showBlockAction {
            constraints.append(blockButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight))
            constraints.append(blockButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor,
                                                                constant: Metrics.margin))
            constraints.append(blockButton.leftAnchor.constraint(equalTo: bottomContainer.leftAnchor,
                                                                 constant: Metrics.margin))
        }

        if showReviewAction {
            constraints.append(reviewButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight))
            constraints.append(reviewButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor,
                                                                 constant: Metrics.margin))
            constraints.append(reviewButton.rightAnchor.constraint(equalTo: bottomContainer.rightAnchor,
                                                                   constant: -Metrics.margin))
        }

        if showBlockAction, showReviewAction {
            constraints.append(blockButton.rightAnchor.constraint(equalTo: bottomContainer.centerXAnchor,
                                                                  constant: -Layout.buttonMarginToCenter))
            constraints.append(reviewButton.leftAnchor.constraint(equalTo: bottomContainer.centerXAnchor,
                                                                  constant: Layout.buttonMarginToCenter))
        } else if showBlockAction, !showReviewAction {
            constraints.append(blockButton.rightAnchor.constraint(equalTo: bottomContainer.rightAnchor,
                                                                  constant: -Metrics.margin))
        } else if showReviewAction, !showBlockAction {
            constraints.append(reviewButton.leftAnchor.constraint(equalTo: bottomContainer.leftAnchor,
                                                                  constant: Metrics.margin))
        }

        NSLayoutConstraint.activate(constraints)
    }

    @objc private func didTapBlockButton() {
        viewModel.didTapBlock()
    }

    @objc private func didTapReviewButton() {
        viewModel.didTapReview()
    }
}

extension ReportSentViewController: ReportSentViewModelDelegate { }
