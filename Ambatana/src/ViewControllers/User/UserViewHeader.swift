//
//  UserViewHeader.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

protocol UserViewHeaderDelegate: class {
    func headerAvatarAction()
    func ratingsAvatarAction()
    func facebookAccountAction()
    func googleAccountAction()
    func emailAccountAction()
}

enum UserViewHeaderMode {
    case MyUser, OtherUser
}

enum UserViewHeaderTab: Int {
    case Selling, Sold, Favorites
}

class UserViewHeader: UIView {
    private static let bgViewMaxHeight: CGFloat = 165

    private static let otherAccountWidth: CGFloat = 22
    private static let otherAccountHeight: CGFloat = 28
    private static let otherAccountEmptyHeight: CGFloat = 20

    private static let ratingCountContainerLeadingVisible: CGFloat = 15
    private static let ratingCountContainerTrailingVisible: CGFloat = 20

    @IBOutlet weak var avatarRatingsContainerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    var avatarBorderLayer: CAShapeLayer?
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var avatarRatingsEffectView: UIVisualEffectView!
    @IBOutlet weak var ratingCountContainerLeading: NSLayoutConstraint!
    @IBOutlet weak var ratingCountContainerTrailing: NSLayoutConstraint!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var ratingsButton: UIButton!

    @IBOutlet weak var infoView: UIView!

    @IBOutlet weak var userRelationView: UIView!
    @IBOutlet weak var userRelationLabel: UILabel!

    @IBOutlet weak var verifiedOtherUserView: UIView!
    @IBOutlet weak var verifiedOtherUserViewHeight: NSLayoutConstraint!
    @IBOutlet weak var verifiedOtherUserTitle: UILabel!

    @IBOutlet weak var otherFacebookButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var otherGoogleButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var otherEmailButtonWidth: NSLayoutConstraint!

    @IBOutlet weak var verifiedMyUserView: UIView!
    @IBOutlet weak var verifiedMyUserTitle: UILabel!
    @IBOutlet weak var myUserFacebookButton: UIButton!
    @IBOutlet weak var myUserGoogleButton: UIButton!
    @IBOutlet weak var myUserEmailButton: UIButton!

    private var verifiedView: UIView {
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
    let userRatingsDisabled = Variable<Bool>(true)

    var mode: UserViewHeaderMode = .MyUser {
        didSet {
            switch mode {
            case .MyUser:
                verifiedOtherUserView.hidden = true
                verifiedMyUserView.hidden = false
                
                sellingButtonWidthConstraint.constant = 0
            case .OtherUser:
                verifiedOtherUserView.hidden = false
                verifiedMyUserView.hidden = true
                let currentWidth = sellingButtonWidthConstraint.multiplier * frame.width
                let halfWidth = 0.5 * frame.width
                sellingButtonWidthConstraint.constant = halfWidth - currentWidth
            }
            updateInfoAndAccountsVisibility()
        }
    }

    var accounts: UserViewHeaderAccounts? {
        didSet {
            updateInfoAndAccountsVisibility()
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
            let isCollapsed = avatarRatingsContainerView.alpha == 0
            guard isCollapsed != collapsed else { return }

            UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseIn, .BeginFromCurrentState],
                                       animations: { [weak self] in
                guard let strongSelf = self else { return }
                let alpha: CGFloat = strongSelf.collapsed ? 0 : 1
                strongSelf.avatarRatingsContainerView.alpha = alpha
                strongSelf.userRelationView.alpha = alpha
                strongSelf.verifiedOtherUserView.alpha = alpha
                strongSelf.verifiedMyUserView.alpha = alpha
            }, completion: nil)

            avatarButton.enabled = !collapsed
            ratingsButton.enabled = !collapsed
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
        if let url = url {
            avatarImageView.lg_setImageWithURL(url, placeholderImage: placeholderImage)
        } else {
            avatarImageView.image = placeholderImage
        }
    }

    func setRatingCount(ratingCount: Int?) {
        let hidden = (ratingCount ?? 0) <= 0
        ratingCountLabel.text = hidden ? nil : String(ratingCount ?? 0)
        ratingsLabel.text = hidden ? nil : LGLocalizedString.profileReviewsCount
        avatarRatingsEffectView.hidden = hidden
        ratingCountContainerLeading.constant = hidden ? 0 : UserViewHeader.ratingCountContainerLeadingVisible
        ratingCountContainerTrailing.constant = hidden ? 0 : UserViewHeader.ratingCountContainerTrailingVisible
    }

    func setUserRelationText(userRelationText: String?) {
        userRelationLabel.text = userRelationText
        updateInfoAndAccountsVisibility()
    }

    private func updateInfoAndAccountsVisibility() {
        let fbL = accounts?.facebookLinked ?? false
        let fbV = accounts?.facebookVerified ?? false
        setFacebookAccount(fbL, isVerified: fbV)
        let gL = accounts?.googleLinked ?? false
        let gV = accounts?.googleVerified ?? false
        setGoogleAccount(gL, isVerified: gV)
        let eL = accounts?.emailLinked ?? false
        let eV = accounts?.emailVerified ?? false
        setEmailAccount(eL, isVerified: eV)

        var infoViewHidden: Bool
        var verifiedViewHidden: Bool
        if let userRelationText = userRelationLabel.text {
            infoViewHidden = userRelationText.isEmpty
            verifiedViewHidden = !userRelationText.isEmpty
        } else if let _ = accounts {
            infoViewHidden = true
            verifiedViewHidden = false
        } else {
            infoViewHidden = true
            verifiedViewHidden = true
        }
        userRelationView.hidden = infoViewHidden
        verifiedView.hidden = verifiedViewHidden

        switch mode {
        case .MyUser:
            break
        case .OtherUser:
            let anyAccountVerified = fbV || gV || eV
            verifiedOtherUserTitle.text = anyAccountVerified ? LGLocalizedString.profileVerifiedAccountsOtherUser : ""
            verifiedOtherUserViewHeight.constant = anyAccountVerified ? UserViewHeader.otherAccountHeight :
                UserViewHeader.otherAccountEmptyHeight
        }
    }

