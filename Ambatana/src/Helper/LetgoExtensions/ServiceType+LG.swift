import LGCoreKit

extension ServiceType {

    var sectionRepresentable: DropdownSectionViewModel {
        let cellContent = DropdownCellContent(type: .header, title: self.name, id: self.id)
        let typeRepresentable = DropdownCellViewModel(withContent: cellContent, state: .deselected)
        let subRepresentables = subTypes.makeCellRepresentables()
        let section = DropdownSectionViewModel(withHeader: typeRepresentable,
                                               items: subRepresentables,
                                               isExpanded: false,
                                               isShowingAll: false)
        return section
    }
    
    func isAllSubtypesSelected(_ subtypes: [ServiceSubtype]) -> Bool {
        return self.subTypes.count == subtypes.count
    }
}

extension Collection where Element == ServiceType {
    
    var sectionRepresentables: [DropdownSectionViewModel] {
        return reduce([]) { (res, nextElement) -> [DropdownSectionViewModel] in
            return res + [nextElement.sectionRepresentable]
        }
    }
}
