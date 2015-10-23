//
//  ContactSubject.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

public enum ContactSubject {
    case ProfileEdit, ProductEdit, Location, Login, Report, Other
    
    var name: String {
        get {
            switch(self) {
            case .ProfileEdit:
                return LGLocalizedString.contactSubjectOptionProfileEdit
            case .ProductEdit:
                return LGLocalizedString.contactSubjectOptionProductEdit
            case .Location:
                return LGLocalizedString.contactSubjectOptionLocation
            case .Login:
                return LGLocalizedString.contactSubjectOptionLogin
            case .Report:
                return LGLocalizedString.contactSubjectOptionReport
            case .Other:
                return LGLocalizedString.contactSubjectOptionOther
            }
        }
    }
    
    static var allValues: [ContactSubject] {
        return [.ProfileEdit, .ProductEdit, .Location, .Login, .Report, .Other]
    }
}
