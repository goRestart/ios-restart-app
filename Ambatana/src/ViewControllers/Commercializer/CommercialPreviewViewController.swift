//
//  CommercialPreviewViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 04/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class CommercialPreviewViewController: BaseViewController {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var commercialImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var socialShareView: SocialShareView!

    private let viewModel: CommercialPreviewViewModel


    // MARK: - View lifecycle

    init(viewModel: CommercialPreviewViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "CommercialPreviewViewController")
        self.viewModel.delegate = self
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }


    // MARK: - Actions

    @IBAction func closeButtonPressed(sender: AnyObject) {
        viewModel.closeButtonPressed()
    }
    
    @IBAction func playButtonPressed(sender: AnyObject) {
        viewModel.playButtonPressed()
    }


    // MARK: - Private methods

    private func setupUI() {
        contentContainer.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        
        socialShareView.socialMessage = viewModel.socialShareMessage
        socialShareView.delegate = self
        socialShareView.style = .Grid

        titleLabel.text = LGLocalizedString.commercializerPreviewTitle
        subtitleLabel.text = LGLocalizedString.commercializerPreviewSubtitle

        if let imageString = viewModel.thumbURL, let imageUrl = NSURL(string: imageString) {
            commercialImage.lg_setImageWithURL(imageUrl)
        }
    }
}


// MARK: - CommercialPreviewViewModelDelegate

extension CommercialPreviewViewController: CommercialPreviewViewModelDelegate {
    func vmDismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func vmShowCommercial(viewModel viewModel: CommercialDisplayViewModel) {
        let vController = CommercialDisplayViewController(viewModel: viewModel)
        vController.preDismissAction = { [weak self] in
            self?.view.hidden = true
        }
        vController.postDismissAction = { [weak self] in
            self?.dismissViewControllerAnimated(false, completion: nil)
        }
        presentViewController(vController, animated: true, completion: nil)
    }
}


// MARK: - SocialShareViewDelegate

extension CommercialPreviewViewController: SocialShareViewDelegate {
    func viewController() -> UIViewController? {
        return self
    }
}
