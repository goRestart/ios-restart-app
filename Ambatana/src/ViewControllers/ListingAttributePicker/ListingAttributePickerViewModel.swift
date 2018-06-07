
import LGComponents

enum ListingAttributePickerType {
    case multiselect(ListingAttributeMultiselectPickerViewModel)
    case singleSelect(ListingAttributeSingleSelectPickerViewModel)
}

protocol ListingAttributePickerViewModel: ListingAttributePickerTableViewDelegate {
    var title: String { get }
    var attributes: [String] { get }
    var canSearchAttributes: Bool { get }
    var doneButtonTitle: String? { get }
    var showsDoneButton: Bool { get }
    var doneButtonStyle: ButtonStyle { get }
    
    var delegate: BaseViewModelDelegate? { get set }
    var type: ListingAttributePickerType { get }
}


final class ListingAttributeMultiselectPickerViewModel: BaseViewModel, ListingAttributePickerViewModel {

    let title: String
    let attributes: [String]
    let canSearchAttributes: Bool
    let doneButtonTitle: String? = R.Strings.commonDone
    
    private var selectedAttributes: [String]
    private var selectionUpdate: ((_ selectedIndex: [Int]) -> Void)?

    weak var delegate: BaseViewModelDelegate?
    
    var type: ListingAttributePickerType {
        return .multiselect(self)
    }
    
    var showsDoneButton: Bool {
        return true
    }
    
    var doneButtonStyle: ButtonStyle {
        return .primary(fontSize: .medium)
    }
    
    var selectedIndexes: [Int] {
        let selectedAttributesLowercased = selectedAttributes.map( { $0.lowercased() } )
        let attributesLowercased = attributes.map( { $0.lowercased() } )
        return selectedAttributesLowercased.reduce([], { (res, next) -> [Int] in
            if let index = attributesLowercased.index(of: next) {
                return res + [index]
            }
            return res
        })
    }

    convenience init(title: String,
                     attributes: [String],
                     selectedAttributes: [String],
                     selectionUpdate: @escaping ([Int]) -> Void) {
        self.init(title: title,
                  attributes: attributes,
                  selectedAttributes: selectedAttributes,
                  canSearchAttributes: false,
                  selectionUpdate: selectionUpdate)
    }
    
    init(title: String,
         attributes: [String],
         selectedAttributes: [String],
         canSearchAttributes: Bool,
         selectionUpdate: @escaping ([Int]) -> Void) {
        self.title = title
        self.attributes = attributes
        self.selectedAttributes = selectedAttributes
        self.selectionUpdate = selectionUpdate
        self.canSearchAttributes = canSearchAttributes
        
        super.init()
    }
    
    private func selectAttribute(at index: Int) {
        guard let selectedAttribute = attributes[safeAt: index] else {
            return
        }
        selectedAttributes.append(selectedAttribute)
    }
    
    private func deselectAttribute(at index: Int) {
        guard let deselectedAttribute = attributes[safeAt: index], 
            let deselectedIndex = selectedAttributes.index(of: deselectedAttribute) else {
            return
        }

        selectedAttributes.remove(at: deselectedIndex)
    }
    
    private func dismiss() {
        delay(0.3) { [weak self] in
            self?.delegate?.vmPop()
        }
    }
    
    func doneButtonTapped() {
        selectionUpdate?(selectedIndexes)
        dismiss()
    }
    
    
    // MARK: ListingAttributePickerTableViewDelegate Implementation
    
    func indexSelected(index: Int) {
        selectAttribute(at: index)
    }
    
    func indexDeselected(index: Int) {
        deselectAttribute(at: index)
    }
    
    func indexForValueSelected() -> Int? {
        return nil
    }
}


final class ListingAttributeSingleSelectPickerViewModel: BaseViewModel, ListingAttributePickerViewModel {
    
    let title: String
    let attributes: [String]
    let canSearchAttributes: Bool
    
    private var selectedAttribute: String?
    private var selectionUpdate: ((_ selectedIndex: Int?) -> Void)?
    
    weak var delegate: BaseViewModelDelegate?
    var selectedIndex: Int? {
        guard let selectedAttribute = selectedAttribute?.lowercased() else { return nil }
        return attributes.map({ $0.lowercased() }).index(of: selectedAttribute)
    }
    
    var type: ListingAttributePickerType {
        return .singleSelect(self)
    }
    
    let doneButtonTitle: String? = nil
    
    var showsDoneButton: Bool {
        return false
    }
    
    var doneButtonStyle: ButtonStyle {
        return .primary(fontSize: .medium)
    }
    
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
    
    private func selectAttribute(at index: Int) {
        selectedAttribute = attributes[index]
        selectionUpdate?(index)
        dismiss()
    }
    
    private func deselectAttribute() {
        selectedAttribute = nil
        selectionUpdate?(nil)
    }
    
    private func dismiss() {
        delay(0.3) { [weak self] in
            self?.delegate?.vmPop()
        }
    }
    
    
    // MARK: ListingAttributePickerTableViewDelegate Implementation
    
    func indexSelected(index: Int) {
        selectAttribute(at: index)
    }
    
    func indexDeselected(index: Int) {
        deselectAttribute()
    }
    
    func indexForValueSelected() -> Int? {
        return selectedIndex
    }
}