    private func setFacebookAccount(isLinked: Bool, isVerified: Bool) {
        let on = isLinked && isVerified
        switch mode {
        case .MyUser:
            let image = UIImage(named: on ? "ic_user_private_fb_on" : "ic_user_private_fb_off")
            myUserFacebookButton.setImage(image, forState: .Normal)
            myUserFacebookButton.setImage(image, forState: .Disabled)
            myUserFacebookButton.enabled = !on
        case .OtherUser:
            otherFacebookButtonWidth.constant = on ? UserViewHeader.otherAccountWidth : 0
        }
    }

    private func setGoogleAccount(isLinked: Bool, isVerified: Bool) {
        let on = isLinked && isVerified
        switch mode {
        case .MyUser:
            let image = UIImage(named: on ? "ic_user_private_google_on" : "ic_user_private_google_off")
            myUserGoogleButton.setImage(image, forState: .Normal)
            myUserGoogleButton.setImage(image, forState: .Disabled)
            myUserGoogleButton.enabled = !on
        case .OtherUser:
            otherGoogleButtonWidth.constant = on ? UserViewHeader.otherAccountWidth : 0
        }
    }

    private func setEmailAccount(isLinked: Bool, isVerified: Bool) {
        let on = isLinked && isVerified
        switch mode {
        case .MyUser:
            let image = UIImage(named: on ? "ic_user_private_email_on" : "ic_user_private_email_off")
            myUserEmailButton.setImage(image, forState: .Normal)
            myUserEmailButton.setImage(image, forState: .Disabled)
            myUserEmailButton.enabled = !on
        case .OtherUser:
            otherEmailButtonWidth.constant = on ? UserViewHeader.otherAccountWidth : 0
        }
    }
}


// MARK: - Private methods
// MARK: > UI

extension UserViewHeader {
    private func setupUI() {
        setupInfoView()
        setupAvatarRatingsContainerView()
        setupVerifiedViews()
        setupButtons()
    }

    private func updateUI() {
        updateAvatarRatingsContainerView()
        updateUserAvatarView()
    }

    private func setupInfoView() {
        userRelationView.hidden = true
        userRelationLabel.font = UIFont.smallBodyFont
        userRelationLabel.textColor = UIColor.primaryColor
    }

    private func setupAvatarRatingsContainerView() {
        ratingCountLabel.font = UIFont.systemLightFont(size: 24)
        ratingCountLabel.textColor = UIColor.black
        ratingsLabel.font = UIFont.systemRegularFont(size: 13)
        ratingsLabel.textColor = UIColor.grayDark
    }

    private func setupVerifiedViews() {
        verifiedMyUserView.hidden = true
        verifiedMyUserTitle.text = LGLocalizedString.profileVerifiedAccountsMyUser
        verifiedMyUserTitle.textColor = UIColor.grayDark
        verifiedMyUserTitle.font = UIFont.mediumBodyFontLight

        verifiedOtherUserView.hidden = true
        verifiedOtherUserTitle.text = nil
        verifiedOtherUserTitle.textColor = UIColor.grayDark
        verifiedOtherUserTitle.font = UIFont.mediumBodyFontLight
    }

    private func setupButtons() {
        var attributes = [String : AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont.inactiveTabFont

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

    private func updateAvatarRatingsContainerView() {
        let height = avatarRatingsContainerView.bounds.height
        avatarRatingsContainerView.layer.cornerRadius = height / 2
        userRatingsDisabled.value = !FeatureFlags.userRatings
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
        attributes[NSFontAttributeName] = UIFont.activeTabFont

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
        setupButtonsRxBindings()
        setupAccountsRxBindings()
    }

    private func setupButtonsRxBindings() {
        avatarButton.rx_tap.subscribeNext { [weak self] _ in
            self?.delegate?.headerAvatarAction()
        }.addDisposableTo(disposeBag)

        ratingsButton.rx_tap.subscribeNext { [weak self] _ in
            self?.delegate?.ratingsAvatarAction()
        }.addDisposableTo(disposeBag)

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

        userRatingsDisabled.asObservable().bindTo(ratingsButton.rx_hidden).addDisposableTo(disposeBag)
    }

    private func setupAccountsRxBindings() {
        myUserFacebookButton.rx_tap.subscribeNext { [weak self] in
            self?.delegate?.facebookAccountAction()
        }.addDisposableTo(disposeBag)

        myUserGoogleButton.rx_tap.subscribeNext { [weak self] in
            self?.delegate?.googleAccountAction()
        }.addDisposableTo(disposeBag)

        myUserEmailButton.rx_tap.subscribeNext { [weak self] in
            self?.delegate?.emailAccountAction()
        }.addDisposableTo(disposeBag)
    }
}
