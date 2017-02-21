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
    
    static let cellHeight: CGFloat = 32

    static func sizeForDirectAnswer(_ answer: QuickAnswer) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: DirectAnswerCell.cellHeight)
        let boundingBox = answer.text.boundingRect(with: constraintRect,
            options: NSStringDrawingOptions.usesFontLeading,
            attributes: [NSFontAttributeName: UIFont.mediumBodyFont], context: nil)
        return CGSize(width: boundingBox.width+20, height: DirectAnswerCell.cellHeight)
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

    func setupWithDirectAnswer(_ answer: QuickAnswer) {
        cellText.text = answer.text
    }


    // MARK: - Private methods

    private func setupUI() {
        contentView.layer.cornerRadius = DirectAnswerCell.cellHeight/2
        contentView.layer.backgroundColor = UIColor.primaryColor.cgColor
        cellText.textColor = UIColor.white
    }

    private func resetUI() {
        cellText.text = nil
    }

    private func refreshBckgState() {
        let highlighedState = self.isHighlighted || self.isSelected
        contentView.layer.backgroundColor = highlighedState ? UIColor.primaryColorHighlighted.cgColor :
            UIColor.primaryColor.cgColor
    }
}
