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
        mainButton.setStyle(.primary(fontSize: .big))
        mainButton.setTitle(viewModel.buttonTitle, for: .normal)
        mainButton.accessibilityId = .postDeleteFullscreenButton

        mainTextLabel.text = viewModel.title
        secondaryTextLabel.text = viewModel.subTitle

        iconView.image = viewModel.icon

        guard let postIncentivatorView = PostIncentivatorView.postIncentivatorView(false) else { return }
        incentiveContainer.addSubview(postIncentivatorView)
        let views: [String : Any] = ["postIncentivatorView": postIncentivatorView]
        incentiveContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[postIncentivatorView]|",
            options: [], metrics: nil, views: views))
        incentiveContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[postIncentivatorView]|",
            options: [], metrics: nil, views: views))
        postIncentivatorView.delegate = self
        postIncentivatorView.accessibilityId = .postDeleteFullscreenIncentiveView
        postIncentivatorView.setupIncentiviseView()
    }

    fileprivate func closeWithFadeOutWithCompletion(_ completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }

    @IBAction func onCloseButtonTapped(_ sender: AnyObject) {
        closeWithFadeOutWithCompletion(nil)
    }

    @IBAction func onMainButtonTapped(_ sender: AnyObject) {
        closeWithFadeOutWithCompletion(viewModel.mainButtonAction)
    }
}

// MARK: - Incentivise methods

extension PostAfterDeleteViewController: PostIncentivatorViewDelegate {
    func incentivatorTapped() {
        closeWithFadeOutWithCompletion(viewModel.mainButtonAction)
    }
}
