//
//  UserView.swift
//  LetGo
//
//  Created by Albert Hernández López on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

protocol UserViewDelegate: class {
    func userViewAvatarPressed(userView: UserView)
    func userViewAvatarLongPressStarted(userView: UserView)
    func userViewAvatarLongPressEnded(userView: UserView)
    func userViewTextInfoContainerPressed(userView: UserView)
}

enum UserViewStyle {
    case CompactShadow(size: CGSize)
    case CompactBorder(size: CGSize)
    case Full
    case WithProductInfo

    var bgColor: UIColor {
        switch self {
        case .Full:
            return UIColor.white.colorWithAlphaComponent(0.9)
        case .CompactShadow, .CompactBorder, WithProductInfo:
            return UIColor.clearColor()
        }
    }

    var usernameLabelFont: UIFont {
        switch self {
        case .Full:
            return UIFont.mediumBodyFont
        case .CompactShadow, .CompactBorder:
            return UIFont.smallBodyFont
        case .WithProductInfo:
            return UIFont.systemMediumFont(size: 17)
        }
    }

    var usernameLabelColor: UIColor {
        switch self {
        case .Full:
            return UIColor.black
        case .CompactShadow, .CompactBorder, WithProductInfo:
            return UIColor.white
        }
    }

    var subtitleLabelFont: UIFont {
        switch self {
        case .Full:
            return UIFont.systemRegularFont(size: 13)
        case .CompactShadow, .CompactBorder:
            return UIFont.systemRegularFont(size: 11)
        case .WithProductInfo:
            return UIFont.systemBoldFont(size: 21)
        }
    }

    var subtitleLabelColor: UIColor {
        switch self {
        case .Full:
            return UIColor.black
        case .CompactShadow, .CompactBorder, .WithProductInfo:
            return UIColor.white
        }
    }

    var avatarBorderColor: UIColor? {
        switch self {
        case .Full, .CompactShadow:
            return nil
        case .CompactBorder, WithProductInfo:
            return UIColor.white
        }
    }
    
    var textHasShadow: Bool {
        switch self {
        case .Full, .CompactBorder, .CompactShadow:
            return false
        case .WithProductInfo:
            return true
        }
    }
}

class UserView: UIView {
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet var avatarMarginConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var textInfoContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ratingsContainer: UIView!
    @IBOutlet weak var ratingsContainerHeight: NSLayoutConstraint!

    let userRatings = Variable<Float?>(nil)

    private static let ratingsViewVisibleHeight: CGFloat = 12

    private var style: UserViewStyle = .Full
    private var avatarURL: NSURL?   // Used as an "image id" to avoid loading the avatar of the previous user
                                    //if the current doesn't has one

    weak var delegate: UserViewDelegate?

    private let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle

    static func userView(style: UserViewStyle) -> UserView {
        let view = NSBundle.mainBundle().loadNibNamed("UserView", owner: self, options: nil)?.first as? UserView
        view?.style = style
        view?.setup()
        return view!
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.height / 2
    }

    
    // MARK: - Public methods

    func setupWith(userAvatar avatar: NSURL?, userName: String?, userId: String?) {
        setupWith(userAvatar: avatar, userName: userName, subtitle: nil, userId: userId)
    }

    func setupWith(userAvatar avatar: NSURL?, userName: String?, subtitle: String?, userId: String?) {
        let placeholder = LetgoAvatar.avatarWithID(userId, name: userName)
        setupWith(userAvatar: avatar, placeholder: placeholder, userName: userName, subtitle: subtitle)
    }
    
    func setupWith(userAvatar avatar: NSURL?, userName: String?, productTitle: String?, productPrice: String?, userId: String?) {
        let placeholder = LetgoAvatar.avatarWithID(userId, name: userName)
        setupWith(userAvatar: avatar, placeholder: placeholder, userName: productTitle, subtitle: productPrice)
    }

    func setupWith(userAvatar avatar: NSURL?, placeholder: UIImage?, userName: String?, subtitle: String?) {
        avatarURL = avatar
        userAvatarImageView.image = placeholder
        if let avatar = avatar {
            ImageDownloader.sharedInstance.downloadImageWithURL(avatar) { [weak self] result, url in
                guard let imageWithSource = result.value where url == self?.avatarURL else { return }
                self?.userAvatarImageView.image = imageWithSource.image
            }
        }
        titleLabel.text = userName
        subtitleLabel.text = subtitle
        
        if style.textHasShadow {
            [titleLabel, subtitleLabel].forEach { label in
                label.layer.shadowColor = UIColor.black.CGColor
                label.layer.shadowOffset = CGSize.zero
                label.layer.shadowRadius = 2.0
                label.layer.shadowOpacity = 0.5
            }
        }
    }
    
    func showShadow(show: Bool) {
        if show {
            layer.shadowOffset = CGSize.zero
            layer.shadowOpacity = 0.24
            layer.shadowRadius = 2.0
        } else {
            layer.shadowOpacity = 0.0
            layer.shadowRadius = 0.0
        }
    }


    // MARK: - Private methods

    private func setup() {
        clipsToBounds = false
        
        showShadow(true)

        backgroundColor = style.bgColor
        titleLabel.font = style.usernameLabelFont
        titleLabel.textColor = style.usernameLabelColor
        subtitleLabel.font = style.subtitleLabelFont
        subtitleLabel.textColor = style.subtitleLabelColor

        if let borderColor = style.avatarBorderColor {
            userAvatarImageView.layer.borderWidth = 2
            userAvatarImageView.layer.borderColor = borderColor.CGColor
        }
        let tapGestureOnAvatar = UITapGestureRecognizer(target: self, action: #selector(avatarPressed))
        userAvatarImageView.addGestureRecognizer(tapGestureOnAvatar)
        
        let tapGestureOnText = UITapGestureRecognizer(target: self, action: #selector(textPressed))
        textInfoContainer.addGestureRecognizer(tapGestureOnText)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(avatarLongPressed(_:)))
        addGestureRecognizer(longPressGesture)

        userRatings.asObservable().bindNext { [weak self] userRating in
            let rating = userRating ?? 0
            if rating > 0 {
                self?.ratingsContainerHeight.constant = UserView.ratingsViewVisibleHeight
                self?.ratingsContainer.setupRatingContainer(rating: rating)
            } else {
                self?.ratingsContainerHeight.constant = 0
            }
            self?.subtitleLabel.hidden = rating > 0
        }.addDisposableTo(disposeBag)

        setAccesibilityIds()
    }

    dynamic private func avatarPressed() {
        delegate?.userViewAvatarPressed(self)
    }
    
    dynamic private func textPressed() {
        delegate?.userViewTextInfoContainerPressed(self)
    }

    dynamic private func avatarLongPressed(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            delegate?.userViewAvatarLongPressStarted(self)
        case .Cancelled, .Ended:
            delegate?.userViewAvatarLongPressEnded(self)
        default:
            break
        }
    }

    private func setAccesibilityIds() {
        titleLabel.accessibilityId = .UserViewNameLabel
        subtitleLabel.accessibilityId = .UserViewSubtitleLabel
        textInfoContainer.accessibilityId = .UserViewTextInfoContainer
    }
}
