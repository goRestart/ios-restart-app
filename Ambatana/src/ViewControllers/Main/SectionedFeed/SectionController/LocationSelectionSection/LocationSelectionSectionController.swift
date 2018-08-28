import IGListKit
import LGComponents

protocol LocationEditable: class {
    func openEditLocation()
}

final class LocationSectionController: ListSectionController {
    
    weak var locationEditable: LocationEditable?
    
    private var locationObject: LocationData?
    
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
            else { fatalError("Cannot dequeue EmptyCell in LocationSectionController") }
        return cell
    }
    
    override func didUpdate(to object: Any) {
        locationObject = object as? LocationData
    }
}


// MARK:- SupplementaryView Datasource

extension LocationSectionController: ListSupplementaryViewSource {
    
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
        view.configure(with: locationObject?.locationString ?? R.Strings.productPopularNearYou,
                       buttonText: R.Strings.commonEdit)
        view.sectionHeaderDelegate = self
        return view
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        guard let context = collectionContext else { return .zero }
        return CGSize(width: context.containerSize.width,
                      height: SectionControllerLayout.fixTitleHeaderHeight)
    }
}

extension LocationSectionController: SectionTitleHeaderViewDelegate {
    func didTapViewAll() {
        locationEditable?.openEditLocation()
    }
}

