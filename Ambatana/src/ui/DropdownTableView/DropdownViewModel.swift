import RxSwift
import RxCocoa

protocol DropdownRepresentable {
    var screenTitle: String { get }
    var searchPlaceholderTitle: String { get }
    var attributes: [DropdownCellRepresentable] { get set }
}

final class DropdownViewModel: DropdownRepresentable {
    let screenTitle: String
    let searchPlaceholderTitle: String
    var attributes: [DropdownCellRepresentable]
    
    init(screenTitle: String, searchPlaceholderTitle: String, attributes: [DropdownCellRepresentable]) {
        self.screenTitle = screenTitle
        self.searchPlaceholderTitle = searchPlaceholderTitle
        self.attributes = attributes
    }
    
    func update(withState state: DropdownCellState, atIndex index: Int) {
        attributes[safeAt: index]?.update(withState: state)
    }
}
