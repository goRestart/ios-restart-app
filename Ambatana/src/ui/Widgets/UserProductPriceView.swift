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

class UserProductPriceView: BaseView {
    static let height: CGFloat = 50

    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet var avatarMarginConstraints: [NSLayoutConstraint]!

    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var labelsLeftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelsRightMarginConstraint: NSLayoutConstraint!


    weak var delegate: UserProductPriceViewDelegate?

    
    // MARK: - Lifecycle

    static func userProductPriceView() -> UserProductPriceView? {
        guard let view = NSBundle.mainBundle().loadNibNamed("UserProductPriceView", owner: self,
            options: nil).first as? UserProductPriceView else { return nil }
        view.setup()
        return view
    }

    override func intrinsicContentSize() -> CGSize {
        let height = UserProductPriceView.height

        let avatarMargin = avatarMarginConstraints.first?.constant ?? 0
        let avatarSide = height - avatarMargin * 2
        let labelsMargin = labelsLeftMarginConstraint.constant + labelsRightMarginConstraint.constant

        let productPriceLabelDesiredWidth = productPriceLabel.intrinsicContentSize().width
        let userNameLabelDesiredWidth = userNameLabel.intrinsicContentSize().width
        let width = avatarMargin + avatarSide + labelsMargin +
            max(productPriceLabelDesiredWidth, userNameLabelDesiredWidth)

        return CGSize(width: width, height: height)
    }


    // MARK: - Public methods

    func setupWith(userAvatar avatar: NSURL?, productPrice: String?, userName: String?) {
        userAvatarImageView.sd_setImageWithURL(avatar, placeholderImage: UIImage(named: "no_photo"))
        productPriceLabel.text = productPrice
        userNameLabel.text = userName
    }


    // MARK: - Private methods

    private func setup() {
        userAvatarImageView.layer.cornerRadius = CGRectGetWidth(userAvatarImageView.frame) / 2

        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("avatarPressed"))
        addGestureRecognizer(tapGesture)
    }

    dynamic private func avatarPressed() {
        delegate?.userProductPriceViewAvatarPressed(self)
    }
}