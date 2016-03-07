//
//  ProcessingVideoDialogViewController.swift
//  LetGo
//
//  Created by Dídac on 04/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ProcessingVideoDialogViewController: UIViewController {

    @IBOutlet weak var loadingIndicator: LoadingIndicator!
    @IBOutlet weak var processingLabel: UILabel!
    @IBOutlet weak var videoWillAppearLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var createMoreVideosLabel: UILabel!

    var stopLoadingIndicatorTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setStatusBarHidden(true)

        okButton.setPrimaryStyle()
        okButton.setTitle(LGLocalizedString.commonOk, forState: .Normal)

        loadingIndicator.color = StyleHelper.primaryColor

        // TODO: localize labels

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        loadingIndicator.startAnimating()
        stopLoadingIndicatorTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "stopIndicator", userInfo: nil, repeats: false)
    }

    func stopIndicator() {
        loadingIndicator.stopAnimating(true)
    }

    @IBAction func onCloseButtonTapped(sender: AnyObject) {
        closeView()
    }

    @IBAction func onOKButtonTapped(sender: AnyObject) {
        closeView()
    }

    private func closeView() {
        setStatusBarHidden(false)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
