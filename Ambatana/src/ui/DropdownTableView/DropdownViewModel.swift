
typealias DropdownSelectedItems = (selectedHeaderId: String, selectedItemIds: [String])

final class DropdownViewModel {
    
    private enum Layout {
        static let headerHeight: CGFloat = 50.0
        static let itemHeight: CGFloat = 30.0
    }
    
    let screenTitle: String
    let searchPlaceholderTitle: String
    let buttonAction: ((DropdownSelectedItems?) -> Void)?
    
    let attributes: [DropdownSection]
    
    var filteredAttributes: [DropdownSection] {
        // MARK: Will be used for filtering by keyword
        return attributes
    }
    
    init(screenTitle: String,
         searchPlaceholderTitle: String,
         attributes: [DropdownSection],
         buttonAction: ((DropdownSelectedItems?) -> Void)?) {
        self.screenTitle = screenTitle
        self.searchPlaceholderTitle = searchPlaceholderTitle
        self.attributes = attributes
        self.buttonAction = buttonAction
    }

    
    // MARK: DataSource fetching
    
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
        return filteredAttributes.count
    }
    
    func numberOfItems(forSection section: Int) -> Int {
        return filteredAttributes[safeAt: section]?.count ?? 0
    }


    // MARK: DataSource Operations

    func dropdownSection(atSection section: Int) -> DropdownSection? {
        return filteredAttributes[safeAt: section]
    }
    
    func didSelectItem(atIndexPath indexPath: IndexPath) {
        guard let item = item(forIndexPath: indexPath),
            let section = dropdownSection(atSection: indexPath.section) else { return }
        switch item.content.type {
        case .item:
            filteredAttributes.selectItem(withItemId: item.content.id,
                                          inSection: section)
        case .header:
            filteredAttributes.toggleExpansionState(forId: item.content.id)
        }
    }
    
    func didDeselectItem(atIndexPath indexPath: IndexPath) {
        guard let item = item(forIndexPath: indexPath) else { return }
        switch item.content.type {
        case .item:
            filteredAttributes.deselectItem(withItemId: item.content.id)
        case .header:
            filteredAttributes.toggleExpansionState(forId: item.content.id)
        }
    }
    
    func toggleHeaderSelection(atIndexPath indexPath: IndexPath) {
        guard let item = item(forIndexPath: indexPath) else { return }
        switch item.state {
        case .selected, .semiSelected:
            filteredAttributes.deselectSection(withHeaderId: item.content.id)
        case .deselected:
            filteredAttributes.selectSection(withHeaderId: item.content.id)
        }
    }
    
    func expansionState(forId id: String) -> Bool {
        return filteredAttributes.expansionState(forId: id)
    }
    
    func resetFilters() {
        attributes.deselectAllItems()
    }
    
    func applySelectedFilters() {
        let selectedItems = attributes.selectedSectionItems
        buttonAction?(selectedItems)
    }
}
