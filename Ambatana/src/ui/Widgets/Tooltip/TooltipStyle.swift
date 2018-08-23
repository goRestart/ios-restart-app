import LGComponents

enum TooltipStyle {
    case black(closeEnabled: Bool)
    case blue(closeEnabled: Bool)
    
    static let minWidthWithCloseButton: CGFloat = 200
    static let minWidthWithoutCloseButton: CGFloat = 150
    
    var closeEnabled: Bool {
        switch self {
        case let .black(closeEnabled):
            return closeEnabled
        case let .blue(closeEnabled):
            return closeEnabled
        }
    }
    
    var bgColor: UIColor {
        switch self {
        case .black:
            return UIColor.blackTooltip.withAlphaComponent(0.95)
        case .blue:
            return UIColor.blueTooltip.withAlphaComponent(0.95)
        }
    }
    
    var centeredPeak: UIImage? {
        return R.Asset.IconsButtons.tooltipPeakCenterBlack.image.withRenderingMode(.alwaysTemplate)
    }
    
    var leftSidePeak: UIImage? {
        return R.Asset.IconsButtons.tooltipPeakSideBlack.image.withRenderingMode(.alwaysTemplate)
    }
    
    var rightSidePeak: UIImage? {
        guard let originalImg = leftSidePeak, let cgImg = originalImg.cgImage else { return nil }
        return UIImage.init(cgImage: cgImg, scale: originalImg.scale, orientation: .upMirrored)
    }
    
    var minWidth: CGFloat {
        return closeEnabled ? TooltipStyle.minWidthWithCloseButton : TooltipStyle.minWidthWithoutCloseButton
    }
}
