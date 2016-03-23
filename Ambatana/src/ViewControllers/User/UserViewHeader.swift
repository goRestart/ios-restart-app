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


enum UserViewHeaderMode {
    case MyUser, OtherUser
}

enum UserViewHeaderTab: Int {
    case Selling, Sold, Favorites
}

class UserViewHeader: UIView {

    static let height: CGFloat = 130
    private static let bgViewMaxHeight: CGFloat = 90

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var bgViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var sellingButton: UIButton!
    @IBOutlet weak var sellingButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var soldButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!

    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorViewLeadingConstraint: NSLayoutConstraint!

    let tab = Variable<UserViewHeaderTab>(.Selling)

    var mode: UserViewHeaderMode = .MyUser {
        didSet {
            switch mode {
            case .MyUser:
                sellingButtonWidthConstraint.constant = 0
            case .OtherUser:
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
    }
}


// MARK: - Public methods

extension UserViewHeader {
    func setMode(mode: UserViewHeaderMode) {

    }

    func setAvatar(url: NSURL?, placeholderImage: UIImage?) {
        avatarImageView.sd_setImageWithURL(url, placeholderImage: placeholderImage)
    }

    func setCollapsePercentage(percentage: CGFloat) {
        let maxH = UserViewHeader.bgViewMaxHeight
        let minH = sellingButton.frame.height

        let height = maxH - (maxH - minH) * percentage
        bgViewHeightConstraint.constant = min(maxH, height)
    }

    func setAvatarHidden(hidden: Bool) {
        let isHidden = avatarImageView.alpha == 0
        guard isHidden != hidden else { return }

        UIView.animateWithDuration(0.2) { [weak self] in
            self?.avatarImageView.alpha = hidden ? 0 : 1
        }
    }
}


// MARK: - Private methods
// MARK: > UI

extension UserViewHeader {
    private func setupUI() {
        setupUserAvatarView()
        setupButtons()
    }

    private func setupUserAvatarView() {
        avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0
        avatarImageView.clipsToBounds = true
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
        setupButtonsRxBindings()
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
