//
//  DirectAnswerCell.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import LGComponents

class DirectAnswerCell: UICollectionViewCell, ReusableCell {

    static let reusableID = "DirectAnswerCell"

    @IBOutlet weak var cellIcon: UIImageView!
    @IBOutlet weak var cellText: UILabel!

    @IBOutlet weak var cellIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellIconMarginConstraint: NSLayoutConstraint!

    static let cellHeight: CGFloat = 32
    static let calendarWidth: CGFloat = 15
    static let calendarHorizontalMargin: CGFloat = 5

    fileprivate var quickAnswer: QuickAnswer?

    static func sizeForDirectAnswer(_ quickAnswer: QuickAnswer) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: DirectAnswerCell.cellHeight)
        let boundingBox = quickAnswer.textToShow.boundingRect(with: constraintRect,
                                                              options: NSStringDrawingOptions.usesFontLeading,
                                                              attributes: [NSAttributedStringKey.font: UIFont.mediumBodyFont],
                                                              context: nil)
        var width = boundingBox.width + Metrics.shortMargin*2
        if quickAnswer.isMeetingAssistant {
            width += DirectAnswerCell.calendarWidth + DirectAnswerCell.calendarHorizontalMargin
        }
        return CGSize(width: width, height: DirectAnswerCell.cellHeight)
    }

    override var isHighlighted: Bool {
        didSet {
            refreshBckgState()
        }
    }

    override var isSelected: Bool {
        didSet {
            refreshBckgState()
        }
    }


    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }


    // MARK: - Public methods

    func setupWithDirectAnswer(_ quickAnswer: QuickAnswer, answersEnabled: Bool) {
        cellText.text = quickAnswer.textToShow
        cellText.textColor = quickAnswer.textColor
        cellIcon.tintColor = quickAnswer.iconTintColor
        isUserInteractionEnabled = answersEnabled
        contentView.layer.backgroundColor = answersEnabled ? quickAnswer.bgColor.cgColor : quickAnswer.disabledBgColor.cgColor

        if let icon = quickAnswer.icon {
            cellIcon.isHidden = false
            cellIcon.image = icon
            cellIconWidthConstraint.constant = DirectAnswerCell.calendarWidth
            cellIconMarginConstraint.constant = DirectAnswerCell.calendarHorizontalMargin
        } else {
            cellIcon.isHidden = true
            cellIconWidthConstraint.constant = 0
            cellIconMarginConstraint.constant = 0
        }
    }


    // MARK: - Private methods

    private func setupUI() {
        contentView.setRoundedCorners()
        contentView.layer.backgroundColor = UIColor.primaryColor.cgColor
        cellText.textColor = UIColor.white
    }

    private func resetUI() {
        cellText.text = nil
    }

    private func refreshBckgState() {
        guard let answer = quickAnswer, !answer.isMeetingAssistant else { return }
        let highlighedState = self.isHighlighted || self.isSelected
        contentView.layer.backgroundColor = highlighedState ? answer.disabledBgColor.cgColor : answer.bgColor.cgColor
    }
}
