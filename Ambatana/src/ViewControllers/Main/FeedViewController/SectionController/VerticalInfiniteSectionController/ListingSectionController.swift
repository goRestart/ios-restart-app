import IGListKit
import LGComponents

protocol LocationEditable: class {
    func openEditLocation()
}

enum ListingRetrievalState {
    case loading, error, lastPage
}

final class ListingSectionController: ListSectionController {
    
    enum SupplementaryViewHeight: CGFloat {
        case footer, header
        var cgfloatValue: CGFloat {
            switch self {
            case .footer:
                return SharedConstants.listingListFooterHeight
            case .header:
                return SectionControllerLayout.fixTitleHeaderHeight
            }
        }
    }
    
    private var listingVerticalSectionModel: ListingSectionModel?
    private let numberOfColumns: Int
    private let listingState: ListingRetrievalState
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(),
                           viewController: self.viewController,
                           workingRangeSize: 0)
    }()
    
    weak var locationEditable: LocationEditable?
    weak var collectionViewFooter: CollectionViewFooter?

    init(numberOfColumns: Int, listingState: ListingRetrievalState) {
        self.numberOfColumns = numberOfColumns
        self.listingState = listingState
        super.init()
        supplementaryViewSource = self
        setupLayoutParams()
    }
    
    override func numberOfItems() -> Int {
        return listingVerticalSectionModel?.items.count ?? 0
    }
    
    override func didUpdate(to object: Any) {
        listingVerticalSectionModel = object as? ListingSectionModel
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: SimpleImageListingCell.self,
                                                                for: self,
                                                                at: index) else {
                                                                    fatalError()
        }
        return cell
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let cxt = collectionContext else { return .zero }
        let width = cxt.containerSize.width / CGFloat(numberOfColumns)
        let height = CGFloat(100 + 10 * index) //FIXME: Use image size to calculate cell height
        return CGSize(width: width, height: height)
    }
    
    
    // Private Methods:
    
    private func refreshFooter() {
        guard let footer = collectionViewFooter else { return }
        switch listingState {
        case .error:
            footer.status = .error
        case .lastPage:
            footer.status = .lastPage
        case .loading:
            footer.status = .loading
        }
        
        footer.retryButtonBlock = {
            // TODO: Implement retrieveListingsNextPage and reload data in ABIOS-4511
            // https://ambatana.atlassian.net/browse/ABIOS-4511
        }
    }
    
    private func setupLayoutParams() {
        inset = SectionControllerLayout.sectionInset
        minimumLineSpacing = SectionControllerLayout.fixedListingSpacing
        minimumInteritemSpacing = SectionControllerLayout.fixedListingSpacing
    }
}


// MARK:- SupplementaryView Datasource

extension ListingSectionController: ListSupplementaryViewSource {
    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader, UICollectionElementKindSectionFooter]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        
        switch elementKind {
        case UICollectionElementKindSectionHeader:
            guard let view = collectionContext?
                .dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                  for: self,
                                                  class: SectionTitleHeaderView.self,
                                                  at: index) as? SectionTitleHeaderView else {
                                                    fatalError()
            }
            view.configure(with: listingVerticalSectionModel?.title,
                           buttonText: listingVerticalSectionModel?.links.first?.key)
            view.sectionHeaderDelegate = self
            return view
        case UICollectionElementKindSectionFooter:
            guard let view = collectionContext?
                .dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                  for: self,
                                                  class: CollectionViewFooter.self,
                                                  at: index) as? CollectionViewFooter else {
                                                    fatalError()  }
            collectionViewFooter = view
            refreshFooter()
            return view
        default:
            fatalError()
        }
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        guard let context = collectionContext else { return .zero }
        let height: CGFloat
        switch elementKind {
        case UICollectionElementKindSectionFooter:
            height = SupplementaryViewHeight.footer.cgfloatValue
        case UICollectionElementKindSectionHeader:
            height = SupplementaryViewHeight.header.cgfloatValue
        default:
            height = 0
        }
        return CGSize(width: context.containerSize.width, height: height)
    }
}

extension ListingSectionController: SectionTitleHeaderViewDelegate {
    func didTapViewAll() {
        locationEditable?.openEditLocation()
    }
}

