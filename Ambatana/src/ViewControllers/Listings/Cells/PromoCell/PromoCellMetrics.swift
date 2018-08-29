import LGComponents

struct PromoCellMetrics {
    
    static let height: CGFloat = 233
    
    struct Stack {
        static let margin: CGFloat = Metrics.margin
        static let largeMargin: CGFloat = 32.0
        static let largeBottomMargin: CGFloat = 32.0
    }
    
    struct Title {
        static let font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
    }
    
    struct PostButton {
        static let bottomMargin: CGFloat = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus) ? Metrics.margin :
            Metrics.bigMargin
        static let height: CGFloat = 30
        static let width: CGFloat = 95
        static let horizontalInsets: CGFloat = 32
    }
}
