//
//  HelpViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 24/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import WebKit

class HelpViewController: BaseViewController {
    private let webView = WKWebView()
    private var viewModel: HelpViewModel


    // MARK: - Lifecycle
    
    required init(viewModel: HelpViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        automaticallyAdjustsScrollViewInsets = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.addToViewController(self, inView: self.view)

        // Navigation Bar
        setNavBarTitle(LGLocalizedString.helpTitle)
        setLetGoRightButtonWith(imageName: "ic_more_options", selector: "showOptions")

        if let url = viewModel.url {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        setupAccessibilityIds()
    }
    
    
    // MARK: - Private methods

    private func setupAccessibilityIds() {
        webView.accessibilityId = .helpWebView
    }

    dynamic private func showOptions() {
        let alert = UIAlertController(title: nil, message: nil,
            preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        alert.addAction(UIAlertAction(title: LGLocalizedString.mainSignUpTermsConditionsTermsPart, style: .default,
            handler: { [weak self] action in self?.viewModel.termsButtonPressed() }))
        alert.addAction(UIAlertAction(title: LGLocalizedString.mainSignUpTermsConditionsPrivacyPart, style: .default,
            handler: { [weak self] action in self?.viewModel.privacyButtonPressed() }))
        alert.addAction(UIAlertAction(title: LGLocalizedString.commonCancel, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

