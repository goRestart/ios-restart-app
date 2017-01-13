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

class ProcessingVideoDialogViewController: BaseViewController {

    // Success
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var processingLabel: UILabel!
    @IBOutlet weak var videoWillAppearLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var loadingIndicator: LoadingIndicator!
    var stopLoadingIndicatorTimer: Timer? // used just to stop the fake loading indicator animation

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
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch viewModel.videoProcessStatus {
        case .processOK:
            setupSuccessView()
        case .processFail:
            setupErrorView()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch viewModel.videoProcessStatus {
        case .processOK:
            loadingIndicator.startAnimating()
            stopLoadingIndicatorTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                selector: #selector(ProcessingVideoDialogViewController.stopIndicator), userInfo: nil, repeats: false)
        case .processFail:
            break
        }
    }

    func stopIndicator() {
        loadingIndicator.stopAnimating(true)
    }

    @IBAction func onCloseButtonTapped(_ sender: AnyObject) {
        closeView()
    }

    @IBAction func onOKButtonTapped(_ sender: AnyObject) {
        closeView()
    }

    @IBAction func onTryAgainButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true) { [weak self] _ in
            self?.dismissDelegate?.processingVideoDidDismissTryAgain()
        }
    }


    // MARK: - private methods

    private func setupSuccessView() {
        okButton.setStyle(.primary(fontSize: .medium))
        okButton.setTitle(LGLocalizedString.commonOk, for: .normal)

        loadingIndicator.color = UIColor.primaryColor

        processingLabel.text = LGLocalizedString.commercializerProcessingTitleLabel
        videoWillAppearLabel.text = LGLocalizedString.commercializerProcessingWillAppearLabel
        successView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        errorView.isHidden = true
    }

    private func setupErrorView() {
        tryAgainButton.setStyle(.primary(fontSize: .medium))
        tryAgainButton.setTitle(LGLocalizedString.commonErrorRetryButton, for: .normal)

        errorTitleLabel.text = LGLocalizedString.commonErrorTitle.capitalized
        errorMessageLabel.text = LGLocalizedString.commercializerProcessVideoFailedErrorMessage
        errorView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        successView.isHidden = true
    }

    private func closeView() {
        dismiss(animated: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            switch strongSelf.viewModel.videoProcessStatus {
            case .processOK:
                strongSelf.dismissDelegate?.processingVideoDidDismissOk()
                let source = strongSelf.viewModel.promotionSource
                strongSelf.delegate?.promoteProductViewControllerDidFinishFromSource(source)
            case .processFail:
                break
            }
        }
    }
}
