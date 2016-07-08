//
//  DirectAnswerCell.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class DirectAnswerCell: UICollectionViewCell, ReusableCell {

    static let reusableID = "DirectAnswerCell"

    @IBOutlet weak var cellText: UILabel!
    
    private static let cellHeight: CGFloat = 32

    static func sizeForDirectAnswer(answer: DirectAnswer) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.max, height: DirectAnswerCell.cellHeight)
        let boundingBox = answer.text.boundingRectWithSize(constraintRect,
            options: NSStringDrawingOptions.UsesFontLeading,
            attributes: [NSFontAttributeName: UIFont.mediumBodyFont], context: nil)
        return CGSize(width: boundingBox.width+20, height: DirectAnswerCell.cellHeight)
    }

    override var highlighted: Bool {
        didSet {
            refreshBckgState()
        }
    }

    override var selected: Bool {
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

    func setupWithDirectAnswer(answer: DirectAnswer) {
        cellText.text = answer.text
    }


    // MARK: - Private methods

    private func setupUI() {
        contentView.layer.cornerRadius = DirectAnswerCell.cellHeight/2
        contentView.layer.backgroundColor = UIColor.primaryColor.CGColor
        cellText.textColor = UIColor.whiteColor()
    }

    private func resetUI() {
        cellText.text = nil
    }

    private func refreshBckgState() {
        let highlighedState = self.highlighted || self.selected
        contentView.layer.backgroundColor = highlighedState ? UIColor.primaryColorHighlighted.CGColor :
            UIColor.primaryColor.CGColor
    }
}
