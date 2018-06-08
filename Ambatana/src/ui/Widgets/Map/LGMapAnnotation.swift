import UIKit
import MapKit
import LGCoreKit
import LGComponents

enum MapAnnotationType {
    case general, realEstate
    
    func icon(_ selected: Bool, isFeatured: Bool) -> UIImage {
        if isFeatured {
            return selected ? selectedIconFeatured : R.Asset.IconsButtons.Map.icPinFeatured.image
        } else {
            return selected ? selectedIcon : R.Asset.IconsButtons.Map.icPin.image
        }
    }
    
    private var selectedIconFeatured: UIImage {
        switch self {
        case .general:
            return R.Asset.IconsButtons.Map.icPinFeatured.image
        case .realEstate:
            return R.Asset.IconsButtons.Map.icPinFeaturedRealEstate.image
        }
    }
    
    private var selectedIcon: UIImage {
        switch self {
        case .general:
            return R.Asset.IconsButtons.Map.icPin.image
        case .realEstate:
            return R.Asset.IconsButtons.Map.icPinFeaturedRealEstate.image
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

