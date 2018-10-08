import LGComponents

enum LGWaterFallSettings {

    static let columnCount: Int = 2
    static let  itemRenderPolicy: WaterfallLayoutItemRenderPolicy = .leftToRight
    /// If the top header is a super sticky header, it can also be stretchy.
    static let topHeaderIsStretchy: Bool = false

    static let itemSize: CGSize = CGSize(width: 50,
                                         height: 50)
    static let headerHeight: CGFloat = 0
    static let footerHeight: CGFloat = 0
    static let minimumLineSpacing: CGFloat = 0
    static let sectionInset: UIEdgeInsets = UIEdgeInsets(top: Metrics.shortMargin,
                                                         left: Metrics.shortMargin,
                                                         bottom: 0,
                                                         right: Metrics.shortMargin)
}

