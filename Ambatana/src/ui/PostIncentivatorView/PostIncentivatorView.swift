//
//  PostIncentivatorView.swift
//  LetGo
//
//  Created by Dídac on 22/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol PostIncentivatorViewDelegate: class {
    func incentivatorTapped()
}

class PostIncentivatorView: UIView {

    @IBOutlet weak var incentiveLabel: UILabel!
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstCountLabel: UILabel!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var secondNameLabel: UILabel!
    @IBOutlet weak var secondCountLabel: UILabel!
    @IBOutlet weak var thirdImage: UIImageView!
    @IBOutlet weak var thirdNameLabel: UILabel!
    @IBOutlet weak var thirdCountLabel: UILabel!

    weak var delegate: PostIncentivatorViewDelegate?

    var isFree: Bool?

    var incentiveText: NSAttributedString {
        let gotAnyTextAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayText,
                                                          NSFontAttributeName : UIFont.systemBoldFont(size: 15)]
        let lookingForTextAttributes: [String : AnyObject] = [ NSForegroundColorAttributeName : UIColor.darkGrayText,
                                                               NSFontAttributeName : UIFont.mediumBodyFont]

        let secondPartString = (isFree ?? false)  ? LGLocalizedString.productPostIncentiveGotAnyFree :
            LGLocalizedString.productPostIncentiveGotAny
        let plainText = LGLocalizedString.productPostIncentiveLookingFor(secondPartString)
        let resultText = NSMutableAttributedString(string: plainText, attributes: lookingForTextAttributes)
        let boldRange = NSString(string: plainText).rangeOfString(secondPartString, options: .CaseInsensitiveSearch)
        resultText.addAttributes(gotAnyTextAttributes, range: boldRange)

        return resultText
    }

    static func postIncentivatorView(isFree: Bool) -> PostIncentivatorView? {
        guard let view = NSBundle.mainBundle().loadNibNamed("PostIncentivatorView", owner: self, options: nil)?.first
            as? PostIncentivatorView else { return nil }
        view.isFree = isFree
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    func setupIncentiviseView() {        
        let itemPack = PostIncentiviserItem.incentiviserPack(isFree ?? false)

        guard itemPack.count == 3 else {
            self.hidden = true
            return
        }

        let firstItem = itemPack[0]
        let secondItem = itemPack[1]
        let thirdItem = itemPack[2]

        firstImage.image = firstItem.image
        firstNameLabel.text = firstItem.name
        firstNameLabel.textColor = UIColor.blackText
        firstCountLabel.text = firstItem.searchCount
        firstCountLabel.textColor = UIColor.darkGrayText

        secondImage.image = secondItem.image
        secondNameLabel.text = secondItem.name
        secondNameLabel.textColor = UIColor.blackText
        secondCountLabel.text = secondItem.searchCount
        secondCountLabel.textColor = UIColor.darkGrayText

        thirdImage.image = thirdItem.image
        thirdNameLabel.text = thirdItem.name
        thirdNameLabel.textColor = UIColor.blackText
        thirdCountLabel.text = thirdItem.searchCount
        thirdCountLabel.textColor = UIColor.darkGrayText

        incentiveLabel.attributedText = incentiveText

        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.addGestureRecognizer(tap)
    }


    dynamic private func onTap() {
        delegate?.incentivatorTapped()
    }
}
