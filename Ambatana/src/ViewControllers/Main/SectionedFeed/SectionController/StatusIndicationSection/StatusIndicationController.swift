import IGListKit
import LGComponents

protocol RetryFooterDelegate: class {
    func retryClicked()
}

final class StatusIndicationSectionController: ListSectionController {
    
    weak var retryFooterDelegate: RetryFooterDelegate?
    var listingRetrievalState: ListingRetrievalState?
    
    override init() {
        super.init()
        inset = .zero
        supplementaryViewSource = self
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let context = collectionContext else { return .zero }
        return CGSize(width: context.containerSize.width, height: 1.0)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: EmptyCell.self,
                                                                for: self,
                                                                at: index)
            else { fatalError("Cannot dequeue EmptyCell in StatusIndicationSectionController") }
        return cell
    }
    
    override func didUpdate(to object: Any) {
        listingRetrievalState = (object as? DiffableBox<ListingRetrievalState>)?.value
    }
}

// MARK:- SupplementaryView Datasource

extension StatusIndicationSectionController: ListSupplementaryViewSource {
    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        guard let view = collectionContext?
            .dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                              for: self,
                                              class: CollectionViewFooter.self,
                                              at: index) as? CollectionViewFooter else {
                                                fatalError()
        }
        refreshStatus(view)
        return view
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        guard let context = collectionContext else { return .zero }
        return CGSize(width: context.containerSize.width,
                      height: SharedConstants.listingListFooterHeight)
    }
    
    private func refreshStatus(_ view: CollectionViewFooter) {
        view.retryButtonBlock = { [weak self] in
            self?.retryFooterDelegate?.retryClicked()
        }
        guard let state = listingRetrievalState else { return }
        switch state {
        case .error:
            view.status = .error
        case .lastPage:
            view.status = .lastPage
        case .loading:
            view.status = .loading
        }
    }
}

