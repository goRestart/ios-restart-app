//
//  UserViewHeader.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift
import SDWebImage
import UIKit

protocol UserViewHeaderDelegate: class {
    func headerAvatarAction()
}

enum UserViewHeaderMode {
    case MyUser, OtherUser
}

enum UserViewHeaderTab: Int {
    case Selling, Sold, Favorites
}

class UserViewHeader: UIView {

    private static let bgViewMaxHeight: CGFloat = 165
    private static let avatarHeight: CGFloat = 80

    private static let otherAccountHeight: CGFloat = 16

    @IBOutlet weak var avatarImageView: UIImageView!
    var avatarBorderLayer: CAShapeLayer?
    @IBOutlet weak var buttonsContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarButton: UIButton!

    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var userRelationLabel: UILabel!

    @IBOutlet weak var verifiedOtherUserView: UIView!
    @IBOutlet weak var verifiedOtherUserTitle: UILabel!
    @IBOutlet weak var otherFacebookButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var otherGoogleButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var otherEmailButtonHeight: NSLayoutConstraint!

    @IBOutlet weak var verifiedMyUserView: UIView!
    @IBOutlet weak var verifiedMyUserTitle: UILabel!
    @IBOutlet weak var myUserFacebookButton: UIButton!
    @IBOutlet weak var myUserGoogleButton: UIButton!
    @IBOutlet weak var myUserEmailButton: UIButton!

    var verifiedView: UIView {
        switch mode {
        case .MyUser:
            return verifiedMyUserView
        case .OtherUser:
            return verifiedOtherUserView
        }
    }

    @IBOutlet weak var sellingButton: UIButton!
    @IBOutlet weak var sellingButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var soldButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!

    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorViewLeadingConstraint: NSLayoutConstraint!

    weak var delegate: UserViewHeaderDelegate?

    let tab = Variable<UserViewHeaderTab>(.Selling)

    var mode: UserViewHeaderMode = .MyUser {
        didSet {
            switch mode {
            case .MyUser:
                infoContainerView.hidden = true
                verifiedOtherUserView.hidden = true
                verifiedMyUserView.hidden = false

                sellingButtonWidthConstraint.constant = 0
            case .OtherUser:
                infoContainerView.hidden = false
                verifiedOtherUserView.hidden = false
                verifiedMyUserView.hidden = true

                let currentWidth = sellingButtonWidthConstraint.multiplier * frame.width
                let halfWidth = 0.5 * frame.width
                sellingButtonWidthConstraint.constant = halfWidth - currentWidth
            }
        }
    }

    var selectedColor: UIColor = UIColor.redColor() {
        didSet {
            indicatorView.backgroundColor = selectedColor
            setupButtonsSelectedState()
        }
    }

    var collapsed: Bool = false {
        didSet {
            let isCollapsed = avatarImageView.alpha == 0
            guard isCollapsed != collapsed else { return }

            UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseIn, .BeginFromCurrentState],
                                       animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.avatarImageView.alpha = strongSelf.collapsed ? 0 : 1
                strongSelf.infoContainerView.alpha = strongSelf.collapsed ? 0 : 1
                strongSelf.layoutIfNeeded()
            }, completion: nil)

            let transformAnim = CABasicAnimation(keyPath: "transform")
            transformAnim.duration = 0.2
            transformAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            transformAnim.removedOnCompletion = false
            transformAnim.fillMode = kCAFillModeForwards

            let transform = collapsed ? CATransform3DMakeScale(0.01, 0.01, 1) : CATransform3DIdentity
            transformAnim.toValue = NSValue(CATransform3D: transform)
            avatarImageView.layer.addAnimation(transformAnim, forKey: "transform")
            avatarButton.enabled = !collapsed
        }
    }

    let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    static func userViewHeader() -> UserViewHeader? {
        guard let view = NSBundle.mainBundle().loadNibNamed("UserViewHeader", owner: self,
            options: nil).first as? UserViewHeader else { return nil }
        view.setupUI()
        view.setupRxBindings()
        return view
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        switch mode {
        case .MyUser:
            sellingButtonWidthConstraint.constant = 0
        case .OtherUser:
            let currentWidth = sellingButtonWidthConstraint.multiplier * frame.width
            let halfWidth = 0.5 * frame.width
            sellingButtonWidthConstraint.constant = halfWidth - currentWidth
        }

        updateUI()
    }
}


