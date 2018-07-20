import RxSwift
import RxCocoa

protocol DropdownRepresentable {
    var screenTitle: String { get }
    var searchPlaceholderTitle: String { get }
    var attributes: [DropdownCellRepresentable] { get set }
}

final class DropdownViewModel: DropdownRepresentable {
    
    private enum Layout {
        static let headerHeight: CGFloat = 50.0
        static let itemHeight: CGFloat = 30.0
    }
    
    let screenTitle: String
    let searchPlaceholderTitle: String
    var attributes: [DropdownCellRepresentable]
    let attributesDriver: Driver<[DropdownCellRepresentable]>

    
    init(screenTitle: String, searchPlaceholderTitle: String, attributes: [DropdownCellRepresentable]) {
        self.screenTitle = screenTitle
        self.searchPlaceholderTitle = searchPlaceholderTitle
        self.attributes = attributes
        self.attributesDriver = Driver.just(attributes)
    }
    
    func update(withState state: DropdownCellState, atIndex index: Int) {
        attributes[safeAt: index]?.update(withState: state)
    }
    
    func itemHeight(atIndex index: Int) -> CGFloat {
        guard let item = attributes[safeAt: index] else { return 0 }
        switch item.content.type {
        case .header:
            return Layout.headerHeight
        case .item:
            return Layout.itemHeight
        }
    }
}
