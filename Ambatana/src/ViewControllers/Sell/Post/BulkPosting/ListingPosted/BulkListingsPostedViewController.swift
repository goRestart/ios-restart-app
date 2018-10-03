import UIKit
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa

final class BulkListingsPostedViewController: BaseViewController {

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
        let collectionView = LGIntrinsicSizeCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    private let postIncentivatorView: PostIncentivatorView = {
        return PostIncentivatorView.postIncentivatorView(false, isServicesListing: false)
    }()

    private static let contentContainerShownHeight: CGFloat = 80
    fileprivate let viewModel: BulkListingsPostedViewModel
    private let disposeBag = DisposeBag()

    private var listings: [Listing] = []

    // MARK: - View lifecycle

    required init(viewModel: BulkListingsPostedViewModel) {
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

class LGIntrinsicSizeCollectionView: UICollectionView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !bounds.size.equalTo(intrinsicContentSize) {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        get {
            return contentSize
        }
    }

    private func setup() {
        self.isScrollEnabled = false
        self.bounces = false
    }
}

final class CollectionViewCenteredFlowLayout: UICollectionViewFlowLayout {
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layoutAttributesForElements = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        guard let collectionView = collectionView else {
            return layoutAttributesForElements
        }
        // we group copies of the elements from the same row/column
        var representedElements: [UICollectionViewLayoutAttributes] = []
        var cells: [[UICollectionViewLayoutAttributes]] = [[]]
        var previousFrame: CGRect?
        if scrollDirection == .vertical {
            for layoutAttributes in layoutAttributesForElements {
                guard layoutAttributes.representedElementKind == nil else {
                    representedElements.append(layoutAttributes)
                    continue
                }
                // copying is required to avoid "UICollectionViewFlowLayout cache mismatched frame"
                let currentItemAttributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
                // if the current frame, once stretched to the full row doesn't intersect the previous frame then they are on different rows
                if previousFrame != nil && !currentItemAttributes.frame.intersects(CGRect(x: -.greatestFiniteMagnitude, y: previousFrame!.origin.y, width: .infinity, height: previousFrame!.size.height)) {
                    cells.append([])
                }
                cells[cells.endIndex - 1].append(currentItemAttributes)
                previousFrame = currentItemAttributes.frame
            }
            // we reposition all elements
            return representedElements + cells.flatMap { group -> [UICollectionViewLayoutAttributes] in
                guard let section = group.first?.indexPath.section else {
                    return group
                }
                let evaluatedSectionInset = evaluatedSectionInsetForSection(at: section)
                let evaluatedMinimumInteritemSpacing = evaluatedMinimumInteritemSpacingForSection(at: section)
                var origin = (collectionView.bounds.width + evaluatedSectionInset.left - evaluatedSectionInset.right - group.reduce(0, { $0 + $1.frame.size.width }) - CGFloat(group.count - 1) * evaluatedMinimumInteritemSpacing) / 2
                // we reposition each element of a group
                return group.map {
                    $0.frame.origin.x = origin
                    origin += $0.frame.size.width + evaluatedMinimumInteritemSpacing
                    return $0
                }
            }
        } else {
            for layoutAttributes in layoutAttributesForElements {
                guard layoutAttributes.representedElementKind == nil else {
                    representedElements.append(layoutAttributes)
                    continue
                }
                // copying is required to avoid "UICollectionViewFlowLayout cache mismatched frame"
                let currentItemAttributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
                // if the current frame, once stretched to the full column doesn't intersect the previous frame then they are on different columns
                if previousFrame != nil && !currentItemAttributes.frame.intersects(CGRect(x: previousFrame!.origin.x, y: -.greatestFiniteMagnitude, width: previousFrame!.size.width, height: .infinity)) {
                    cells.append([])
                }
                cells[cells.endIndex - 1].append(currentItemAttributes)
                previousFrame = currentItemAttributes.frame
            }
            // we reposition all elements
            return representedElements + cells.flatMap { group -> [UICollectionViewLayoutAttributes] in
                guard let section = group.first?.indexPath.section else {
                    return group
                }
                let evaluatedSectionInset = evaluatedSectionInsetForSection(at: section)
                let evaluatedMinimumInteritemSpacing = evaluatedMinimumInteritemSpacingForSection(at: section)
                var origin = (collectionView.bounds.height + evaluatedSectionInset.top - evaluatedSectionInset.bottom - group.reduce(0, { $0 + $1.frame.size.height }) - CGFloat(group.count - 1) * evaluatedMinimumInteritemSpacing) / 2
                // we reposition each element of a group
                return group.map {
                    $0.frame.origin.y = origin
                    origin += $0.frame.size.height + evaluatedMinimumInteritemSpacing
                    return $0
                }
            }
        }
    }
}

extension UICollectionViewFlowLayout {
    internal func evaluatedSectionInsetForSection(at section: Int) -> UIEdgeInsets {
        return (collectionView?.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView!, layout: self, insetForSectionAt: section) ?? sectionInset
    }
    internal func evaluatedMinimumInteritemSpacingForSection(at section: Int) -> CGFloat {
        return (collectionView?.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: section) ?? minimumInteritemSpacing
    }
}
