import UIKit
import LGComponents

protocol PushPermissionsHeaderDelegate: class {
    func pushPermissionHeaderPressed()
}

class PushPermissionsHeader: UIView {

    static let viewHeight: CGFloat = 50

    private static let iconWidth: CGFloat = 55
    private static let disclosureWidth: CGFloat = 27
    private static let messageMargin: CGFloat = 8

    weak var delegate: PushPermissionsHeaderDelegate?

    // MARK: - Lifecycle

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTap()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = UIColor.lgBlack

        let icon = UIImageView(image: UIImage(named: "ic_messages"))
        icon.contentMode = .center
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)

        let label = UILabel()
        label.font = UIFont.systemMediumFont(size: 17)
        label.textColor = UIColor.grayLighter
        label.text = R.Strings.profilePermissionsHeaderMessage
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        let disclosure = UIImageView(image: UIImage(named: "ic_disclosure"))
        disclosure.contentMode = .center
        disclosure.translatesAutoresizingMaskIntoConstraints = false
        addSubview(disclosure)

        var views = [String: Any]()
        views["icon"] = icon
        views["label"] = label
        views["disclosure"] = disclosure

        var metrics = [String: Any]()
        metrics["iconWidth"] = PushPermissionsHeader.iconWidth
        metrics["disclosureWidth"] = PushPermissionsHeader.disclosureWidth
        metrics["messageMargin"] = PushPermissionsHeader.messageMargin

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon(iconWidth)]-0-[label]-messageMargin-[disclosure(disclosureWidth)]-0-|",
            options: [.alignAllCenterY], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[icon]-0-|",
            options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[disclosure]-0-|",
            options: [], metrics: nil, views: views))
    }

    private func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }

    @objc private dynamic func viewTapped() {
        delegate?.pushPermissionHeaderPressed()
    }
}
