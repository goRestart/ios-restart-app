import LGComponents
import IGListKit

final class BannerSectionController: ListSectionController {
    
    weak var delegate: AdUpdated?
    
    private let tracker: Tracker
    private var adData: AdData?
    
    init(tracker: Tracker = TrackerProxy.sharedInstance) {
        self.tracker = tracker
        super.init()
    }

    override func sizeForItem(at index: Int) -> CGSize {
        return .zero
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    override func didUpdate(to object: Any) {
        if let diffWrapper = object as? DiffableBox<AdData> {
            adData = diffWrapper.value
        }
    }
    
}
