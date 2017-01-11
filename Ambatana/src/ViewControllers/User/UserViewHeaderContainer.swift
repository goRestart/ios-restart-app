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
    let header: UserViewHeader = UserViewHeader.userViewHeader()
    weak var headerDelegate: UserViewHeaderDelegate? {
        get {
            return header.delegate
        }
        set {
            header.delegate = newValue
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
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // As header's avatarButton & reviewButton are out of view boundaries we intercept touches to be handled manually
        let superResult = super.hitTest(point, with: event)
        guard superResult == nil else { return superResult }

        let avatarButtonConvertedPoint = header.avatarButton.convert(point, from: self)
        let insideAvatarButton = header.avatarButton.point(inside: avatarButtonConvertedPoint, with: event)
        let ratingsButtonConvertedPoint = header.ratingsButton.convert(point, from: self)
        let insideRatingsButton = header.ratingsButton.point(inside: ratingsButtonConvertedPoint, with: event)

        if insideAvatarButton {
            return header.avatarButton
        } else if insideRatingsButton {
            return header.ratingsButton
        } else {
            return nil
        }
    }
}

fileprivate extension UserViewHeaderContainer {
    func setupUI() {
        backgroundColor = UIColor.clear

        header.translatesAutoresizingMaskIntoConstraints = false
        addSubview(header)
    }

    func setupConstraints() {
        let views: [String: AnyObject] = ["header": header]
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[header]-0-|",
                                                                          options: [],
                                                                          metrics: nil, views: views)
        addConstraints(hConstraints)
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[header]-0-|",
                                                                          options: [],
                                                                          metrics: nil, views: views)
        addConstraints(vConstraints)
    }
}
