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
    
    fileprivate var isDynamic = false

    static func sizeForDirectAnswer(_ quickAnswer: QuickAnswer) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: DirectAnswerCell.cellHeight)
        let boundingBox = quickAnswer.text.boundingRect(with: constraintRect,
                                                        options: NSStringDrawingOptions.usesFontLeading,
                                                        attributes: [NSAttributedStringKey.font: UIFont.mediumBodyFont], context: nil)
        return CGSize(width: boundingBox.width + Metrics.shortMargin*2, height: DirectAnswerCell.cellHeight)
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

    func setupWithDirectAnswer(_ quickAnswer: QuickAnswer) {
        cellText.text = quickAnswer.text
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
        guard !isDynamic else { return } // Preventing UI bug: after moving item index in the collection, another cell gets highlighted
        let highlighedState = self.isHighlighted || self.isSelected
        contentView.layer.backgroundColor = highlighedState ? UIColor.primaryColorHighlighted.cgColor :
            UIColor.primaryColor.cgColor
    }
}
