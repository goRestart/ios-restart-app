//
//  PasswordlessEmailSentViewController.swift
//  LetGo
//
//  Created by Sergi Gracia on 30/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGComponents

final class PasswordlessEmailSentViewController: BaseViewController {

    private let viewModel: PasswordlessEmailSentViewModel

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.Asset.IconsButtons.icMagic.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blackText
        label.font = .passwordLessEmailTitleFont
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = R.Strings.passwordlessEmailSentTitle
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayDisclaimerText
        label.font = .passwordLessEmailDescriptionFont
        label.textAlignment = .center
        return label
    }()

    private struct Layout {
        static let imageTopMargin: CGFloat = 100
        static let imageSize: CGFloat = 150
        static let titleTopMargin: CGFloat = 30
        static let subtitleTopMargin: CGFloat = 10
        static let horizontalMargin: CGFloat = 40
    }

    init(viewModel: PasswordlessEmailSentViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAccessibilityIds()
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setNavBarBackgroundStyle(.white)
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = R.Strings.passwordlessEmailSentScreenTitle
        view.addSubviewsForAutoLayout([imageView, titleLabel, subtitleLabel])
        subtitleLabel.text = R.Strings.passwordlessEmailSentSubtitle(viewModel.email)

        setupNavBarActions()
        setupConstraints()
    }

    private func setupNavBarActions() {
        let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close_red"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(didTapClose))
        navigationItem.leftBarButtonItem = closeButton

        let helpButton = UIBarButtonItem(title: R.Strings.mainSignUpHelpButton,
                                         style: .plain,
                                         target: self,
                                         action: #selector(didTapHelp))
        navigationItem.rightBarButtonItem = helpButton
    }

    private func setupConstraints() {
        let constraints = [
            imageView.topAnchor.constraint(equalTo: safeTopAnchor, constant: Layout.imageTopMargin),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Layout.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: Layout.imageSize),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Layout.titleTopMargin),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.horizontalMargin),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.horizontalMargin),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.subtitleTopMargin),
            subtitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.horizontalMargin),
            subtitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Layout.horizontalMargin),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupAccessibilityIds() {
        titleLabel.set(accessibilityId: .passwordlessEmailSentTitleLabel)
        subtitleLabel.set(accessibilityId: .passwordlessEmailSentSubtitleLabel)
        imageView.set(accessibilityId: .passwordlessEmailSentImageView)
    }

    @objc private func didTapClose() {
        viewModel.didTapClose()
    }

    @objc private func didTapHelp() {
        viewModel.didTapHelp()
    }
}
