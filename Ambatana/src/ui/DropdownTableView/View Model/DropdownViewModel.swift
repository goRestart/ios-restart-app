
typealias DropdownSelectedItems = (selectedHeaderId: String, selectedItemIds: [String])

final class DropdownViewModel {
    
    private enum Layout {
        static let headerHeight: CGFloat = 50.0
        static let itemHeight: CGFloat = 30.0
    }
    
    let screenTitle: String
    let searchPlaceholderTitle: String
    let buttonAction: ((DropdownSelectedItems?) -> Void)?
    
    let attributes: [DropdownSectionViewModel]
    
    private var isFilterActive: Bool = false
    
    init(screenTitle: String,
         searchPlaceholderTitle: String,
         attributes: [DropdownSectionViewModel],
         buttonAction: ((DropdownSelectedItems?) -> Void)?) {
        self.screenTitle = screenTitle
        self.searchPlaceholderTitle = searchPlaceholderTitle
        self.attributes = attributes
        self.buttonAction = buttonAction
    }

    
    // MARK: DataSource fetching
    
    var showsHeaderChevron: Bool {
        return !isFilterActive
    }
    
    func item(forIndexPath indexPath: IndexPath) -> DropdownCellRepresentable? {
        guard let section = dropdownSection(atSection: indexPath.section) else { return nil }
        return section.item(forIndex: indexPath.row)
    }
    
    func itemHeight(atIndexPath indexPath: IndexPath) -> CGFloat {
        guard let item = item(forIndexPath: indexPath) else { return 0 }
        switch item.content.type {
        case .header:
            return Layout.headerHeight
        case .item:
            return Layout.itemHeight
        }
    }
    
    func numberOfSections() -> Int {
        return attributes.count
    }
    
    func numberOfItems(forSection section: Int) -> Int {
        return attributes[safeAt: section]?.count ?? 0
    }


    // MARK: DataSource Operations

    func dropdownSection(atSection section: Int) -> DropdownSectionViewModel? {
        return attributes[safeAt: section]
    }
    
    func didSelectItem(atIndexPath indexPath: IndexPath) {
        guard let item = item(forIndexPath: indexPath),
            let section = dropdownSection(atSection: indexPath.section) else { return }
        switch item.content.type {
        case .item:
            attributes.selectItem(withItemId: item.content.id,
                                          inSection: section)
        case .header:
            if !isFilterActive {
                attributes.toggleExpansionState(forId: item.content.id)
            }
        }
    }
    
    func didDeselectItem(atIndexPath indexPath: IndexPath) {
        guard let item = item(forIndexPath: indexPath) else { return }
        switch item.content.type {
        case .item:
            attributes.deselectItem(withItemId: item.content.id)
        case .header:
            if !isFilterActive {
                attributes.toggleExpansionState(forId: item.content.id)
            }
        }
    }
    
    func toggleHeaderSelection(atIndexPath indexPath: IndexPath) {
        guard let item = item(forIndexPath: indexPath) else { return }
        switch item.state {
        case .selected, .semiSelected:
            attributes.deselectSection(withHeaderId: item.content.id)
        case .deselected:
            attributes.selectSection(withHeaderId: item.content.id)
        }
    }
    
    func expansionState(forId id: String) -> Bool {
        return attributes.expansionState(forId: id)
    }
    
    
    // MARK: Actions
    
    func resetFilters() {
        attributes.deselectAllItems()
    }
    
    func applySelectedFilters() {
        let selectedItems = attributes.selectedSectionItems
        buttonAction?(selectedItems)
    }
    
    
    // MARK: Filtering
    
    func didFilter(withText text: String) {
        attributes.applyFilter(withText: text)
        isFilterActive = true
    }
    
    func clearTextFilter() {
        attributes.clearTextFilter()
        isFilterActive = false
    }
}
