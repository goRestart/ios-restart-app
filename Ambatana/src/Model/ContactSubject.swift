//
//  ContactSubject.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

enum ContactSubject {
    case profileEdit, listingEdit, location, login, report, other
    
    var name: String {
        get {
            switch(self) {
            case .profileEdit:
                return LGLocalizedString.contactSubjectOptionProfileEdit
            case .listingEdit:
                return LGLocalizedString.contactSubjectOptionProductEdit
            case .location:
                return LGLocalizedString.contactSubjectOptionLocation
            case .login:
                return LGLocalizedString.contactSubjectOptionLogin
            case .report:
                return LGLocalizedString.contactSubjectOptionReport
            case .other:
                return LGLocalizedString.contactSubjectOptionOther
            }
        }
    }
    
    static var allValues: [ContactSubject] {
        return [.profileEdit, .listingEdit, .location, .login, .report, .other]
    }
}