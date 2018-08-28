import LGComponents

enum PromoCellType {
    case realEstate, car, services

    var postCategory: PostCategory {
        switch self {
        case .realEstate:
            return .realEstate
        case .car:
            return .car
        case .services:
            return .services
        }
    }
    
    var postingSource: PostingSource {
        switch self {
        case .realEstate:
            return .realEstatePromo
        case .car:
            return .carPromo
        case .services:
            return .servicesPromo
        }
    }
}

struct PromoCellData {
    let appearance: CellAppearance
    let arrangement: PromoCellArrangement
    let title: String?
    let attributedTitle: NSAttributedString?
    let image: UIImage
    let type: PromoCellType
    
    init(appearance: CellAppearance,
         arrangement: PromoCellArrangement,
         title: String? = nil,
         attributedTitle: NSAttributedString? = nil,
         image: UIImage,
         type: PromoCellType) {
        self.appearance = appearance
        self.arrangement = arrangement
        self.title = title
        self.attributedTitle = attributedTitle
        self.image = image
        self.type = type
    }
}
