//
//  Listing+Map.swift
//  LetGo
//
//  Created by Tomas Cobo on 09/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import MapKit

private extension Listing {
    
    var type: MapAnnotationType {
        switch self {
        case .product, .car: return .general
        case .realEstate: return .realEstate
        }
    }
    
    var configuration: LGMapAnnotationConfiguration {
        return LGMapAnnotationConfiguration(location: location,
                                            title: name ?? "",
                                            type: type,
                                            isFeatured: featured ?? false)
    }
    
    var annotation: MKAnnotation {
        return LGMapAnnotation(configuration: configuration)
    }
    
}


extension Array where Element == Listing {
    var annotations: [MKAnnotation] {
        return map { $0.annotation }
    }
}
