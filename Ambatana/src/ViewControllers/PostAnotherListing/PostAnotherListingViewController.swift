import UIKit
import LGCoreKit
import RxSwift
import LGComponents

final class PostAnotherListingViewController: BaseViewController {

    private struct Layout {
        static let closeButtonWidth: CGFloat = 44.0
        static let closeButtonHeight: CGFloat = 44.0
        static let postButtonHeight: CGFloat = 44.0
    }

    private let centeredLayoutGuide: UILayoutGuide = UILayoutGuide()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = R.Strings.postAnotherListingTitle
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemBoldFont(size: 18)
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = R.Strings.postAnotherListingDescription
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(size: 18)
        label.textColor = UIColor.darkGrayText
        return label
    }()
    private let postButton: UIButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        button.setTitle(R.Strings.postAnotherListingButton, for: .normal)
        button.addTarget(self, action: #selector(postButtonPressed), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemBoldFont(size: 17)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.veryBigMargin, bottom: 0, right: Metrics.veryBigMargin)
        return button
    }()
    private let closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        button.setImage(R.Asset.CongratsScreenImages.icCloseRed.image, for: .normal)
        return button
    }()

    private let viewModel: PostAnotherListingViewModel

    // MARK: - Lifecycle

    init(viewModel: PostAnotherListingViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)

        setupUI()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        view.backgroundColor = UIColor.white
        view.addLayoutGuide(centeredLayoutGuide)
        view.addSubviewsForAutoLayout([titleLabel, descriptionLabel, postButton, closeButton])

        NSLayoutConstraint.activate([
            centeredLayoutGuide.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centeredLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.margin),
            centeredLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.margin),

            titleLabel.topAnchor.constraint(equalTo: centeredLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: centeredLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: centeredLayoutGuide.trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metrics.margin),
            descriptionLabel.leadingAnchor.constraint(equalTo: centeredLayoutGuide.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: centeredLayoutGuide.trailingAnchor),

            postButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Metrics.bigMargin),
            postButton.centerXAnchor.constraint(equalTo: centeredLayoutGuide.centerXAnchor),
            postButton.bottomAnchor.constraint(equalTo: centeredLayoutGuide.bottomAnchor),
            postButton.heightAnchor.constraint(equalToConstant: Layout.postButtonHeight),

            closeButton.topAnchor.constraint(equalTo: view.safeTopAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: Layout.closeButtonHeight),
            closeButton.widthAnchor.constraint(equalToConstant: Layout.closeButtonWidth)
        ])
    }

    @objc private func postButtonPressed() {
        viewModel.postListing()
    }

    @objc private func closeButtonPressed() {
        viewModel.cancel()
    }

    func setAccessibilityIds() {
        closeButton.set(accessibilityId: .postAnotherListingCloseButton)
        titleLabel.set(accessibilityId: .postAnotherListingTitleLabel)
        descriptionLabel.set(accessibilityId: .postAnotherListingDescriptionLabel)
        postButton.set(accessibilityId: .postAnotherListingPostButton)
    }
}
