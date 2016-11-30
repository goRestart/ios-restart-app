//
//  TestTextViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 30/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class TestTextViewController: TextViewController {

    init(){
        super.init(viewModel: nil, nibName: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let leftBarBtn = UIBarButtonItem(title: "Close", style: .Done, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = leftBarBtn
    }

    dynamic private func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
