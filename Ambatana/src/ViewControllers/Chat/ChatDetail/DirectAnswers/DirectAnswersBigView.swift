//
//  DirectAnswersBigView.swift
//  LetGo
//
//  Created by Dídac on 03/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class DirectAnswersBigView: UIView {

    private static let titleHeight: CGFloat = 40
    private static let answerHeight: CGFloat = 50

    private var titleLabel: UILabel = UILabel()
    private var firstAnswerLabel: UILabel = UILabel()
    private var secondAnswerLabel: UILabel = UILabel()
    private var thirdAnswerLabel: UILabel = UILabel()
    private var topConstraint: NSLayoutConstraint?

    private var directAnswers: [DirectAnswer] = []

    // MARK: - Lifecycle

    convenience init() {
        self.init(frame: CGRectZero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupData()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Public

    func setupOnTopOfView(sibling: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        guard let parentView = sibling.superview else { return }
        parentView.addSubview(self)
        let top = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy:
            NSLayoutRelation.Equal, toItem: sibling, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal,
                                      toItem: sibling, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal,
                                       toItem: sibling, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        parentView.addConstraints([top,left,right])
        topConstraint = top
    }

    func setDirectAnswers(directAnswers: [DirectAnswer]) {

    }

    // MARK: - Private

    private func setupData() {
        titleLabel.text = LGLocalizedString.directAnswerTitle
        firstAnswerLabel.text = directAnswers[0].text
        firstAnswerLabel.textColor = UIColor.redText
        secondAnswerLabel.text = directAnswers[1].text
        secondAnswerLabel.textColor = UIColor.redText
        thirdAnswerLabel.text = directAnswers[2].text
        thirdAnswerLabel.textColor = UIColor.redText
    }

    private func setupConstraints() {
        addSubview(titleLabel)
        addSubview(firstAnswerLabel)
        addSubview(secondAnswerLabel)
        addSubview(thirdAnswerLabel)

        let titleTop = NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: self,
                                          attribute: .Top, multiplier: 1, constant: 0)
        let titleHeight = NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                             attribute: .NotAnAttribute, multiplier: 1, constant: DirectAnswersBigView.titleHeight)

        let firstLabelTop = NSLayoutConstraint(item: firstAnswerLabel, attribute: .Top, relatedBy: .Equal, toItem: titleLabel,
                                          attribute: .Bottom, multiplier: 1, constant: 0)
        let firstLabelHeight = NSLayoutConstraint(item: firstAnswerLabel, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                             attribute: .NotAnAttribute, multiplier: 1, constant: DirectAnswersBigView.answerHeight)

        let secondLabelTop = NSLayoutConstraint(item: secondAnswerLabel, attribute: .Top, relatedBy: .Equal, toItem: firstAnswerLabel,
                                               attribute: .Bottom, multiplier: 1, constant: 0)
        let secondLabelHeight = NSLayoutConstraint(item: secondAnswerLabel, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                                  attribute: .NotAnAttribute, multiplier: 1, constant: DirectAnswersBigView.answerHeight)

        let thirdLabelTop = NSLayoutConstraint(item: thirdAnswerLabel, attribute: .Top, relatedBy: .Equal, toItem: secondAnswerLabel,
                                                attribute: .Bottom, multiplier: 1, constant: 0)
        let thirdLabelHeight = NSLayoutConstraint(item: thirdAnswerLabel, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                                   attribute: .NotAnAttribute, multiplier: 1, constant: DirectAnswersBigView.answerHeight)
        let thirdLabelBottom = NSLayoutConstraint(item: thirdAnswerLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self,
                                               attribute: .Bottom, multiplier: 1, constant: 0)

        addConstraints([titleTop, titleHeight, firstLabelTop, firstLabelHeight, secondLabelTop, secondLabelHeight,
            thirdLabelTop, thirdLabelHeight, thirdLabelBottom])
    }
}
