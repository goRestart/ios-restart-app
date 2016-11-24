//
//  PostAfterDeleteViewController.swift
//  LetGo
//
//  Created by Dídac on 22/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class PostAfterDeleteViewController: BaseViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var secondaryTextLabel: UILabel!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var incentiveContainer: UIView!

    var viewModel: PostAfterDeleteViewModel

    required init(viewModel: PostAfterDeleteViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "PostAfterDeleteViewController")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        setStatusBarHidden(true)
        mainButton.setStyle(.Primary(fontSize: .Big))
        mainButton.setTitle(viewModel.buttonTitle, forState: .Normal)
        mainButton.accessibilityId = .PostDeleteFullscreenButton

        mainTextLabel.text = viewModel.title
        secondaryTextLabel.text = viewModel.subTitle

        iconView.image = viewModel.icon

        guard let postIncentivatorView = PostIncentivatorView.postIncentivatorView(false) else { return }
        incentiveContainer.addSubview(postIncentivatorView)
        let views: [String : AnyObject] = ["postIncentivatorView": postIncentivatorView]
        incentiveContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[postIncentivatorView]|",
            options: [], metrics: nil, views: views))
        incentiveContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[postIncentivatorView]|",
            options: [], metrics: nil, views: views))
        postIncentivatorView.delegate = self
        postIncentivatorView.accessibilityId = .PostDeleteFullscreenIncentiveView
        postIncentivatorView.setupIncentiviseView()
    }

    private func closeWithFadeOutWithCompletion(completion: (() -> Void)?) {
        dismissViewControllerAnimated(true, completion: completion)
    }

    @IBAction func onCloseButtonTapped(sender: AnyObject) {
        closeWithFadeOutWithCompletion(nil)
    }

    @IBAction func onMainButtonTapped(sender: AnyObject) {
        closeWithFadeOutWithCompletion(viewModel.mainButtonAction)
    }
}

// MARK: - Incentivise methods

extension PostAfterDeleteViewController: PostIncentivatorViewDelegate {
    func incentivatorTapped() {
        closeWithFadeOutWithCompletion(viewModel.mainButtonAction)
    }
}
