//
//  SubjectCell.swift
//  LetGo
//
//  Created by Dídac on 17/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class SubjectCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        // Configure the view for the selected state
        if selected {
            checkImage.image = UIImage(named: "subject_check")
        } else {
            checkImage.image = UIImage()
        }
    }
    
}
