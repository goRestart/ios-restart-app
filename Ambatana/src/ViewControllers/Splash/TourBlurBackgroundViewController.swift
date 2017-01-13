//
//  TourBlurBackgroundViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 23/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class TourBlurBackgroundViewController: BaseViewController {

    init() {
        super.init(viewModel: nil, nibName: "TourBlurBackgroundViewController",
                   statusBarStyle: .lightContent)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
