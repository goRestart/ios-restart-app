//
//  ReportUsersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 05/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ReportUsersViewController: BaseViewController, ReportUsersViewModelDelegate {

    private let viewModel: ReportUsersViewModel


    // MARK: - Lifecycle

    init(viewModel: ReportUsersViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "ReportUsersViewController")
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    


    // MARK: - ReportUsersViewModelDelegate



}
