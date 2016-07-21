//
//  UserViewHeaderContainer.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

/**
User View Header Container to forward hits to UserViewHeader subviews located out of its boundaries into it.
*/
class UserViewHeaderContainer: UIView {
    let header: UserViewHeader? = UserViewHeader.userViewHeader()
    weak var headerDelegate: UserViewHeaderDelegate? {
        get {
            return header?.delegate
        }
        set {
            header?.delegate = newValue
        }
    }


    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
        setupConstraints()
    }
}


// MARK: - Overrides

extension UserViewHeaderContainer {
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        // As header's avatarButton & reviewButton are out of view boundaries we intercept touches to be handled manually
        let superResult = super.hitTest(point, withEvent: event)
        guard let header = header where superResult == nil else { return superResult }

        let avatarButtonConvertedPoint = header.avatarButton.convertPoint(point, fromView: self)
        let insideAvatarButton = header.avatarButton.pointInside(avatarButtonConvertedPoint, withEvent: event)
        let ratingsButtonConvertedPoint = header.ratingsButton.convertPoint(point, fromView: self)
        let insideRatingsButton = header.ratingsButton.pointInside(ratingsButtonConvertedPoint, withEvent: event)

        if insideAvatarButton {
            return header.avatarButton
        } else if insideRatingsButton {
            return header.ratingsButton
        } else {
            return nil
        }
    }
}

private extension UserViewHeaderContainer {
    func setupUI() {
        backgroundColor = UIColor.clearColor()

        guard let header = header else { return }
        header.translatesAutoresizingMaskIntoConstraints = false
        addSubview(header)
    }

    func setupConstraints() {
        let views: [String: AnyObject] = ["header": header!]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[header]-0-|",
                                                                          options: [],
                                                                          metrics: nil, views: views)
        addConstraints(hConstraints)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[header]-0-|",
                                                                          options: [],
                                                                          metrics: nil, views: views)
        addConstraints(vConstraints)
    }
}
