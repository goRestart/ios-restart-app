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
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }


    // MARK: - Actions

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeButtonPressed()
    }
    
    @IBAction func playButtonPressed(_ sender: AnyObject) {
        viewModel.playButtonPressed()
    }


    // MARK: - Private methods

    private func setupUI() {
        contentContainer.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        
        socialShareView.socialMessage = viewModel.socialShareMessage
        socialShareView.delegate = self
        socialShareView.style = .grid

        titleLabel.text = LGLocalizedString.commercializerPreviewTitle
        subtitleLabel.text = LGLocalizedString.commercializerPreviewSubtitle

        if let imageString = viewModel.thumbURL, let imageUrl = URL(string: imageString) {
            commercialImage.lg_setImageWithURL(imageUrl)
        }
    }
}


// MARK: - CommercialPreviewViewModelDelegate

extension CommercialPreviewViewController: CommercialPreviewViewModelDelegate {
    func vmDismiss() {
        dismiss(animated: true, completion: nil)
    }

    func vmShowCommercial(viewModel: CommercialDisplayViewModel) {
        let vController = CommercialDisplayViewController(viewModel: viewModel)
        vController.preDismissAction = { [weak self] in
            self?.view.isHidden = true
        }
        vController.postDismissAction = { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }
        present(vController, animated: true, completion: nil)
    }
}


// MARK: - SocialShareViewDelegate

extension CommercialPreviewViewController: SocialShareViewDelegate {
    func viewController() -> UIViewController? {
        return self
    }
}
