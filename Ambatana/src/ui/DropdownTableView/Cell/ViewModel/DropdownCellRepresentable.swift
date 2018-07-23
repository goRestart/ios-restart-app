enum DropdownCellState {
    case selected, semiSelected, deselected, disabled
}
enum DropdownCellType {
    case header, item(featured: Bool)
}

struct DropdownCellContent {
    let type: DropdownCellType
    let title: String
    let id: String
}

protocol DropdownCellRepresentable {
    var content: DropdownCellContent { get }
    var state: DropdownCellState { get set }
    func update(withState state: DropdownCellState)
}

extension DropdownCellType: Equatable {
    static func ==(a: DropdownCellType, b: DropdownCellType) -> Bool {
        switch (a, b) {
        case (let .item(featured: valueA), let .item(featured: valueB)): return valueA == valueB
        case (.header, .header): return true
        default: return false
        }
    }
}

//  MARK: - [DropdownCellRepresentable]+ServicesFilters

extension Collection where Element == DropdownCellRepresentable {
    func updatedCellRepresentables(withServicesFilters serviceFilters: ServicesFilters) -> [DropdownCellRepresentable] {
        guard let updatedCellRepresentable = self as? [DropdownCellRepresentable] else { return [] }
        
        guard let serviceType = serviceFilters.type else { return updatedCellRepresentable }
        
        first(where: { $0.content.id == serviceType.id  })?.update(withState: .semiSelected)
        
        guard let serviceSubtypes = serviceFilters.subtypes else { return updatedCellRepresentable }
        
        let isAllSelected = serviceType.isAllSubtypesSelected(serviceSubtypes)
        let servicesSubtypeIds = serviceSubtypes.map { $0.id }
        
        if isAllSelected {
            first(where: { $0.content.id == serviceType.id  })?.update(withState: .selected)
        }
        
        forEach {
            if $0.content.type != .header {
                let subtypeState: DropdownCellState = servicesSubtypeIds.contains( $0.content.id) ? .selected : .deselected
                $0.update(withState: subtypeState)
            }
        }
        
        return updatedCellRepresentable
    }
}
