enum DropdownCellState {
    case selected, semiSelected, deselected
}
enum DropdownCellType: Equatable {
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

extension DropdownCellRepresentable {
    
    var isHighlighted: Bool {
        if case .item(let featured) = content.type {
            return featured
        }
        return false
    }
}

//  MARK: - [DropdownCellRepresentable]+ServicesFilters

extension Collection where Element == DropdownSectionViewModel {
    
    func updatedSectionRepresentables(withServicesFilters serviceFilters: ServicesFilters) -> [DropdownSectionViewModel] {
        guard let updatedSectionRepresentable = self as? [DropdownSectionViewModel] else { return [] }
        
        guard let serviceType = serviceFilters.type else { return updatedSectionRepresentable }
        guard let serviceSubtypes = serviceFilters.subtypes else { return updatedSectionRepresentable }
        
        guard let section = first(where: { $0.sectionId == serviceType.id }) else { return updatedSectionRepresentable }
        
        let servicesSubtypeIds = serviceSubtypes.map { $0.id }
        section.absorb(ids: servicesSubtypeIds)
        
        return updatedSectionRepresentable
    }
}
