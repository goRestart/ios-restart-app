
enum ListingAttributeGridTheme {
    case light, dark
}

extension ListingAttributeGridTheme {
    
    var backgroundColor: UIColor {
        switch self {
        case .dark:
            return .clear
        case .light:
            return .white
        }
    }
    
    var selectedTintColour: UIColor {
        switch self {
        case .dark:
            return .white
        case .light:
            return .redText
        }
    }
    
    var defaultTintColour: UIColor {
        switch self {
        case .dark:
            return .white
        case .light:
            return .gray
        }
    }
}
