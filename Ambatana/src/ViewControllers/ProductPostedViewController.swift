//
//  ProductPostedViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 14/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

class ProductPostedViewController: BaseViewController {

    weak var delegate: SellProductViewControllerDelegate?

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var mainIconImage: UIImageView!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var secondaryTextLabel: UILabel!
    @IBOutlet weak var shareContainer: UIView!
    @IBOutlet weak var shareContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var shareItLabel: UILabel!
    @IBOutlet weak var orLabel: UILabel!

    // ViewModel
    private var viewModel: ProductPostedViewModel!


    // MARK: - View lifecycle

    convenience init(viewModel: ProductPostedViewModel) {
        self.init(viewModel: viewModel, nibName: "ProductPostedViewController")
    }

    required init(viewModel: ProductPostedViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("ProductPostedViewController:deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - IBActions

    @IBAction func onCloseButton(sender: AnyObject) {
        dismissViewControllerAnimated(true) { [weak self] in
            self?.viewModel.closeActionPressed()
        }
    }

    @IBAction func onMainButton(sender: AnyObject) {
        dismissViewControllerAnimated(true) { [weak self] in
            self?.viewModel.mainActionPressed()
        }
    }


    // MARK: - Private methods

    private func setupView() {

        contentContainer.layer.cornerRadius = 4
        mainButton.layer.cornerRadius = 4

        shareItLabel.text = LGLocalizedString.productPostConfirmationShare
        orLabel.text = LGLocalizedString.productPostConfirmationAnother

        mainTextLabel.text = viewModel.mainText
        secondaryTextLabel.text = viewModel.secondaryText
        mainButton.setTitle(viewModel.mainButtonText, forState: UIControlState.Normal)

        if let shareInfo = viewModel.shareInfo {
            //TODO: IMPLEMENT
        } else {
            shareContainer.hidden = true
            shareContainerHeight.constant = 0
        }
    }
}
