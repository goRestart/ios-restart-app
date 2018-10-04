import UIKit
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa

final class BulkPostingsPostedViewController: BaseViewController {

    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(R.Asset.CongratsScreenImages.icCloseRed.image, for: .normal)
        return button
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 27)
        label.textColor = .lgBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = R.Strings.bulkPostingCongratsPrimaryLabel
        return label
    }()
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.mediumBodyFont
        label.textColor = UIColor.grayDark
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = R.Strings.bulkPostingCongratsSecondaryLabel
        return label
    }()
    private let mainButton: UIButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .mediumBold))
        button.setTitle(R.Strings.bulkPostingCongratsPostButton, for: .normal)
        return button
    }()
    private let editLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemMediumFont(size: 15)
        label.textColor = UIColor.lgBlack.withAlphaComponent(0.38)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = R.Strings.bulkPostingCongratsListingsSectionLabel
        return label
    }()
    private let listingsCollectionView: UICollectionView = {
        let layout = CollectionViewCenteredFlowLayout()
        layout.itemSize = CGSize(width: 86, height: 144)
        layout.minimumInteritemSpacing = 16
        let collectionView = LGAutoIntrinsicContentSizeCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    private let postIncentivatorView: PostIncentivatorView = {
        return PostIncentivatorView.postIncentivatorView(false, isServicesListing: false)
    }()

    private static let contentContainerShownHeight: CGFloat = 80
    fileprivate let viewModel: BulkPostingsPostedViewModel
    private let disposeBag = DisposeBag()

    private var listings: [Listing] = []

    // MARK: - View lifecycle

    required init(viewModel: BulkPostingsPostedViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationCapturesStatusBarAppearance = true
        setReachabilityEnabled(false)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()
        setupRx()
        setAccesibilityIds()
    }

    // MARK: - Status Bar

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Private methods

    private func setupView() {
        view.backgroundColor = .white
        listingsCollectionView.register(type: BulkPostedListingCell.self)
        scrollView.addSubviewForAutoLayout(containerView)
        view.addSubviewsForAutoLayout([scrollView, closeButton])
        containerView.addSubviewsForAutoLayout([titleLabel, secondaryLabel, mainButton, editLabel, listingsCollectionView,
                                             postIncentivatorView])
        postIncentivatorView.setupIncentiviseView()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeTopAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 45),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Metrics.margin),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Metrics.margin),

            secondaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metrics.shortMargin),
            secondaryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Metrics.margin),
            secondaryLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Metrics.margin),

            mainButton.topAnchor.constraint(equalTo: secondaryLabel.bottomAnchor, constant: 47),
            mainButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            mainButton.heightAnchor.constraint(equalToConstant: 50),
            mainButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 240),

            editLabel.topAnchor.constraint(equalTo: mainButton.bottomAnchor, constant: 41),
            editLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Metrics.margin),
            editLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Metrics.margin),

            listingsCollectionView.topAnchor.constraint(equalTo: editLabel.bottomAnchor, constant: 17),
            listingsCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Metrics.margin),
            listingsCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Metrics.margin),

            postIncentivatorView.topAnchor.constraint(equalTo: listingsCollectionView.bottomAnchor, constant: Metrics.bigMargin),
            postIncentivatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Metrics.margin),
            postIncentivatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Metrics.margin),
            postIncentivatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Metrics.margin),
        ])
    }

    private func setupRx() {

        closeButton.rx.tap.subscribe { _ in
            self.viewModel.input.didTapClose()
        }.disposed(by: disposeBag)

        mainButton.rx.tap.subscribe { _ in
            self.viewModel.input.didTapMainAction()
        }.disposed(by: disposeBag)

        postIncentivatorView.rx.viewTapped.subscribe { _ in
            self.viewModel.input.didTapIncentivate()
        }.disposed(by: disposeBag)

        viewModel.cells.asObservable()
            .bind(to: listingsCollectionView.rx.items) { (collectionView, row, element) in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BulkPostedListingCell.reusableID, for: indexPath) as! BulkPostedListingCell
                cell.setupWith(price: element.price, imageURL: element.image)
                cell.rx.editButtonTapped.subscribe { _ in
                    self.viewModel.input.didTapEditAtIndex(index: row)
                }.disposed(by: cell.disposeBag)
                return cell
        }.disposed(by: disposeBag)
    }

    func setAccesibilityIds() {
        closeButton.set(accessibilityId: .postingInfoCloseButton)
        mainButton.set(accessibilityId: .postingInfoMainButton)
    }
}
