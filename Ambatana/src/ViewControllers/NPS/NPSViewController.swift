//
//  NPSViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 26/8/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


class NPSViewController: BaseViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var notLikelyLabel: UILabel!
    @IBOutlet weak var extremelyLikelyLabel: UILabel!
    @IBOutlet weak var notLikelyImage: UIImageView!
    @IBOutlet weak var extremelyLikelyImage: UIImageView!
    @IBOutlet var npsButtons: [UIButton]!
    
    var viewModel: NPSViewModel
    
    init(viewModel: NPSViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "NPSViewController")
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        npsButtons.forEach {
            $0.layer.cornerRadius = $0.height/2
            $0.backgroundColor = UIColor.whiteColor()
            $0.layer.borderColor = UIColor.primaryColor.CGColor
            $0.layer.borderWidth = 1.0
            $0.setTitle(String($0.tag), forState: .Normal)
            $0.setTitleColor(UIColor.primaryColor, forState: .Normal)
        }
    }
}