
final class DropdownSectionViewModel {
    
    private let header: DropdownCellRepresentable
    private let items: [DropdownCellRepresentable]
    private var filterText: String?
    
    var isExpanded: Bool
    var isShowingAll: Bool
    
    init(withHeader header: DropdownCellRepresentable,
         items: [DropdownCellRepresentable],
         isExpanded: Bool,
         isShowingAll: Bool) {
        self.header = header
        self.items = items
        self.isExpanded = isExpanded
        self.isShowingAll = isShowingAll
    }
    
    private var selectedItemCount: Int {
        return items.filter({ $0.state == .selected }).count
    }
    
    private var allItems: [DropdownCellRepresentable] {
        return [header] + items
    }
    
    private var allHighlightedItems: [DropdownCellRepresentable] {
        return [header] + items.filter({ $0.isHighlighted })
    }

    private var visibleItems: [DropdownCellRepresentable] {
        if let filterText = self.filterText {
            return items(matchingText: filterText)
        }
        
        if isExpanded {
            return isShowingAll ? allItems : allHighlightedItems
        }
        return [header]
    }
    
    var sectionId: String {
        return header.content.id
    }
    
    var count: Int {
        return visibleItems.count
    }
    
    var selectedItems: DropdownSelectedItems? {
        guard header.state == .selected || header.state == .semiSelected else { return nil }
        let selectedItemIds = items.filter({ $0.state == .selected }).map({ $0.content.id })
        return (header.content.id, selectedItemIds)
    }
    
    func item(forIndex index: Int) -> DropdownCellRepresentable? {
        return visibleItems[safeAt: index]
    }
    
    
    // MARK: State Handling
    
    func updateState(state: DropdownCellState,
                     forItemId itemId: String) {
        allItems.filter({ $0.content.id == itemId }).first?.update(withState: state)
        refreshHeaderState()
    }

    private func updateAllItems(toState state: DropdownCellState) {
        allItems.forEach( { $0.update(withState: state) } )
    }
    
    private func updateHeader(toState state: DropdownCellState) {
        header.update(withState: state)
    }
    
    func setupSectionAsSelected(withSelectedItemIds selectedItemIds: [String]) {
        if selectedItemIds.count > 0 {
            allItems.forEach { (item) in
                if selectedItemIds.contains(item.content.id) {
                    item.update(withState: .selected)
                }
            }
            refreshHeaderState()
        } else {
            selectHeader()
        }
    }
    
    private func refreshHeaderState() {
        switch selectedItemCount {
        case 0:
            updateHeader(toState: .deselected)
        case items.count:
            updateHeader(toState: .selected)
        default:
            updateHeader(toState: .semiSelected)
        }
    }

    
    // MARK: Filtering
    
    func clearTextFilter() {
        filterText = nil
        isExpanded = false
        isShowingAll = false
    }
    
    func applyFilter(withText text: String) {
        filterText = text
        isExpanded = true
        isShowingAll = true
    }
    
    private func items(matchingText text: String) -> [DropdownCellRepresentable] {
        let filteredItems = items.filter({ $0.content.title.lowercased().contains(text.lowercased()) })
        if filteredItems.count > 0 {
            return [header] + filteredItems
        } else if header.content.title.lowercased().contains(text.lowercased()) {
            return [header] + filteredItems
        }
        
        return filteredItems
    }
    
    
    // MARK: Selection and Deselection
    
    func deselectAllItems() {
        updateAllItems(toState: .deselected)
    }
    
    func selectHeader() {
        deselectAllItems()
        header.update(withState: .selected)
    }


    // MARK: Handle expansion and contraction of sections

    func toggleExpansionState(forId id: String) {
        guard header.content.id == id else { return }
        isExpanded = !isExpanded
        
        if !isExpanded {
            isShowingAll = false
        }
    }
}

extension Collection where Element == DropdownSectionViewModel {
    
    var selectedSectionItems: DropdownSelectedItems? {
        return first(where: { $0.selectedItems != nil })?.selectedItems
    }
    
    
    // MARK: Filter Logic
    
    func clearTextFilter() {
        forEach { section in
            section.clearTextFilter()
        }
    }
    
    func applyFilter(withText text: String) {
        forEach { section in
            section.applyFilter(withText: text)
        }
    }
    
    
    // MARK: DropdownSection Expansion / Contraction toggle
    
    func toggleExpansionState(forId id: String) {
        forEach { $0.toggleExpansionState(forId: id) }
    }
    
    func expansionState(forId id: String) -> Bool {
        return filter( { $0.sectionId == id }).first?.isExpanded ?? false
    }


    // MARK: DropdownSection Collection selection and deselection
    
    func selectSection(withHeaderId id: String) {
        forEach { section in
            if section.sectionId == id {
                section.selectHeader()
            } else {
                section.deselectAllItems()
            }
        }
    }
    
    func deselectSection(withHeaderId id: String) {
        deselectAllItems()
    }
    
    func selectItem(withItemId id: String,
                    inSection section: DropdownSectionViewModel) {
        forEach({
            if $0.sectionId != section.sectionId {
                $0.deselectAllItems()
            }
        })
        updateState(state: .selected, forItemId: id)
    }
    
    func deselectItem(withItemId id: String) {
        updateState(state: .deselected, forItemId: id)
    }
    
    func deselectAllItems() {
        forEach( { $0.deselectAllItems() } )
    }
    
    private func updateState(state: DropdownCellState,
                             forItemId itemId: String) {
        forEach { $0.updateState(state: state, forItemId: itemId) }
    }
}
