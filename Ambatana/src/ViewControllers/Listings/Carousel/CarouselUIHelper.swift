import Foundation
import LGComponents

struct CarouselUI {
    static let bannerHeight: CGFloat = 64
    static let shareButtonVerticalSpacing: CGFloat = 5
    static let shareButtonHorizontalSpacing: CGFloat = 3

    static let pageControlWidth: CGFloat = 18
    static let pageControlMargin: CGFloat = 30
    static let moreInfoDragMargin: CGFloat = 45
    static let moreInfoExtraHeight: CGFloat = 62
    static let bottomOverscrollDragMargin: CGFloat = 70

    static let itemsMargin: CGFloat = 15
    static let buttonHeight: CGFloat = 50
    static let chatContainerMaxHeight: CGFloat = CarouselUI.buttonHeight + CarouselUI.itemsMargin + DirectAnswersHorizontalView.Layout.Height.standard
    static let buttonTrailingWithIcon: CGFloat = 75
    static let chatFooterTopMargin: CGFloat = Metrics.shortMargin
    
    enum ProPageControlUI {
        static let proPageControlWidth: CGFloat = 46.0
        static let proPageControlHeight: CGFloat = 126.0
        static let proPageControlLeadingConstant: CGFloat = 10.0
        static let proPageControlTopConstant: CGFloat = 26.0
    }
}

class CarouselUIHelper {

    static func buildShareButton(_ text: String?, icon: UIImage?) -> UIButton {
        let shareButton = UIButton(type: .system)
        setupShareButton(shareButton, text: text, icon: icon)
        return shareButton
    }

    static func setupShareButton(_ shareButton: UIButton, text: String?, icon: UIImage?) {
        shareButton.titleEdgeInsets = UIEdgeInsets(top: 0,
                                                   left: CarouselUI.shareButtonHorizontalSpacing,
                                                   bottom: 0,
                                                   right: -CarouselUI.shareButtonHorizontalSpacing)
        shareButton.contentEdgeInsets = UIEdgeInsets(top: CarouselUI.shareButtonVerticalSpacing,
                                                     left: 2*CarouselUI.shareButtonHorizontalSpacing,
                                                     bottom: CarouselUI.shareButtonVerticalSpacing,
                                                     right: 3*CarouselUI.shareButtonHorizontalSpacing)
        shareButton.setTitle(text, for: .normal)
        shareButton.setTitleColor(UIColor.white, for: .normal)
        shareButton.titleLabel?.font = UIFont.systemSemiBoldFont(size: 15)
        if let imageIcon = icon {
            shareButton.setImage(imageIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        shareButton.tintColor = UIColor.white
        shareButton.sizeToFit()
        shareButton.setRoundedCorners()
        shareButton.layer.backgroundColor = UIColor.blackTextLowAlpha.cgColor
    }

    static func buildMoreInfoTooltipText() -> NSAttributedString {
        let tapTextAttributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : UIColor.white,
                                                                NSAttributedStringKey.font : UIFont.systemBoldFont(size: 17)]
        let infoTextAttributes: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.foregroundColor : UIColor.grayLighter,
                                                                  NSAttributedStringKey.font : UIFont.systemSemiBoldFont(size: 17)]
        let plainText = R.Strings.productMoreInfoTooltipPart2(R.Strings.productMoreInfoTooltipPart1)
        let resultText = NSMutableAttributedString(string: plainText, attributes: infoTextAttributes)
        let boldRange = NSString(string: plainText).range(of: R.Strings.productMoreInfoTooltipPart1,
                                                                  options: .caseInsensitive)
        resultText.addAttributes(tapTextAttributes, range: boldRange)
        return resultText
    }
}
