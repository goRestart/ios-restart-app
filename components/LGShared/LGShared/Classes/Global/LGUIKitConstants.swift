import UIKit

public struct LGUIKitConstants {

    // MARK: - Constraint Constants
    // Distance To main view
    public static let itemDistanceToTop = 15
    public static let itemDistanceToBottom = 15
    public static let itemDistanceToLeft = 15
    public static let itemDistanceToRight = 15

    // Distance Between elements
    public static let verticalDistanceLarge = 30
    public static let verticalDistanceMedium = 20
    public static let verticalDistanceSmall = 10

    public static let horitzontalDistanceMedium = 10
    public static let horitzontalDistanceSmall = 5
    
    public static let tabBarSellFloatingButtonDistance: CGFloat = 15

    // Message Distances
    private static let messageLongDistance = 50
    private static let messageShortDistance = 10

    public static let myMessageLeading = messageLongDistance
    public static let myMessageTrailing = messageShortDistance
    public static let otherMessageLeading = messageShortDistance
    public static let otherMessageTrailing = messageLongDistance
    public static let verticalDistanceMessages = 5

    // Max Widths
    public static let alertWidth = 270
    public static let tooltipWidth: CGFloat = 270

    // MARK: - Corner radius
    public static let smallCornerRadius: CGFloat = 4
    public static let mediumCornerRadius: CGFloat = 10
    public static let bigCornerRadius: CGFloat = 15
    
    // MARK: - Button Heights
    public static let bigButtonHeight: CGFloat = 50
    public static let mediumButtonHeight: CGFloat = 44
    public static let smallButtonHeight: CGFloat = 30
    public static let tabBarSellFloatingButtonHeight: CGFloat = 60

    // MARK: - Sizes
    public static var onePixelSize: CGFloat {
        return 1 / UIScreen.main.scale
    }
    public static let enabledButtonHeight: CGFloat = 44

    //0.9 so it will consider images that are slightly vertical as horizontal ones (for better rendering)
    public static let horizontalImageMinAspectRatio: CGFloat = 0.9

    // MARK: - Highlighted
    public static let highlightedStateAlpha: CGFloat = 0.6

    // MARK: - Animation

    public static let defaultAnimationTime: TimeInterval = 0.2

    // MARK: - Ads
    public static let advertisementCellPlaceholderHeight: CGFloat = 220
    public static let advertisementCellMoPubHeight: CGFloat = 290

    // MARK: - Map Pin
    public static let mapPinHeight: CGFloat = 37
    public static let mapPinWidth: CGFloat = 26
}
