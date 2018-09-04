
import LGComponents

typealias DropdownSelectedItems = (selectedHeaderId: String, selectedItemIds: [String])

protocol DropdownViewModelDelegate: BaseViewModelDelegate {
    func selectRow(atIndexPath indexPath: IndexPath)
    func deselectRow(atIndexPath indexPath: IndexPath)
    func showDoneButton()
    func hideDoneButton()
}

final class DropdownViewModel {
    
    private enum Layout {
        static let headerHeight: CGFloat = 50.0
        static let itemHeight: CGFloat = 40.0
    }
    
    let screenTitle: String
    let searchPlaceholderTitle: String
    let buttonAction: ((DropdownSelectedItems?) -> Void)?
    
    
    private let initialSelectedItems: DropdownSelectedItems?
    let attributes: [DropdownSectionViewModel]
    
    
    private let maxSelectableAttributes: Int = 15
    
    private var isFilterActive: Bool = false
    weak var delegate: DropdownViewModelDelegate?
    
    private let featureFlags: FeatureFlaggeable
    private var maxAlertTitle: String {
        return featureFlags.jobsAndServicesEnabled.isActive ? R.Strings.filtersJobsServicesListMaxSelectionAlert : R.Strings.filtersServicesServicesListMaxSelectionAlert
    }
    
    init(screenTitle: String,
         searchPlaceholderTitle: String,
         attributes: [DropdownSectionViewModel],
         buttonAction: ((DropdownSelectedItems?) -> Void)?,
         featureFlags: FeatureFlaggeable) {
        self.screenTitle = screenTitle
        self.searchPlaceholderTitle = searchPlaceholderTitle
        self.initialSelectedItems = attributes.selectedSectionItems
        self.attributes = attributes
        self.buttonAction = buttonAction
        self.featureFlags = featureFlags
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
            if canSelectItem(atIndexPath: indexPath) {
                attributes.selectItem(withItemId: item.content.id,
                                      inSection: section)
                delegate?.selectRow(atIndexPath: indexPath)
            } else {
                delegate?.deselectRow(atIndexPath: indexPath)
                showAlert(withTitle: maxAlertTitle)
            }
        case .header:
            if !isFilterActive {
                attributes.toggleExpansionState(forId: item.content.id)
            }
            
            delegate?.selectRow(atIndexPath: indexPath)
        }
        assertShouldShowActionButtons()
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
        assertShouldShowActionButtons()
        delegate?.deselectRow(atIndexPath: indexPath)
    }
    
    func toggleHeaderSelection(atIndexPath indexPath: IndexPath) {
        guard let item = item(forIndexPath: indexPath) else { return }
        switch item.state {
        case .selected, .semiSelected:
            attributes.deselectSection(withHeaderId: item.content.id)
        case .deselected:
            attributes.selectSection(withHeaderId: item.content.id)
        }
        assertShouldShowActionButtons()
    }
    
    func expansionState(forId id: String) -> Bool {
        return attributes.expansionState(forId: id)
    }
    
    func canSelectItem(atIndexPath indexPath: IndexPath) -> Bool {
        guard let selectedItems = attributes.selectedSectionItems else { return true }
        return selectedItems.selectedItemIds.count < maxSelectableAttributes
    }
    
    func showAlert(withTitle title: String) {
        let action = UIAction(interface: .button(R.Strings.commonOk, .primary(fontSize: .medium)),
                              action: { },
                              accessibility: AccessibilityId.postingDetailMaxServices)
        delegate?.vmShowAlertWithTitle(title,
                                       text: "",
                                       alertType: .plainAlert,
                                       actions: [action])
    }
    
    
    // MARK: Actions
    
    func resetFilters() {
        attributes.deselectAllItems()
        assertShouldShowActionButtons()
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
    
    
    // MARK: Action Buttons
    
    private func assertShouldShowActionButtons() {
        let headerChanged = attributes.selectedSectionItems?.selectedHeaderId != initialSelectedItems?.selectedHeaderId
        let itemsChanged = attributes.selectedSectionItems?.selectedItemIds != initialSelectedItems?.selectedItemIds
        if headerChanged || itemsChanged {
            delegate?.showDoneButton()
        } else {
            delegate?.hideDoneButton()
        }
    }
}
