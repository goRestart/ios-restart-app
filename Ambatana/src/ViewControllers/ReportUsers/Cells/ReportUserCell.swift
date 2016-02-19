//
//  ReportUserCell.swift
//  LetGo
//
//  Created by Eli Kohen on 05/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ReportUserCell: UICollectionViewCell, ReusableCell {

    static let reusableID = "ReportUserCell"

    @IBOutlet weak var reportIcon: UIImageView!
    @IBOutlet weak var reportSelected: UIImageView!
    @IBOutlet weak var reportText: UILabel!


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


    // MARK: - Private methods

    private func setupUI() {
        reportSelected.layer.cornerRadius = reportSelected.width/2
    }

    private func resetUI() {
        reportIcon.image = nil
        reportText.text = nil
    }
}
