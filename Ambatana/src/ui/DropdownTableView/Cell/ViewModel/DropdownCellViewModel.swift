final class DropdownCellViewModel: DropdownCellRepresentable {
    let content: DropdownCellContent
    var state: DropdownCellState
    
    init(withContent content: DropdownCellContent, state: DropdownCellState ) {
        self.content = content
        self.state = state
    }
    
    func update(withState state: DropdownCellState) {
        self.state = state
    }
}
