import LGCoreKit

extension ServiceType {

    var sectionRepresentable: DropdownSection {
        let cellContent = DropdownCellContent(type: .header, title: self.name, id: self.id)
        let typeRepresentable = DropdownCellViewModel(withContent: cellContent, state: .deselected)
        let subRepresentables = subTypes.createCellRepresentables(withParentId: self.id)
        let section = DropdownSection(withHeader: typeRepresentable,
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
    var sectionRepresentables: [DropdownSection] {
        return reduce([]) { (res, nextElement) -> [DropdownSection] in
            return res + [nextElement.sectionRepresentable]
        }
    }
}
