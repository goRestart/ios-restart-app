import LGComponents
import Contacts
import MessageUI
import RxSwift
import RxCocoa
import LGCoreKit

struct ContactInfo: Equatable {
    let name: String
    let phoneNumber: String
}

enum StatusInviteSMSContactsStatus {
    case loading
    case data
    case error
    case needPermissions
    case empty
    case filtering
}

final class AffiliationInviteSMSContactsViewModel: BaseViewModel {
    var navigator: AffiliationInviteSMSContactsNavigator?
    private let myUserRepository: MyUserRepository
    
    private var itemsSelected = [ContactInfo]()
    private var firstLetterIndexes = [Int]()
    
    let hasContactsSelected = BehaviorRelay<Bool>(value: false)
    let status = BehaviorRelay<StatusInviteSMSContactsStatus>(value: .loading)
    let contactsInfo = BehaviorRelay<[ContactInfo]>(value: [])
    let searchResultsInfo = BehaviorRelay<[ContactInfo]>(value: [])
    
    private let disposeBag = DisposeBag()

    init(myUserRepository: MyUserRepository) {
        self.myUserRepository = myUserRepository
        super.init()
    }
    
    override convenience init() {
        self.init(myUserRepository: Core.myUserRepository)
    }
    
    override func backButtonPressed() -> Bool {
        navigator?.closeAffiliationInviteSMSContacts()
        return true
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime {
            requestContactPermissions()
        }
    }
    
    var contactsSelected: [ContactInfo] {
        return itemsSelected
    }
    
    func isFirstLetter(position: Int) -> Bool {
        return firstLetterIndexes.contains(position)
    }
    
    private func getContacts(store: CNContactStore) -> [ContactInfo] {
        guard let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                          CNContactPhoneNumbersKey] as? [CNKeyDescriptor] else { return []}
        
        var contacts = [ContactInfo]()
        
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        request.sortOrder = CNContactSortOrder.givenName
        do {
            try store.enumerateContacts(with: request, usingBlock: {(contact, stopPointerIfYouWantToStopEnumerating) in
                
                let fullName: String? = CNContactFormatter.string(from: contact, style: .fullName)
                let contactInfo = ContactInfo(name: fullName ?? "",
                                              phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "")
                contacts.append(contactInfo)
            })
        } catch let _ {
            status.accept(.error)
        }
        return contacts
    }
    
    func requestContactPermissions() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) {[weak self] (granted, err) in
            self?.update(with: granted, error: err, store: store)
        }
    }
    
    private func update(with granted: Bool, error: Error?, store: CNContactStore) {
        if granted {
            let contacts = getContacts(store: store)
            contactsInfo.accept(contacts)
            let newStatus: StatusInviteSMSContactsStatus = contacts.isEmpty ? .empty : .data
            status.accept(newStatus)
        } else {
            status.accept(.needPermissions)
        }
    }
    
    func updateFirstLetterPositions() {
        firstLetterIndexes = []
        let extractNames = contactsInfo.value.compactMap { String($0.name) }
        var previousLetter = ""
        extractNames.enumerated().forEach { (position, value) in
            let letter = value.firstLetterNormalized
            if letter != previousLetter {
                firstLetterIndexes.append(position)
            }
            previousLetter = letter
        }
    }

    func stateFor(contactInfo: ContactInfo) -> AffiliationInviteSMSContactsCellState {
        return itemsSelected.contains(contactInfo) ? .selected : .deselected
    }
    
    func cellSelected(contactInfo: ContactInfo) {
        guard !itemsSelected.contains(contactInfo) else { return }
        itemsSelected.append(contactInfo)
        hasContactsSelected.accept(!itemsSelected.isEmpty)
    }
    
    func cellDeselected(contactInfo: ContactInfo) {
        guard itemsSelected.contains(contactInfo) else { return }
        itemsSelected.removeIfContains(contactInfo)
        hasContactsSelected.accept(!itemsSelected.isEmpty)
    }
    
    func smsText() -> SocialMessage {
        let myUserId = myUserRepository.myUser?.objectId
        let myUserName = myUserRepository.myUser?.name
        let myUserAvatar = myUserRepository.myUser?.avatar?.fileURL?.absoluteString
        let socialMessage: SocialMessage = AffiliationSocialMessage(myUserId:myUserId, myUserName: myUserName, myUserAvatar: myUserAvatar)
        return socialMessage
    }
    
    
    // MARK: Filtering
    
    func didFilter(withText text: String) {
        let contactsFiltered = contactsInfo.value.filter { $0.name.lowercased().contains(text.lowercased()) || $0.phoneNumber.lowercased().contains(text.lowercased())  }
        searchResultsInfo.accept(contactsFiltered)
        status.accept(.filtering)
    }
    
    func clearTextFilter() {
        searchResultsInfo.accept([])
        let newStatus: StatusInviteSMSContactsStatus = contactsInfo.value.isEmpty ? .empty : .data
        status.accept(newStatus)

    }
}
