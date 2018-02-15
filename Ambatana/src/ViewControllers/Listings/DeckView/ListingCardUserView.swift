//
//  ListingCardUserView.swift
//  LetGo
//
//  Created by Facundo Menzella on 06/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

final class ListingCardUserView: UIView {
    enum Action {
        case favourite(isOn: Bool)
        case edit

        fileprivate func setupListingCardUserView(_ view: ListingCardUserView) {
            switch self {
            case .favourite(let isOn):
                view.set(favourite: isOn)
            case .edit:
                view.setEditMode()
            }
        }
    }
    struct Images {
        static let favourite = #imageLiteral(resourceName: "nit_favourite")
        static let favouriteOn = #imageLiteral(resourceName: "nit_favourite_on")

        static let edit = #imageLiteral(resourceName: "nit_edit")
        static let placeholder = #imageLiteral(resourceName: "user_placeholder")
        static let share = #imageLiteral(resourceName: "nit_share")
    }

    struct Constant {
        struct Height { static let userIcon: CGFloat = 34.0 }
        struct Width {  static let shareProportion: CGFloat = 0.15 }
    }

    override var intrinsicContentSize: CGSize { return CGSize(width: UIViewNoIntrinsicMetric, height: 68.0) } // totally arbitrary

    let rxShareButton: Reactive<UIButton>
    let rxActionButton: Reactive<UIButton>

    private let userIcon = UIImageView(image: Images.placeholder)
    private let userNameLabel = UILabel()

    private let effect = UIBlurEffect(style: .light)
    let effectView: UIVisualEffectView

    private let actionLayoutGuide = UILayoutGuide()
    private let actionButton = UIButton()
    private let shareButton = UIButton()

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        effectView = UIVisualEffectView(effect: effect)
        rxShareButton = shareButton.rx
        rxActionButton = actionButton.rx

        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func populate(withUserName userName: String, icon: URL?, imageDownloader: ImageDownloaderType) {
        userNameLabel.text = userName
        actionButton.tintColor = .white

        guard let url = icon else { return }
        imageDownloader.downloadImageWithURL(url, completion: { [weak self] (result, url) in
            if let value = result.value {
                self?.userIcon.image = value.image
            }
        })
    }

    func set(action: Action) {
        action.setupListingCardUserView(self)
    }

    fileprivate func set(favourite isFavourite: Bool) {
        if isFavourite {
            actionButton.setImage(Images.favouriteOn, for: .normal)
        } else {
            actionButton.setImage(Images.favourite, for: .normal)
        }
    }

    fileprivate func setEditMode() {
        actionButton.setImage(Images.edit, for: .normal)
    }

    @objc private func didTouchUpShareButton() {
        shareButton.bounce()
    }

    @objc private func didTouchUpActionButton() {
        actionButton.bounce()
    }

    private func setupUI() {
        setupBlur()
        setupGradient()
        setupUserIcon()
        setupUserInfo()
        setupActions()
    }

    private func setupBlur() {
        effectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(effectView)
        effectView.layout(with: self).fill()
        effectView.backgroundColor = UIColor.clear

        effectView.alpha = 0
    }

    private func setupGradient() {
        let gradient = GradientView(colors: [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0.2)])
        gradient.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gradient)
        gradient.layout(with: self).fill()
    }

    private func setupUserIcon() {
        userIcon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(userIcon)
        userIcon.layout(with: self)
            .top(by: Metrics.shortMargin)
            .leading(by: Metrics.margin).bottom(by: -Metrics.margin, relatedBy: .greaterThanOrEqual)
        userIcon.layout().width(Constant.Height.userIcon).widthProportionalToHeight()

        userIcon.contentMode = .scaleAspectFill
    }

    private func setupUserInfo() {
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(userNameLabel)
        userNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        userNameLabel.layout(with: userIcon).leading(to: .trailingMargin, by: Metrics.margin).top()
        userNameLabel.layout(with: userIcon).bottom(relatedBy: .greaterThanOrEqual)
        userNameLabel.font = UIFont.deckUsernameFont
        userNameLabel.textColor = .white
    }

    private func setupActions() {
        addLayoutGuide(actionLayoutGuide)
        addSubview(actionButton)
        addSubview(shareButton)

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setImage(Images.favourite, for: .normal)
        actionButton.imageView?.contentMode = .center
        actionButton.addTarget(self, action: #selector(didTouchUpActionButton), for: .touchUpInside)

        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setImage(Images.share, for: .normal)
        shareButton.imageView?.contentMode = .center

        shareButton.layout(with: actionButton).proportionalWidth()
        shareButton.layout(with: self).proportionalWidth(multiplier: Constant.Width.shareProportion)

        actionButton.layout(with: actionLayoutGuide).leading().top().bottom()
        shareButton.layout(with: actionLayoutGuide).trailing().top().bottom()
        shareButton.layout(with: actionButton).leading(to: .trailing)
        shareButton.addTarget(self, action: #selector(didTouchUpShareButton), for: .touchUpInside)

        actionLayoutGuide.leadingAnchor.constraint(equalTo: userNameLabel.trailingAnchor,
                                                   constant: Metrics.margin).isActive = true
        actionLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.veryShortMargin).isActive = true
        actionLayoutGuide.topAnchor.constraint(equalTo: userNameLabel.topAnchor).isActive = true
        actionLayoutGuide.bottomAnchor.constraint(equalTo: userIcon.bottomAnchor).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userIcon.cornerRadius = min(userIcon.width, userIcon.height) / 2.0
    }
}

