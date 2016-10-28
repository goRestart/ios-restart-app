//
//  ShareProductViewController.swift
//  LetGo
//
//  Created by Dídac on 26/10/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ShareProductViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var shareButtonsContainer: UIView!
    @IBOutlet weak var shareButtonsContainerWidth: NSLayoutConstraint!
    @IBOutlet var socialShareView: SocialShareView!

    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var linkButtonContainer: UIView!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var copyLabel: UILabel!

    @IBOutlet weak var gradientView: UIView!
    var shadowLayer: CALayer?

    var viewModel: ShareProductViewModel


    // MARK: - Lifecycle

    init(viewModel: ShareProductViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "ShareProductViewController")
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }


    // MARK: - Public Methods

    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func copyButtonPressed(sender: AnyObject) {
//        guard let socialMessage = viewModel.socialMessage else { return }
//        SocialHelper.shareOnCopyLink(socialMessage, viewController: self)
    }


    // MARK: - Private Methods

    private func setupUI() {

        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subTitle
        orLabel.text = "_ OR"

//        linkLabel.text = viewModel.link
        copyLabel.text = "_Copy"

        setupShareView()
        setupGradientView()
        // 👾
        shareButtonsContainerWidth.constant = CGFloat(viewModel.shareTypes.count*60)
    }

    private func setupShareView() {
        socialShareView.setupWithShareTypes(viewModel.shareTypes)
//        socialShareView.socialMessage = viewModel.socialMessage
        socialShareView.delegate = viewModel.shareDelegate
        socialShareView.buttonsSide = 60
        socialShareView.style = .Line
    }

    private func setupGradientView() {
        if let shadowLayer = shadowLayer {
            shadowLayer.removeFromSuperlayer()
        }
        shadowLayer = CAGradientLayer.gradientWithColor(UIColor.grayLighter, alphas:[0, 1], locations: [0, 1])
        if let shadowLayer = shadowLayer {
            shadowLayer.frame = gradientView.bounds
            gradientView.layer.insertSublayer(shadowLayer, atIndex: 0)
        }
    }
}


extension ShareProductViewController: ShareProductViewModelDelegate {

}

