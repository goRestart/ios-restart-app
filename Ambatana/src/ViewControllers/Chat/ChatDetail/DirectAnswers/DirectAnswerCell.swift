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
    @IBOutlet weak var arrowWhiteImageView: UIImageView?
    
    static let cellHeight: CGFloat = 32
    static let arrowWidth: CGFloat = 8
    static let arrowHorizontalMargin: CGFloat = 8

    static func sizeForDirectAnswer(_ answer: QuickAnswer, isDynamic: Bool) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: DirectAnswerCell.cellHeight)
        guard let text = isDynamic ? answer.title : answer.text else { return CGSize.zero }
        let boundingBox = text.boundingRect(with: constraintRect,
            options: NSStringDrawingOptions.usesFontLeading,
            attributes: [NSFontAttributeName: UIFont.mediumBodyFont], context: nil)
    
        var width = boundingBox.width+20
        if isDynamic {
            width += DirectAnswerCell.arrowWidth + DirectAnswerCell.arrowHorizontalMargin
        }
        let height = DirectAnswerCell.cellHeight
        
        return CGSize(width: width, height: height)
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

    func setupWithDirectAnswer(_ answer: QuickAnswer, isDynamic: Bool) {
        if isDynamic {
            cellText.text = answer.title
        } else {
            cellText.text = answer.text
            arrowWhiteImageView?.removeFromSuperview()
        }
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
