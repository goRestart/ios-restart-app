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
                return NSLocalizedString("contact_subject_option_profile_edit", comment: "")
            case .ProductEdit:
                return NSLocalizedString("contact_subject_option_product_edit", comment: "")
            case .Location:
                return NSLocalizedString("contact_subject_option_location", comment: "")
            case .Login:
                return NSLocalizedString("contact_subject_option_login", comment: "")
            case .Report:
                return NSLocalizedString("contact_subject_option_report", comment: "")
            case .Other:
                return NSLocalizedString("contact_subject_option_other", comment: "")
            }
        }
    }
    
    static var allValues: [ContactSubject] {
        return [.ProfileEdit, .ProductEdit, .Location, .Login, .Report, .Other]
    }
}
