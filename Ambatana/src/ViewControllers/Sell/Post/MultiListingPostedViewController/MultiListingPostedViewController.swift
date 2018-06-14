import UIKit
import LGComponents
import RxSwift
import RxCocoa
import LGCoreKit

final class MultiListingPostedViewController: BaseViewController {
    
    private typealias ListingCell = MultiListingPostedListingCell
    private typealias HeaderCell = MultiListingPostedHeaderCell
    private typealias CongratsCell = MultiListingPostedCongratsCell
    private typealias PostIncentivisorCell = MultiListingPostedIncentivisorCell
    
    private let viewModel: MultiListingPostedViewModel
    private let disposeBag = DisposeBag()
    
    private struct Layout {
        static let closeButtonSize: CGSize = CGSize(width: 18.0, height: 18.0)
        static let loadingIndicatorSize: CGSize = CGSize(width: 100, height: 100)
        static let loadingIndicatorYOffset: CGFloat = -100
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize.zero
        
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        
        return collectionView
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(R.Asset.CongratsScreenImages.icCloseRed.image,
                        for: .normal)
        return button
    }()
    
    private let loadingIndicator: LoadingIndicator = {
        let loadingIndicator = LoadingIndicator(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: Layout.loadingIndicatorSize.width,
                                                              height: Layout.loadingIndicatorSize.height))
        loadingIndicator.isHidden = true
        loadingIndicator.color = UIColor.primaryColor
        return loadingIndicator
    }()
    
    
    // MARK:- Lifecycle
    
    init(viewModel: MultiListingPostedViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupView()
        setupCollectionView()
        setupCloseButton()
        setAccesibilityIds()
        setupRx()
        viewModel.viewDidLoad()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK:- Public methods
    func listingEdited(listing: Listing) {
        viewModel.listingEdited(listing: listing)
    }
}


// MARK:- Setup

extension MultiListingPostedViewController {
    
    private func registerCells() {
        collectionView.register(type: CongratsCell.self)
        collectionView.register(HeaderCell.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: HeaderCell.reusableID)
        collectionView.register(type: ListingCell.self)
        collectionView.register(type: PostIncentivisorCell.self)
    }
    
    private func setAccesibilityIds() {
        closeButton.set(accessibilityId: .postingInfoCloseButton)
        collectionView.set(accessibilityId: .postingInfoCollectionView)
    }

    private func setupView() {
        modalTransitionStyle = .crossDissolve
        modalPresentationCapturesStatusBarAppearance = true
        view.backgroundColor = UIColor.white
        setNeedsStatusBarAppearanceUpdate()
        setReachabilityEnabled(false)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        registerCells()
    }
    
    private func setupCloseButton() {
        closeButton.addTarget(viewModel,
                              action: #selector(viewModel.closeButtonTapped),
                              for: .touchUpInside)
    }
    
    private func setupRx() {
        viewModel.statusDriver.drive(onNext: { [weak self] (status) in
            DispatchQueue.main.async {
                switch status {
                case .error, .success:
                    self?.stopLoading(success: status.success)
                    self?.collectionView.reloadData()
                case .servicesPosting, .servicesImageUpload:
                    self?.startLoading()
                    self?.collectionView.reloadData()
                }
            }

        }).disposed(by: disposeBag)
    }
}


// MARK:- Layout

extension MultiListingPostedViewController {
    
    private func setupConstraints() {
        view.addSubviewsForAutoLayout([
            collectionView,
            closeButton,
            loadingIndicator
            ])
        
        collectionView.layout(with: view)
            .fillHorizontal()
            .bottom(to: .bottom)
        collectionView.topAnchor.constraint(equalTo: safeTopAnchor,
                                            constant: 2*Metrics.veryBigMargin).isActive = true
        
        closeButton.layout()
            .width(Layout.closeButtonSize.width)
            .height(Layout.closeButtonSize.height)
        
        closeButton.layout(with: view)
            .left(to: .left, by: Metrics.bigMargin)
        
        closeButton.topAnchor.constraint(equalTo: safeTopAnchor,
                                         constant: Metrics.bigMargin).isActive = true
        
        loadingIndicator.layout()
            .width(Layout.loadingIndicatorSize.width)
            .height(Layout.loadingIndicatorSize.height)
        
        loadingIndicator.layout(with: view)
            .centerX()
            .centerY(by: Layout.loadingIndicatorYOffset)
    }
}


// MARK:- Loading Methods

extension MultiListingPostedViewController {
    
    private func startLoading() {
        hideAllElements()
        
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
    }
    
    private func stopLoading(success: Bool) {
        showAllElements()
        
        loadingIndicator.stopAnimating(correctState: success)
        loadingIndicator.isHidden = true
    }
    
    private func hideAllElements() {
        collectionView.isHidden = true
        collectionView.isUserInteractionEnabled = false
    }
    
    private func showAllElements() {
        collectionView.isHidden = false
        collectionView.isUserInteractionEnabled = true
    }
}


// MARK: UICollectionViewDataSource Implementation

extension MultiListingPostedViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(inSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = viewModel.viewItem(forIndex: indexPath) else {
            return UICollectionViewCell()
        }
        
        switch item {
        case .congrats(let title, let subtitle, let actionText):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CongratsCell.reusableID,
                                                                for: indexPath) as? CongratsCell else {
                                                                    return UICollectionViewCell()
            }
            cell.setup(withTitle: title,
                       subtitle: subtitle,
                       actionButtonText: actionText,
                       tapAction: { [weak self, indexPath] in
                        self?.viewModel.itemTapped(atIndex: indexPath)
            })
            return cell
        case .listingItem(let listing):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListingCell.reusableID,
                                                                for: indexPath) as? ListingCell else {
                                                                    return UICollectionViewCell()
            }
            cell.setup(withListing: listing,
                       editAction: { [weak self, indexPath] in
                        self?.viewModel.itemTapped(atIndex: indexPath)
            })
            return cell
        case .postIncentivisor(let isFreePosting):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostIncentivisorCell.reusableID,
                                                                for: indexPath) as? PostIncentivisorCell else {
                                                                    return UICollectionViewCell()
            }
            
            cell.setup(isFreePosting: isFreePosting,
                       withTapAction: { [weak self, indexPath] in
                        self?.viewModel.itemTapped(atIndex: indexPath)
            })
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            guard let headerItem = viewModel.headerItem(forSection: indexPath.section),
                let cell = makeHeaderCell(forHeaderItem: headerItem,
                                      inCollectionView: collectionView,
                                      atIndexPath: indexPath) else {
                                        return UICollectionReusableView()
            }
            return cell
        default: return UICollectionReusableView()
        }
    }
    
    private func makeHeaderCell(forHeaderItem headerItem: MultiListingPostedHeaderItem,
                                inCollectionView collectionView: UICollectionView,
                                atIndexPath indexPath: IndexPath) -> HeaderCell? {
        switch headerItem {
        case .header(let title, let textAlignment):
            guard let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                       withReuseIdentifier: HeaderCell.reusableID,
                                                                       for: indexPath) as? HeaderCell else {
                                                                        return nil
            }
            cell.setup(withText: title, alignment: textAlignment)
            return cell
        }
    }
}


// MARK: UICollectionViewDelegate Implementation

extension MultiListingPostedViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.itemTapped(atIndex: indexPath)
    }
}


// MARK: UICollectionViewDelegateFlowLayout

extension MultiListingPostedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.sizeForItem(atIndex: indexPath,
                                     inCollectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return viewModel.sizeForHeader(inSection: section,
                                       inCollectionView: collectionView)
    }
}
