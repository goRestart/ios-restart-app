import LGComponents

enum FilterServicesSection {
    case type, subtype
    
    static var all: [FilterServicesSection] {
        return [.type, .subtype]
    }
    
    var title: String {
        switch self {
        case .type:
            return R.Strings.servicesServiceTypeTitle
        case .subtype:
            return R.Strings.servicesServiceSubtypeTitle
        }
    }
}

