//
//  ReportUserCell.swift
//  LetGo
//
//  Created by Eli Kohen on 05/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

enum ReportUserType {
    case Offensive, Scammer, Mia, Suspicious, Inactive, ProhibitedItems, Spammer, CounterfeitItems, Others

    var image: UIImage? {
        switch self {
        case .Offensive:
            return UIImage(named: "ic_report_offensive")
        case .Scammer:
            return UIImage(named: "ic_report_scammer")
        case .Mia:
            return UIImage(named: "ic_report_mia")
        case .Suspicious:
            return UIImage(named: "ic_report_suspicious")
        case .Inactive:
            return UIImage(named: "ic_report_inactive")
        case .ProhibitedItems:
            return UIImage(named: "ic_report_prohibited")
        case .Spammer:
            return UIImage(named: "ic_report_spammer")
        case .CounterfeitItems:
            return UIImage(named: "ic_report_counterfeit")
        case .Others:
            return UIImage(named: "ic_report_others")
        }
    }

    var text: String {
        switch self {
        case .Offensive:
            return LGLocalizedString.reportUserOffensive
        case .Scammer:
            return LGLocalizedString.reportUserScammer
        case .Mia:
            return LGLocalizedString.reportUserMia
        case .Suspicious:
            return LGLocalizedString.reportUserSuspcious
        case .Inactive:
            return LGLocalizedString.reportUserInactive
        case .ProhibitedItems:
            return LGLocalizedString.reportUserProhibitedItems
        case .Spammer:
            return LGLocalizedString.reportUserSpammer
        case .CounterfeitItems:
            return LGLocalizedString.reportUserCounterfeit
        case .Others:
            return LGLocalizedString.reportUserOthers
        }
    }

    static func all() -> [ReportUserType] {
        return [.Offensive, .Scammer, .Mia, .Suspicious, .Inactive, .ProhibitedItems, .Spammer, .CounterfeitItems,
            .Others]
    }
}

class ReportUserCell: UICollectionViewCell, ReusableCell {

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


    // MARK: - Public methods

    func setup(type: ReportUserType) {
        reportIcon.image = type.image
        reportText.text = type.text
    }


    // MARK: - Static methods

    static func reusableID() -> String {
        return "ReportUserCell"
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
