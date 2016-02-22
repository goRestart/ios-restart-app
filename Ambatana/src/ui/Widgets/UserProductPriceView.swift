//
//  UserProductPriceView.swift
//  LetGo
//
//  Created by Albert Hernández López on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol UserProductPriceViewDelegate: class {
    func userProductPriceViewAvatarPressed(userProductPriceView: UserProductPriceView)
}

enum UserProductPriceViewStyle {
    case Compact(size: CGSize), Full
}

class UserProductPriceView: UIView {
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet var avatarMarginConstraints: [NSLayoutConstraint]!

    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var labelsLeftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelsRightMarginConstraint: NSLayoutConstraint!

    private var style: UserProductPriceViewStyle = .Full

    weak var delegate: UserProductPriceViewDelegate?

    
    // MARK: - Lifecycle

    static func userProductPriceView(style: UserProductPriceViewStyle) -> UserProductPriceView? {
        guard let view = NSBundle.mainBundle().loadNibNamed("UserProductPriceView", owner: self,
            options: nil).first as? UserProductPriceView else { return nil }
        view.style = style
        view.setup()
        return view
    }

    override func intrinsicContentSize() -> CGSize {
        let height = userAvatarImageView.intrinsicContentSize().height

        let avatarMargin = avatarMarginConstraints.first?.constant ?? 0
        let avatarSide = height - avatarMargin * 2
        let labelsMargin = labelsLeftMarginConstraint.constant + labelsRightMarginConstraint.constant

        let productPriceLabelDesiredWidth = productPriceLabel.intrinsicContentSize().width
        let userNameLabelDesiredWidth = userNameLabel.intrinsicContentSize().width
        let width = avatarMargin + avatarSide + labelsMargin +
            max(productPriceLabelDesiredWidth, userNameLabelDesiredWidth)

        return CGSize(width: width, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.height / 2
    }

    
    // MARK: - Public methods

    func setupWith(userAvatar avatar: NSURL?, productPrice: String?, userName: String?) {
        clipsToBounds = false
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 0.24
        layer.shadowRadius = 2.0

        userAvatarImageView.sd_setImageWithURL(avatar, placeholderImage: UIImage(named: "no_photo"))
        productPriceLabel.text = productPrice
        userNameLabel.text = userName
    }


    // MARK: - Private methods

    private func setup() {
        backgroundColor = StyleHelper.userProductViewBgColor(style)
        productPriceLabel.font = StyleHelper.userProductViewPriceLabelFont(style)
        productPriceLabel.textColor = StyleHelper.userProductViewPriceLabelColor(style)
        userNameLabel.font = StyleHelper.userProductViewUsernameLabelFont(style)
        userNameLabel.textColor = StyleHelper.userProductViewUsernameLabelColor(style)
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("avatarPressed"))
        addGestureRecognizer(tapGesture)
    }

    dynamic private func avatarPressed() {
        delegate?.userProductPriceViewAvatarPressed(self)
    }
}