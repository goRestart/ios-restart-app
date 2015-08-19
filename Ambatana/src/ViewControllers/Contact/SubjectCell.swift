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

    override func setSelected(selected: Bool, animated: Bool) {
        // Configure the view for the selected state
        if selected {
            checkImage.image = UIImage(named: "subject_check")
        } else {
            checkImage.image = nil
        }
    }
    
    // MARK: - Private methods
    
    /**
        Sets up the UI 
    */
    private func setupUI() {
    }

    /**
        Resets the UI to the initial state
    */
    private func resetUI() {
        checkImage.image = nil
    }
}
