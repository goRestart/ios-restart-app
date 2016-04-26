//
//  NotificationsViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 26/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class NotificationsViewController: BaseViewController {


    private let viewModel: NotificationsViewModel

    // MARK: - Lifecycle

    convenience init() {
        self.init(viewModel: NotificationsViewModel())
    }

    convenience init(viewModel: NotificationsViewModel) {
        self.init(viewModel: viewModel, nibName: "NotificationsViewController")
    }

    required init(viewModel: NotificationsViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel.delegate = self

        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - NotificationsViewModelDelegate

extension NotificationsViewController: NotificationsViewModelDelegate {

}
