import LGComponents

enum ContactSubject {
    case profileEdit, listingEdit, location, login, report, other
    
    var name: String {
        get {
            switch(self) {
            case .profileEdit:
                return R.Strings.contactSubjectOptionProfileEdit
            case .listingEdit:
                return R.Strings.contactSubjectOptionProductEdit
            case .location:
                return R.Strings.contactSubjectOptionLocation
            case .login:
                return R.Strings.contactSubjectOptionLogin
            case .report:
                return R.Strings.contactSubjectOptionReport
            case .other:
                return R.Strings.contactSubjectOptionOther
            }
        }
    }
    
    static var allValues: [ContactSubject] {
        return [.profileEdit, .listingEdit, .location, .login, .report, .other]
    }
}
