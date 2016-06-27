//
//  ProcessingVideoDialogViewController.swift
//  LetGo
//
//  Created by Dídac on 04/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol ProcessingVideoDialogDismissDelegate: class {
    func processingVideoDidDismissOk()
    func processingVideoDidDismissTryAgain()
}

public class ProcessingVideoDialogViewController: BaseViewController {

    // Success
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var processingLabel: UILabel!
    @IBOutlet weak var videoWillAppearLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var loadingIndicator: LoadingIndicator!
    var stopLoadingIndicatorTimer: NSTimer? // used just to stop the fake loading indicator animation

    // Error
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var loadingFailedImageView: UIImageView!

    var viewModel: ProcessingVideoDialogViewModel
    weak var delegate: PromoteProductViewControllerDelegate?
    weak var dismissDelegate: ProcessingVideoDialogDismissDelegate?


    // MARK: - Lifecycle

    convenience init(viewModel: ProcessingVideoDialogViewModel) {
        self.init(viewModel: viewModel, nibName: "ProcessingVideoDialogViewController")
    }

    init(viewModel: ProcessingVideoDialogViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        switch viewModel.videoProcessStatus {
        case .ProcessOK:
            setupSuccessView()
        case .ProcessFail:
            setupErrorView()
        }
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        switch viewModel.videoProcessStatus {
        case .ProcessOK:
            loadingIndicator.startAnimating()
            stopLoadingIndicatorTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self,
                selector: #selector(ProcessingVideoDialogViewController.stopIndicator), userInfo: nil, repeats: false)
        case .ProcessFail:
            break
        }
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

    @IBAction func onTryAgainButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true) { [weak self] _ in
            self?.dismissDelegate?.processingVideoDidDismissTryAgain()
        }
    }


    // MARK: - private methods

    private func setupSuccessView() {
        okButton.setPrimaryStyle()
        okButton.setTitle(LGLocalizedString.commonOk, forState: .Normal)

        loadingIndicator.color = UIColor.primaryColor

        processingLabel.text = LGLocalizedString.commercializerProcessingTitleLabel
        videoWillAppearLabel.text = LGLocalizedString.commercializerProcessingWillAppearLabel
        successView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        errorView.hidden = true
    }

    private func setupErrorView() {
        tryAgainButton.setPrimaryStyle()
        tryAgainButton.setTitle(LGLocalizedString.commonErrorRetryButton, forState: .Normal)

        errorTitleLabel.text = LGLocalizedString.commonErrorTitle.capitalizedString
        errorMessageLabel.text = LGLocalizedString.commercializerProcessVideoFailedErrorMessage
        errorView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        successView.hidden = true
    }

    private func closeView() {
        dismissViewControllerAnimated(true) { [weak self] _ in
            guard let strongSelf = self else { return }
            switch strongSelf.viewModel.videoProcessStatus {
            case .ProcessOK:
                strongSelf.dismissDelegate?.processingVideoDidDismissOk()
                let source = strongSelf.viewModel.promotionSource
                strongSelf.delegate?.promoteProductViewControllerDidFinishFromSource(source)
            case .ProcessFail:
                break
            }
        }
    }
}
