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
        
        static var prefixFont: UIFont {
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

    struct BumpUpIcon {
        static let iconHeight: CGFloat = 20
        static let iconWidth: CGFloat = 20
        static let leftMargin: CGFloat = Metrics.margin
        static let rightMargin: CGFloat = Metrics.veryShortMargin
    }

    struct BumpUpLabel {
        static let topMargin: CGFloat = Metrics.margin
        static let bottomMargin: CGFloat = Metrics.margin
        static let rightMargin: CGFloat = Metrics.margin
        static var font: UIFont {
            let fontSize: Int = DeviceFamily.current.shouldShow3Columns() ? 13 : 15
            return UIFont.systemBoldFont(size: fontSize)
        }
    }
    
    static func getTotalHeightForPriceAndTitleView(titleViewModel: ListingTitleViewModel?,
                                                   containerWidth: CGFloat,
                                                   maxLines: Int = 2) -> CGFloat {
        let priceHeight = minPriceAreaHeight
        guard let titleViewModel = titleViewModel else { return priceHeight }
        let sideMarginOffset: CGFloat = 5.0
        let labelWidth = containerWidth - ((2 * sideMargin)+sideMarginOffset)
        let titleHeight = titleViewModel.height(forWidth: labelWidth,
                                                maxLines: maxLines,
                                                fontDescriptor: ProductPriceAndTitleView.TitleFontDescriptor())
        return priceHeight + titleHeight + TitleLabel.bottomMargin
    }

    static func getTotalHeightForBumpUpCTA(text: String?, containerWidth: CGFloat) -> CGFloat {
        guard let text = text else { return 0.0 }
        let marginsTotalSpace = BumpUpIcon.leftMargin + BumpUpIcon.iconWidth + BumpUpIcon.rightMargin + BumpUpLabel.rightMargin
        let labelWidth = (containerWidth - marginsTotalSpace) - 2 * sideMargin
        let textHeight = text.heightForWidth(width: labelWidth, maxLines: 2, withFont: BumpUpLabel.font)
        return textHeight + BumpUpLabel.bottomMargin + BumpUpLabel.topMargin
    }
}
