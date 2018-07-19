import LGCoreKit

extension ServiceType {
    var cellRepresentables: [DropdownCellRepresentable] {
        let cellContent = DropdownCellContent(type: .header, title: self.name, id: self.id)
        let typeRepresentable = DropdownCellViewModel(withContent: cellContent, state: .disabled)
        return [typeRepresentable] + subTypes.cellRepresentables
    }
    
    func isAllSubtypesSelected(_ subtypes: [ServiceSubtype]) -> Bool {
        return self.subTypes.count == subtypes.count
    }
}

extension Collection where Element == ServiceType {
    var cellRepresentables: [DropdownCellRepresentable] {
        return reduce([]) { (res, nextElement) -> [DropdownCellRepresentable] in
            return res + nextElement.cellRepresentables
        }
    }
}
