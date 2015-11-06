//
//  NSBundle+LG.swift
//  LGTour
//
//  Created by AHL on 28/10/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import UIKit

extension NSBundle {
    /**
        Returns the LGTour bundle.
    
        - returns: The LGTour bundle.
    */
    internal static func LGTourBundle() -> NSBundle {
        let frameworkBundle = NSBundle(forClass: LGTourViewController.self)
        let url = frameworkBundle.URLForResource("LGTourBundle", withExtension: "bundle")!
        return NSBundle(URL: url)!
    }
}