// MARK: - Public methods

extension UserViewHeader {
    func setAvatar(url: NSURL?, placeholderImage: UIImage?) {
        avatarImageView.sd_setImageWithURL(url, placeholderImage: placeholderImage)
    }

    func setUserRelationText(userRelationText: String?) {
        userRelationLabel.text = userRelationText
        updateInfoAndAccountsVisibility()
    }

    func setAccounts(facebookLinked: Bool, facebookVerified: Bool,
                     googleLinked: Bool, googleVerified: Bool,
                     emailLinked: Bool, emailVerified: Bool) {
        setFacebookAccount(facebookLinked, isVerified: facebookVerified)
        setGoogleAccount(googleLinked, isVerified: googleVerified)
        setEmailAccount(emailLinked, isVerified: emailVerified)

        let anyAccountVerified = facebookVerified || googleVerified || emailVerified
        verifiedOtherUserTitle.text = anyAccountVerified ? "VERIFIED" : "NO VERIFIED"
        updateInfoAndAccountsVisibility()
    }

    private func updateInfoAndAccountsVisibility() {
        var infoViewHidden = true
        var verifiedViewHidden = false
        if let userRelationText = userRelationLabel.text {
            infoViewHidden = userRelationText.isEmpty
            verifiedViewHidden = !userRelationText.isEmpty
        }
        infoContainerView.hidden = infoViewHidden
        verifiedView.hidden = verifiedViewHidden
    }

    private func setFacebookAccount(isLinked: Bool, isVerified: Bool) {
        switch mode {
        case .MyUser:
            myUserFacebookButton.enabled = !isLinked || !isVerified
            myUserFacebookButton.highlighted = isLinked && isVerified
        case .OtherUser:
            otherFacebookButtonHeight.constant = isLinked && isVerified ? UserViewHeader.otherAccountHeight : 0
        }
    }

    private func setGoogleAccount(isLinked: Bool, isVerified: Bool) {
        switch mode {
        case .MyUser:
            myUserGoogleButton.enabled = !isLinked || !isVerified
            myUserGoogleButton.highlighted = isLinked && isVerified
        case .OtherUser:
            otherGoogleButtonHeight.constant = isLinked && isVerified ? UserViewHeader.otherAccountHeight : 0
        }
    }

    private func setEmailAccount(isLinked: Bool, isVerified: Bool) {
        switch mode {
        case .MyUser:
            myUserEmailButton.enabled = !isLinked || !isVerified
            myUserEmailButton.highlighted = isLinked && isVerified
        case .OtherUser:
            otherEmailButtonHeight.constant = isLinked && isVerified ? UserViewHeader.otherAccountHeight : 0
        }
    }

    func setCollapsePercentage(percentage: CGFloat) {
        let maxH = UserViewHeader.bgViewMaxHeight
        let minH = sellingButton.frame.height

        let height = maxH - (maxH - minH) * percentage
        buttonsContainerViewHeightConstraint.constant = min(maxH, height)
    }
}


// MARK: - Private methods
// MARK: > UI

extension UserViewHeader {
    private func setupUI() {
        setupInfoView()
        setupButtons()
    }

    private func updateUI() {
        updateUserAvatarView()
    }

    private func setupInfoView() {
        userRelationLabel.font = StyleHelper.userRelationLabelFont
        userRelationLabel.textColor = StyleHelper.userRelationLabelColor
    }

