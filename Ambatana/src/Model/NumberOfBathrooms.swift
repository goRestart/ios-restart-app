import Foundation
import LGComponents

enum NumberOfBathrooms: Float {
    case zero = 0.0
    case one = 1.0
    case oneAndHalf = 1.5
    case two = 2.0
    case twoAndHalf = 2.5
    case three = 3.0
    case threeAndHalf = 3.5
    case four = 4.0
    
    var trackingString: String {
        return String(self.rawValue)
    }
    
    var localizedString: String {
        switch self {
        case .zero:
            return R.Strings.realEstateBathrooms0
        case .one:
            return R.Strings.realEstateBathrooms1
        case .oneAndHalf:
            return R.Strings.realEstateBathrooms15
        case .two:
            return R.Strings.realEstateBathrooms2
        case .twoAndHalf:
            return R.Strings.realEstateBathrooms25
        case .three:
            return R.Strings.realEstateBathrooms3
        case .threeAndHalf:
            return R.Strings.realEstateBathrooms35
        case .four:
            return R.Strings.realEstateBathrooms4
        }
    }
    
    var shortLocalizedString: String {
        switch self {
        case .zero:
            return R.Strings.realEstateTitleGeneratorBathrooms0
        case .one:
            return R.Strings.realEstateTitleGeneratorBathrooms1
        case .oneAndHalf:
            return R.Strings.realEstateTitleGeneratorBathrooms15
        case .two:
            return R.Strings.realEstateTitleGeneratorBathrooms2
        case .twoAndHalf:
            return R.Strings.realEstateTitleGeneratorBathrooms25
        case .three:
            return R.Strings.realEstateTitleGeneratorBathrooms3
        case .threeAndHalf:
            return R.Strings.realEstateTitleGeneratorBathrooms35
        case .four:
            return R.Strings.realEstateTitleGeneratorBathrooms4
        }
    }
    
    var summaryLocalizedString: String {
        switch self {
        case .zero:
            return R.Strings.realEstateBathrooms0
        case .one:
            return R.Strings.realEstateBathrooms1 + " " + R.Strings.realEstateSummaryBathroomTitle
        case .oneAndHalf:
            return R.Strings.realEstateBathrooms15 + " " + R.Strings.realEstateSummaryBathroomTitle
        case .two:
            return R.Strings.realEstateBathrooms2 + " " + R.Strings.realEstateSummaryBathroomsTitle
        case .twoAndHalf:
            return R.Strings.realEstateBathrooms25 + " " + R.Strings.realEstateSummaryBathroomTitle
        case .three:
            return R.Strings.realEstateBathrooms3 + " " + R.Strings.realEstateSummaryBathroomsTitle
        case .threeAndHalf:
            return R.Strings.realEstateBathrooms35 + " " + R.Strings.realEstateSummaryBathroomTitle
        case .four:
            return R.Strings.realEstateBathrooms4 + " " + R.Strings.realEstateSummaryBathroomsTitle
        }
    }
    
    var position: Int {
        switch self {
        case .zero:
            return 0
        case .one:
            return 1
        case .oneAndHalf:
            return 2
        case .two:
            return 3
        case .twoAndHalf:
            return 4
        case .three:
            return 5
        case .threeAndHalf:
            return 6
        case .four:
            return 7
        }
    }
    
    static var allValues: [NumberOfBathrooms] {
        return [.zero, .one, .oneAndHalf, .two, .twoAndHalf, .three, .threeAndHalf, .four]
    }
}
