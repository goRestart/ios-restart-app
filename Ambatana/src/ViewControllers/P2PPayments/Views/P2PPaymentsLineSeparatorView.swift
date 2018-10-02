import UIKit

final class P2PPaymentsLineSeparatorView: UIView {
    init() {
        super.init(frame: .zero)
        backgroundColor = .grayLight
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 1)
    }
}
