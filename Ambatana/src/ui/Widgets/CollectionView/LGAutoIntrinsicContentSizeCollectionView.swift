import Foundation

class LGAutoIntrinsicContentSizeCollectionView: UICollectionView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !bounds.size.equalTo(intrinsicContentSize) {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        get {
            return contentSize
        }
    }

    private func setup() {
        self.isScrollEnabled = false
        self.bounces = false
    }
}
