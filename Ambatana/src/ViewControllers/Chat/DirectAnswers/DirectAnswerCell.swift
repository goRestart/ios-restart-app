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
            attributes: [NSFontAttributeName: StyleHelper.directAnswerFont], context: nil)
        return CGSize(width: boundingBox.width+20, height: DirectAnswerCell.cellHeight)
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

    func setCellHighlighted(highlighted: Bool) {
        contentView.layer.backgroundColor = highlighted ? StyleHelper.directAnswerHighlightedColor.CGColor :
            StyleHelper.directAnswerBackgroundColor.CGColor
    }
    

    // MARK: - Public methods

    func setupWithDirectAnswer(answer: DirectAnswer) {
        cellText.text = answer.text
    }


    // MARK: - Private methods

    private func setupUI() {
        contentView.layer.borderColor = StyleHelper.lineColor.CGColor
        contentView.layer.borderWidth = StyleHelper.onePixelSize
        contentView.layer.cornerRadius = DirectAnswerCell.cellHeight/2
        contentView.layer.backgroundColor = UIColor.whiteColor().CGColor
    }

    private func resetUI() {
        cellText.text = nil
    }
}
