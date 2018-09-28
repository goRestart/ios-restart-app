enum AffiliationInviteSMSContactsCellState {
    case selected, deselected
}

struct AffiliationInviteSMSContactsCellViewModel {
    let content: ContactInfo
    let isFirstWithLetter: Bool
    let state: AffiliationInviteSMSContactsCellState

    var name: String {
        return content.name
    }
    
    var phoneNumber: String {
        return content.phoneNumber
    }
}
