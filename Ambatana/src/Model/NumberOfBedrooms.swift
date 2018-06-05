import Foundation
import LGComponents

enum NumberOfBedrooms: Int {
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    
    var localizedString: String {
        switch self {
        case .zero:
            return R.Strings.realEstateBedrooms0
        case .one:
            return R.Strings.realEstateBedrooms1
        case .two:
            return R.Strings.realEstateBedrooms2
        case .three:
            return R.Strings.realEstateBedrooms3
        case .four:
            return R.Strings.realEstateBedrooms4
        }
    }

    var shortLocalizedString: String {
        switch self {
        case .zero:
            return R.Strings.realEstateTitleGeneratorBedroomsStudio
        case .one:
            return R.Strings.realEstateTitleGeneratorBedroomsOne
        case .two:
            return R.Strings.realEstateTitleGeneratorBedroomsTwo
        case .three:
            return R.Strings.realEstateTitleGeneratorBedroomsThree
        case .four:
            return R.Strings.realEstateTitleGeneratorBedroomsFour
        }
    }
    
    var summaryLocalizedString: String {
        switch self {
        case .zero:
            return R.Strings.realEstateBedrooms0
        case .one:
            return R.Strings.realEstateBedrooms1 + " " + R.Strings.realEstateSummaryBedroomTitle
        case .two:
            return R.Strings.realEstateBedrooms2 + " " + R.Strings.realEstateSummaryBedroomsTitle
        case .three:
            return R.Strings.realEstateBedrooms3 + " " + R.Strings.realEstateSummaryBedroomsTitle
        case .four:
            return R.Strings.realEstateBedrooms4 + " " + R.Strings.realEstateSummaryBedroomsTitle
        }
    }
    
    var position: Int {
        switch self {
        case .zero:
            return 0
        case .one:
            return 1
        case .two:
            return 2
        case .three:
            return 3
        case .four:
            return 4
        }
    }
    
    static var allValues: [NumberOfBedrooms] {
        return [.zero, .one, .two, .three, .four]
    }
}
