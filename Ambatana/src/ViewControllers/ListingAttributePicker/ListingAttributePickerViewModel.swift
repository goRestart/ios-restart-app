
class ListingAttributePickerViewModel: BaseViewModel {
    
    let title: String
    let attributes: [String]
    let canSearchAttributes: Bool
    
    weak var delegate: BaseViewModelDelegate?
    var selectedIndex: Int? {
        guard let selectedAttribute = selectedAttribute?.lowercased() else { return nil }
        return attributes.map({ $0.lowercased() }).index(of: selectedAttribute)
    }

    fileprivate var selectedAttribute: String?
    fileprivate let selectionUpdate: ((_ selectedIndex: Int?) -> Void)
    
    convenience init(title: String,
                     attributes: [String],
                     selectedAttribute: String?,
                     selectionUpdate: @escaping (Int?) -> Void) {
        self.init(title: title,
                  attributes: attributes,
                  selectedAttribute: selectedAttribute,
                  canSearchAttributes: false,
                  selectionUpdate: selectionUpdate)
    }
    
    init(title: String,
        attributes: [String],
        selectedAttribute: String?,
        canSearchAttributes: Bool,
        selectionUpdate: @escaping (Int?) -> Void) {
        self.title = title
        self.attributes = attributes
        self.selectedAttribute = selectedAttribute
        self.selectionUpdate = selectionUpdate
        self.canSearchAttributes = canSearchAttributes
        
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
}
