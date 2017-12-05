
class ListingAttributePickerViewModel: BaseViewModel {
    
    let title: String
    let attributes: [String]
    weak var delegate: BaseViewModelDelegate?

    fileprivate var selectedAttribute: String?
    fileprivate let selectionUpdate: ((_ selectedIndex: Int?) -> Void)
    
    init(
        title: String,
        attributes: [String],
        selectedAttribute: String?,
        selectionUpdate: @escaping (Int?) -> Void
        ) {
        self.title = title
        self.attributes = attributes
        self.selectedAttribute = selectedAttribute
        self.selectionUpdate = selectionUpdate
        super.init()
    }
    
    func selectedAttribute(at index: Int) {
        selectedAttribute = attributes[index]
        selectionUpdate(index)
        delay(0.3) { [weak self] in
            self?.delegate?.vmPop()
        }
    }
    
    func deselectAttribute() {
        selectedAttribute = nil
        selectionUpdate(nil)
    }
    
    func selectedIndex() -> Int? {
        guard let selectedAttribute = selectedAttribute?.lowercased() else { return nil }
        return attributes.map({ $0.lowercased() }).index(of: selectedAttribute)
    }
}
