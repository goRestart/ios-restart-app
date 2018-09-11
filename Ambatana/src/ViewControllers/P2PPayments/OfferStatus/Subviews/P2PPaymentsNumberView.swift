import UIKit

final class P2PPaymentsNumberView: UIView {
    enum State {
        case number(Int)
        case success
        case fail
    }

    var state: State = .number(0)

    private let numberLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        return iconImageView
    }()

    private let backgrounView: UIView = UIView()

    init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        addSubviewsForAutoLayout([numberLabel, iconImageView])
        layer.borderWidth = 4
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 16
        backgroundColor = UIColor.red
        NSLayoutConstraint.activate([
        ])
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 32, height: 32)
    }
}
