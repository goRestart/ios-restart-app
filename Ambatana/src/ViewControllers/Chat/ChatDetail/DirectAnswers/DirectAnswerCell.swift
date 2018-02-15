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
    
    fileprivate var isDynamic = false

    static func sizeForDirectAnswer(_ quickAnswer: QuickAnswer?, isDynamic: Bool) -> CGSize {
        guard let answer = quickAnswer else { return CGSize.zero }
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: DirectAnswerCell.cellHeight)
        guard let text = isDynamic ? answer.title : answer.text else { return CGSize.zero }
        let boundingBox = text.boundingRect(with: constraintRect,
            options: NSStringDrawingOptions.usesFontLeading,
            attributes: [NSAttributedStringKey.font: UIFont.mediumBodyFont], context: nil)
    
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

    func setupWithDirectAnswer(_ quickAnswer: QuickAnswer?, isDynamic: Bool) {
        guard let answer = quickAnswer else { return }
        self.isDynamic = isDynamic
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
        guard !isDynamic else { return } // Preventing UI bug: after moving item index in the collection, another cell gets highlighted
        let highlighedState = self.isHighlighted || self.isSelected
        contentView.layer.backgroundColor = highlighedState ? UIColor.primaryColorHighlighted.cgColor :
            UIColor.primaryColor.cgColor
    }
}
