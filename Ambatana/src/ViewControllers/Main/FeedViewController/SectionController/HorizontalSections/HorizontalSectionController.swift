import IGListKit
import UIKit

final class HorizontalSectionController: ListSectionController {

    private var listingHorizontalSectionModel: ListingSectionModel?

    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(),
                                  viewController: self.viewController)
        adapter.dataSource = self
        return adapter
    }()

    private let featureFlags: FeatureFlaggeable
    
    init(featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.featureFlags = featureFlags
        super.init()
        supplementaryViewSource = self
        inset = SectionControllerLayout.sectionInset
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
        return cell
    }

    override func didUpdate(to object: Any) {
        listingHorizontalSectionModel = object as? ListingSectionModel
    }
    
    private func horizontalSectionHeight(forScreenWidth width: CGFloat) -> CGFloat {
        switch featureFlags.sectionedMainFeed {
        case .baseline, .control:
            return 0
        case .mediumHorizontalSection:
            return width / 2.2
        case .smallHorizontalSection:
            return width / 3.4
        }
    }
}


// MARK:- Adapter Datasource

extension HorizontalSectionController: ListAdapterDataSource {

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let items = listingHorizontalSectionModel?.items else { return [] }
        return items as [ListDiffable]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return EmbeddedListingSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
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
        guard let context = collectionContext else { return .zero }
        return CGSize(width: context.containerSize.width,
                      height: SectionControllerLayout.fixTitleHeaderHeight)
    }
}

extension HorizontalSectionController: SectionTitleHeaderViewDelegate {
    func didTapViewAll() {
        // TODO: https://ambatana.atlassian.net/browse/ABIOS-4506
        print("View All button is tapped: ABIOS_4506")
    }
}

