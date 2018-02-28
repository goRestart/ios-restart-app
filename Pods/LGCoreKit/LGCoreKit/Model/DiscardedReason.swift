import Foundation

public enum DiscardedReason: String, Decodable {
    case badManners = "bad_manners"
    case duplicated = "duplicated"
    case drugsAndMedicines = "drugs_and_medicines"
    case gambling = "gambling"
    case nonRealisticPrice = "non_realistic_price"
    case poorAdQuality = "poor_ad_quality"
    case photoUnclear = "photo_unclear"
    case sexuallyRelated = "sexually_related"
    case referenceToCompetitors = "reference_to_competitors"
    case usedCosmetics = "used_cosmetics"
    case weaponsRelated = "weapons_related"
    case illegalContent = "illegal_content"
    case perishables = "perishables"
    case animals = "animals"
    case services = "services"
    case suspectedScam = "suspected_scam"
    case copyright = "copyright"
    case others = "others"
    case tobacco = "tobacco"
    case recall = "recall"
    case stockPhotoOnly = "stock_photo_only"

    public static let allValues: [DiscardedReason] = [
        .badManners, .duplicated, .drugsAndMedicines, .gambling, .nonRealisticPrice, .poorAdQuality, .photoUnclear,
        .sexuallyRelated, .referenceToCompetitors, .usedCosmetics, .weaponsRelated, .illegalContent, .perishables,
        .animals, .services, .suspectedScam, .copyright, .others, .tobacco, .recall, .stockPhotoOnly
    ]
    
    public var isAllowedToBeEdited: Bool {
        switch self {
            case .badManners, .duplicated, .nonRealisticPrice, .poorAdQuality, .photoUnclear, .referenceToCompetitors,
                 .others, .stockPhotoOnly:
                return true
            case .drugsAndMedicines, .gambling, .sexuallyRelated, .usedCosmetics, .weaponsRelated, .illegalContent,
                 .perishables, .animals, .services, .suspectedScam, .copyright, .tobacco, .recall:
                return false
        }
    }
}
