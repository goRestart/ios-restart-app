import IGListKit
import LGCoreKit

protocol HorizontalSectionDelegate: class {
    func didTapSeeAll(page: SearchType, section: UInt, identifier: String)
}

final class HorizontalSectionController: ListSectionController {

    enum Constants {
        static let bigCellVariation: CGFloat = 2.4
        static let smallCellVariation: CGFloat = 3.6
    }
    
    private var listingHorizontalSectionModel: ListingSectionModel?
    weak var listingActionDelegate: ListingActionDelegate?
    weak var delegate: HorizontalSectionDelegate?
    
    private var scrollOffset: CGFloat = -SectionControllerLayout.sectionInset.left

    private lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(),
                                  viewController: self.viewController)
        adapter.dataSource = self
        adapter.collectionViewDelegate = self
        adapter.scrollViewDelegate = self
        return adapter
    }()

    private let featureFlags: FeatureFlaggeable
    
    init(featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.featureFlags = featureFlags
        super.init()
        supplementaryViewSource = self
        minimumInteritemSpacing = SectionControllerLayout.fixedListingSpacing
    }

    override func sizeForItem(at index: Int) -> CGSize {
        let screenWidth = collectionContext?.containerSize.width ?? 0
        let sectionHeight = horizontalSectionHeight(forScreenWidth: screenWidth)
        return CGSize(width: screenWidth,
                      height: sectionHeight)
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?
            .dequeueReusableCell(of: EmbeddedCollectionViewCell.self,
                                 for: self,
                                 at: index) as? EmbeddedCollectionViewCell
            else { fatalError() }
        adapter.collectionView = cell.collectionView

        cell.collectionView.setContentOffset(
            CGPoint(x: scrollOffset,
                    y: cell.collectionView.contentOffset.y),
            animated: false
        )
        
        return cell
    }

    override func didUpdate(to object: Any) {
        listingHorizontalSectionModel = (object as? DiffableBox<ListingSectionModel>)?.value
    }
    
    private func horizontalSectionHeight(forScreenWidth width: CGFloat) -> CGFloat {
        let variant = featureFlags.sectionedFeedABTestIntValue
        return variant%2 == 0 ? width / Constants.bigCellVariation : width / Constants.smallCellVariation
    }
}


// MARK:- Adapter Datasource

extension HorizontalSectionController: ListAdapterDataSource {

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let items = listingHorizontalSectionModel?.items else { return [] }
        return items.listDiffable()
    }

    func listAdapter(_ listAdapter: ListAdapter,
                     sectionControllerFor object: Any) -> ListSectionController {
        let vm = EmbeddedListingViewModel()
        let sectionController = EmbeddedListingSectionController(embeddedListingViewModel: vm)
        sectionController.listingActionDelegate = listingActionDelegate
        sectionController.interestedActionDelegate = self
        return sectionController
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}


// MARK:- Adapter CollectionViewDelegate

extension HorizontalSectionController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = listingHorizontalSectionModel,
            let cell = collectionView.cellForItem(at: indexPath) as? FeedListingCell else { return }
        let embeddedCollectionViewCell = collectionContext?.cellForItem(at: 0, sectionController: self)
        let originalFrame = embeddedCollectionViewCell?.convert(cell.frame, to: nil) ?? .zero
        listingActionDelegate?.didSelectListing(model.items[indexPath.section].listing,
                                                thumbnailImage: cell.thumbnailImage,
                                                originFrame: originalFrame,
                                                index: indexPath.section,
                                                sectionIdentifier: model.id,
                                                sectionIndex: model.sectionPosition.index,
                                                itemIdentifier: model.listDiffable())
    }
}

extension HorizontalSectionController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollOffset = scrollView.contentOffset.x
    }
}

// MARK:- SupplementaryView Datasource

extension HorizontalSectionController: ListSupplementaryViewSource {
    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }

    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        guard let view = collectionContext?
            .dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                              for: self,
                                              class: SectionTitleHeaderView.self,
                                              at: index) as? SectionTitleHeaderView else {
                                                fatalError()
        }
        view.configure(with: listingHorizontalSectionModel?.title,
                       buttonText: listingHorizontalSectionModel?.links.first?.key)
        view.sectionHeaderDelegate = self
        return view
    }

    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        guard let context = collectionContext,
            let title = listingHorizontalSectionModel?.title else { return .zero }
        return SectionTitleHeaderView.Layout.headerSize(with: title,
                                                        containerWidth: context.containerSize.width,
                                                        maxLines: SectionControllerLayout.sectionHeaderMaxLine)
    }
}

extension HorizontalSectionController: EmbeddedInterestedActionDelegate {
    
    func interestedActionFor(_ listing: Listing,
                             userListing: LocalUser?,
                             touchPoint: CGPoint,
                             completion: @escaping (InterestedState) -> Void) {
        guard let cell = collectionContext?.cellForItem(at: 0, sectionController: self) as? EmbeddedCollectionViewCell,
            let point = viewController?.view.convert(touchPoint, to: cell.collectionView),
            let index = cell.collectionView.indexPathForItem(at: point)?.section,
            let id = listingHorizontalSectionModel?.id else { return }
        let trackingInfo = SectionedFeedChatTrackingInfo(sectionId: .identifier(id: id),
                                                         itemIndexInSection: .position(index: index))
        listingActionDelegate?.interestedActionFor(listing,
                                                   userListing: userListing,
                                                   sectionedFeedChatTrackingInfo: trackingInfo,
                                                   completion: completion)
    }
}

extension HorizontalSectionController: SectionTitleHeaderViewDelegate {
    func didTapViewAll() {
        guard let nextPage = listingHorizontalSectionModel?.links.first?.value ,
            let nextPageURL = URL(string: nextPage),
            let title = listingHorizontalSectionModel?.title else { return }
        guard let model = listingHorizontalSectionModel else { return }
        delegate?.didTapSeeAll(
            page: .feed(page: nextPageURL, title: title),
            section: model.sectionPosition.index,
            identifier: model.id
        )
    }
}
