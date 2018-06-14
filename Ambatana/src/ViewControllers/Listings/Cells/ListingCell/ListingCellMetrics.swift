import Foundation
import LGComponents

fileprivate extension DeviceFamily {
    func shouldShow3Columns() -> Bool {
        return isWiderOrEqualThan(.iPhone6Plus)
    }
}

struct ListingCellMetrics {
    
    static let stripeIconWidth: CGFloat = 14
    static let sideMargin: CGFloat = DeviceFamily.current.shouldShow3Columns() ? 7.0 : Metrics.shortMargin
    static let minThumbnailHeightWithContent: CGFloat = 168
    static let minPriceAreaHeight: CGFloat = 52
    static let thumbnailImageStartingHeight: CGFloat = 165

    struct PriceLabel {
        static let height: CGFloat = DeviceFamily.current.shouldShow3Columns() ? 23 : 28
        static let topMargin: CGFloat = Metrics.shortMargin
        static let bottomMargin: CGFloat = Metrics.shortMargin
        static var font: UIFont {
            let fontSize: CGFloat = DeviceFamily.current.shouldShow3Columns() ? 19 : 23
            return UIFont.systemFont(ofSize: fontSize, weight: .bold)
        }
        static let totalHeight = PriceLabel.topMargin + PriceLabel.height + PriceLabel.bottomMargin
    }
    
    struct TitleLabel {
        static let topMargin: CGFloat = Metrics.veryShortMargin
        static let bottomMargin: CGFloat = Metrics.shortMargin
        static var fontMedium: UIFont {
            let fontSize: CGFloat = DeviceFamily.current.shouldShow3Columns() ? 13 : 15
            return UIFont.systemFont(ofSize: fontSize, weight: .medium)
        }
        static var fontBold: UIFont {
            let fontSize: CGFloat = DeviceFamily.current.shouldShow3Columns() ? 13 : 15
            return UIFont.systemFont(ofSize: fontSize, weight: .bold)
        }
    }
    
    struct ActionButton {
        static let topMargin = Metrics.shortMargin
        static let height = DeviceFamily.current.shouldShow3Columns() ? 30 : LGUIKitConstants.mediumButtonHeight
        static let bottomMargin = Metrics.shortMargin
        static let totalHeight = topMargin + height + bottomMargin
    }
    
    struct DistanceView {
        static let margin: CGFloat = 7.6
        static let iconHeight: CGFloat = 19.0
        static let iconWidth: CGFloat = 14
        static let gap: CGFloat = 4.0
        static var distanceLabelFont: UIFont {
            let fontSize: CGFloat = DeviceFamily.current.shouldShow3Columns() ? 11 : 13
            return UIFont.systemFont(ofSize: fontSize, weight: .bold)
        }
    }
    
    static func getTotalHeightForPriceAndTitleView(_ title: String?, containerWidth: CGFloat, font: UIFont = TitleLabel.fontMedium, maxLines: Int = 2) -> CGFloat {
        let priceHeight = minPriceAreaHeight
        guard let title = title else { return priceHeight }
        let labelWidth = containerWidth - 2 * sideMargin
        let titleHeight = title.heightForWidth(width: labelWidth, maxLines: maxLines, withFont: font)
        return priceHeight + titleHeight + TitleLabel.bottomMargin
    }
}
