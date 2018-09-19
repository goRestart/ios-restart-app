import LGComponents
import UIKit

final class AffiliationChallengesHeaderView: UITableViewHeaderFooterView, ReusableCell {
    private enum Layout {
        static let padding: CGFloat = 24
        static let verticalSpacing: CGFloat = 28
    }

    private let walletView = AffiliationWalletView()
    private let title: UILabel = {
        let label = UILabel()
        label.text = R.Strings.affiliationChallengesSubtitle
        label.numberOfLines = 1
        label.font = UIFont.systemBoldFont(size: 16)
        label.textColor = .grayDark
        return label
    }()

    var tapCallback: (() -> Void)?


    // MARK: - Lifecycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
        setupGestureRecognizer()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubviewsForAutoLayout([walletView, title])
        let constraints = [walletView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                               constant: Layout.padding),
                           walletView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                                constant: -Layout.padding),
                           walletView.topAnchor.constraint(equalTo: topAnchor),
                           title.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                          constant: Layout.padding),
                           title.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                           constant: -Layout.padding),
                           title.topAnchor.constraint(equalTo: walletView.bottomAnchor,
                                                      constant: Layout.verticalSpacing),
                           title.bottomAnchor.constraint(equalTo: bottomAnchor)]
        constraints.activate()
    }

    func set(walletPoints: Int) {
        walletView.set(points: walletPoints)
    }

    private func setupGestureRecognizer() {
        walletView.removeAllGestureRecognizers()
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(didTap))
        walletView.addGestureRecognizer(gestureRecognizer)
    }

    @objc private func didTap() {
        tapCallback?()
    }
}