    private func setupButtons() {
        var attributes = [String : AnyObject]()
        attributes[NSForegroundColorAttributeName] = StyleHelper.userTabNonSelectedColor
        attributes[NSFontAttributeName] = StyleHelper.userTabNonSelectedFont

        let sellingTitle = NSAttributedString(string: LGLocalizedString.profileSellingProductsTab.uppercase,
            attributes: attributes)
        sellingButton.setAttributedTitle(sellingTitle, forState: .Normal)


        let soldTitle = NSAttributedString(string: LGLocalizedString.profileSoldProductsTab.uppercase,
            attributes: attributes)
        soldButton.setAttributedTitle(soldTitle, forState: .Normal)

        let favsTitle = NSAttributedString(string: LGLocalizedString.profileFavouritesProductsTab.uppercase,
            attributes: attributes)
        favoritesButton.setAttributedTitle(favsTitle, forState: .Normal)

        setupButtonsSelectedState()
    }

    private func updateUserAvatarView() {
        let width = min(avatarImageView.bounds.width, avatarImageView.bounds.height)
        let path = UIBezierPath(arcCenter: CGPointMake(avatarImageView.bounds.midX, avatarImageView.bounds.midY),
                                radius: width / 2, startAngle: CGFloat(0.0), endAngle: CGFloat(M_PI * 2.0),
                                clockwise: true)
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        avatarImageView.layer.mask = mask

        let borderLayer = CAShapeLayer()
        borderLayer.path = path.CGPath
        borderLayer.lineWidth = 2 * UIScreen.mainScreen().scale
        borderLayer.strokeColor = UIColor.whiteColor().CGColor
        borderLayer.fillColor = nil

        avatarBorderLayer?.removeFromSuperlayer()
        avatarImageView.layer.addSublayer(borderLayer)
        avatarBorderLayer = borderLayer
    }

    private func setupButtonsSelectedState() {
        var attributes = [String : AnyObject]()
        attributes[NSForegroundColorAttributeName] = selectedColor
        attributes[NSFontAttributeName] = StyleHelper.userTabSelectedFont

        let sellingTitle = NSAttributedString(string: LGLocalizedString.profileSellingProductsTab.uppercase,
            attributes: attributes)
        sellingButton.setAttributedTitle(sellingTitle, forState: .Selected)


        let soldTitle = NSAttributedString(string: LGLocalizedString.profileSoldProductsTab.uppercase,
            attributes: attributes)
        soldButton.setAttributedTitle(soldTitle, forState: .Selected)

        let favsTitle = NSAttributedString(string: LGLocalizedString.profileFavouritesProductsTab.uppercase,
            attributes: attributes)
        favoritesButton.setAttributedTitle(favsTitle, forState: .Selected)
    }

    private func setIndicatorAtTab(tab: UserViewHeaderTab, animated: Bool) {
        let leading = CGFloat(tab.rawValue) * sellingButton.frame.width
        indicatorViewLeadingConstraint.constant = leading
        if animated {
            UIView.animateWithDuration(0.15) { [weak self] in
                self?.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }
}


// MARK: > Rx

extension UserViewHeader {
    private func setupRxBindings() {
        setupAvatarButtonRxBinding()
        setupButtonsRxBindings()
    }

    private func setupAvatarButtonRxBinding() {
        avatarButton.rx_tap.subscribeNext { [weak self] _ in
            self?.delegate?.headerAvatarAction()
            }.addDisposableTo(disposeBag)
    }

    private func setupButtonsRxBindings() {
        sellingButton.rx_tap.subscribeNext { [weak self] _ in
            self?.tab.value = .Selling
        }.addDisposableTo(disposeBag)

        soldButton.rx_tap.subscribeNext { [weak self] _ in
            self?.tab.value = .Sold
        }.addDisposableTo(disposeBag)

        favoritesButton.rx_tap.subscribeNext { [weak self] _ in
            self?.tab.value = .Favorites
        }.addDisposableTo(disposeBag)

        tab.asObservable().map { $0 == .Selling }.bindTo(sellingButton.rx_selected).addDisposableTo(disposeBag)
        tab.asObservable().map { $0 == .Sold }.bindTo(soldButton.rx_selected).addDisposableTo(disposeBag)
        tab.asObservable().map { $0 == .Favorites }.bindTo(favoritesButton.rx_selected).addDisposableTo(disposeBag)

        tab.asObservable().skip(1).subscribeNext { [weak self] tab in
            self?.setIndicatorAtTab(tab, animated: true)
        }.addDisposableTo(disposeBag)
    }
}
