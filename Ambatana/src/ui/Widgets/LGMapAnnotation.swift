//
//  LGMapAnnotation.swift
//  LetGo
//
//  Created by Tomas Cobo on 04/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import MapKit
import LGCoreKit


enum MapAnnotationType {
    case general, realEstate
    
    func icon(_ selected: Bool, isFeatured: Bool) -> UIImage {
        if isFeatured {
            return selected ? selectedIconFeatured : #imageLiteral(resourceName: "ic_pin_featured")
        } else {
            return selected ? selectedIcon : #imageLiteral(resourceName: "ic_pin")
        }
    }
    
    private var selectedIconFeatured: UIImage {
        switch self {
        case .general:
            return #imageLiteral(resourceName: "ic_pin_featured")
        case .realEstate:
            return #imageLiteral(resourceName: "ic_pin_featured_real_estate")
        }
    }
    
    private var selectedIcon: UIImage {
        switch self {
        case .general:
            return #imageLiteral(resourceName: "ic_pin")
        case .realEstate:
            return #imageLiteral(resourceName: "ic_pin_real_estate")
        }
    }

}

struct LGMapAnnotationConfiguration {
    let location: LGLocationCoordinates2D
    let title: String?
    let type: MapAnnotationType
    let isFeatured: Bool
}

extension LGMapAnnotationConfiguration {
    func icon(_ selected: Bool) -> UIImage {
        return type.icon(selected, isFeatured: isFeatured)
    }
}

final class LGMapAnnotation: NSObject, MKAnnotation, ReusableCell {
    
    private var configuration: LGMapAnnotationConfiguration
    var icon: UIImage
    
    init(configuration: LGMapAnnotationConfiguration) {
        self.configuration = configuration
        self.icon = configuration.icon(false)
        super.init()
    }
    
    var coordinate: CLLocationCoordinate2D {
        return location.coordinates2DfromLocation()
    }
    
    var location: LGLocationCoordinates2D {
        return configuration.location
    }
    
    var selectedAnnotation: UIImage {
        return configuration.icon(true)
    }
    
    var deselectedAnnotation: UIImage {
        return configuration.icon(false)
    }

}

