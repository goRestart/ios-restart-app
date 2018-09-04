import LGComponents

struct WaterFallLayoutSettings {

    // Elements sizes
    static let headerHeight: CGFloat = 0
    static let  footerHeight: CGFloat = 0
    static let itemSize: CGSize = CGSize(width: 50, height: 50)
    
    // Behaviours
    static let columnCount: Int = 2
    static let  itemRenderPolicy: WaterfallLayoutItemRenderPolicy = .shortestFirst
    /// If the top header is a super sticky header, it can also be stretchy.
    static let topHeaderIsStretchy: Bool = false
    
    // Spacing
    static let minimumColumnSpacing: CGFloat = Metrics.shortMargin
    static let minimumLineSpacing: CGFloat = Metrics.shortMargin
    static let sectionInset: UIEdgeInsets = UIEdgeInsets(top: Metrics.shortMargin,
                                                         left: Metrics.shortMargin,
                                                         bottom: 0,
                                                         right: Metrics.shortMargin)
}
