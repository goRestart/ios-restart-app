//
//  LGTourPage.swift
//  LGTour
//
//  Created by Albert Hernández López on 28/10/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import UIKit

/**
    Defines the types of titles for a tour page.
*/
public enum LGTourPageTitle {
    case Text(String)
    case Image(UIImage?)
}

/**
    Data displayed in a tour page.
*/
public struct LGTourPage {
    let title: LGTourPageTitle
    let body: String
    let image: UIImage?
    
    public init(title: LGTourPageTitle, body: String, image: UIImage?) {
        self.title = title
        self.body = body
        self.image = image
    }
}