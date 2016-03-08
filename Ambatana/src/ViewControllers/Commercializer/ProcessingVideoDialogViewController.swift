//
//  ProcessingVideoDialogViewController.swift
//  LetGo
//
//  Created by Dídac on 04/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol ProcessingVideoDialogDismissDelegate: class {
    func processingVideoDidDismiss()
}

public class ProcessingVideoDialogViewController: BaseViewController {

    @IBOutlet weak var loadingIndicator: LoadingIndicator!
    @IBOutlet weak var processingLabel: UILabel!
    @IBOutlet weak var videoWillAppearLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var createMoreVideosLabel: UILabel!

    var stopLoadingIndicatorTimer: NSTimer?

    var viewModel: ProcessingVideoDialogViewModel?
    weak var delegate: PromoteProductViewControllerDelegate?
    weak var dismissDelegate: ProcessingVideoDialogDismissDelegate?


    // MARK: - Lifecycle

    convenience init(viewModel: ProcessingVideoDialogViewModel?) {
        self.init(viewModel: viewModel, nibName: "ProcessingVideoDialogViewController")
    }

    init(viewModel: ProcessingVideoDialogViewModel?, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setStatusBarHidden(true)

        okButton.setPrimaryStyle()
        okButton.setTitle(LGLocalizedString.commonOk, forState: .Normal)

        loadingIndicator.color = StyleHelper.primaryColor

        processingLabel.text = LGLocalizedString.commercializerProcessingTitleLabel
        videoWillAppearLabel.text = LGLocalizedString.commercializerProcessingWillAppearLabel
        createMoreVideosLabel.text = LGLocalizedString.commercializerProcessingCreateMoreLabel
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        loadingIndicator.startAnimating()
        stopLoadingIndicatorTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "stopIndicator",
            userInfo: nil, repeats: false)
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        setStatusBarHidden(false)
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
        dismissViewControllerAnimated(true) { [weak self] _ in
            self?.dismissDelegate?.processingVideoDidDismiss()
            guard let source = self?.viewModel?.promotionSource else { return }
            self?.delegate?.promoteProductViewControllerDidFinishFromSource(source)
        }
    }
}
