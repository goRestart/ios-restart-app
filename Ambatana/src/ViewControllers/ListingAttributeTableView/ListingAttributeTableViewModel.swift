
import LGComponents

final class ListingAttributeTableViewModel: BaseViewModel {
    
    private let items: [ListingAttributeGridItem]
    
    weak var navigator: ListingDetailNavigator?
    
    init(withItems items: [ListingAttributeGridItem]) {
        self.items = items
    }
    
    func item(atIndex index: Int) -> ListingAttributeGridItem? {
        return items[safeAt: index]
    }
    
    var numberOfItems: Int {
        return items.count
    }
    
    func closeButtonTapped() {
        navigator?.closeListingAttributeTable()
    }
}
