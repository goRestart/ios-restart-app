//
//  CommercialShareViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 06/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class CommercialShareViewController: BaseViewController {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var socialShareView: SocialShareView!

    weak var shareDelegate: SocialShareViewDelegate?
    private let socialSharer = SocialSharer()
    weak var socialSharerDelegate: SocialSharerDelegate? {
        didSet {
            socialSharer.delegate = socialSharerDelegate
        }
    }

    var socialMessage: SocialMessage? {
        didSet {
            guard let socialShareView = socialShareView else { return }
            socialShareView.socialMessage = socialMessage
        }
    }


    // MARK: - View lifecycle

    init() {
        super.init(viewModel: nil, nibName: "CommercialShareViewController")
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

    @IBAction func backgroundButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }


    // MARK: - Private methods

    private func setupUI() {
        contentContainer.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        titleLabel.text = LGLocalizedString.commercializerDisplayShareAlert
        socialShareView.socialMessage = socialMessage
        socialShareView.delegate = self
        socialShareView.style = .grid

        socialSharer.delegate = socialSharerDelegate
        socialShareView.socialSharer = socialSharer
    }
}


// MARK: - SocialShareViewDelegate

extension CommercialShareViewController: SocialShareViewDelegate {
    func viewController() -> UIViewController? {
        return self
    }
}
