//
//  HelpViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 24/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import SafariServices

public class HelpViewController: BaseViewController, UIWebViewDelegate {

    // UI
    @IBOutlet weak var webView: UIWebView!
    
    // ViewModel
    private var viewModel : HelpViewModel!
    
    // MARK: - Lifecycle
    
    public required init(viewModel: HelpViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "HelpViewController")
        
        automaticallyAdjustsScrollViewInsets = false
    }
    
    public convenience init() {
        let viewModel = HelpViewModel()
        self.init(viewModel: viewModel)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        // Navigation Bar
        setNavBarTitle(LGLocalizedString.helpTitle)
        setLetGoRightButtonWith(imageName: "ic_more_options", selector: "showOptions")

        if let url = viewModel.url {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }

        setupAccessibilityIds()
    }
    
    
    // MARK: - Private methods

    private func setupAccessibilityIds() {
        webView.accessibilityId = .HelpWebView
    }

    dynamic private func showOptions() {
        let alert = UIAlertController(title: nil, message: nil,
            preferredStyle: .ActionSheet)
        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        alert.addAction(UIAlertAction(title: LGLocalizedString.mainSignUpTermsConditionsTermsPart, style: .Default,
            handler: { [weak self] action in self?.showTermsPressed() }))
        alert.addAction(UIAlertAction(title: LGLocalizedString.mainSignUpTermsConditionsPrivacyPart, style: .Default,
            handler: { [weak self] action in self?.showPrivacyPressed() }))
        alert.addAction(UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    private func showTermsPressed() {
        viewModel.termsButtonPressed()
    }

    private func showPrivacyPressed() {
        viewModel.privacyButtonPressed()
    }
}

extension HelpViewController: HelpViewModelDelegate {
    func openURL(url: NSURL) {
        openInternalUrl(url)
    }
}

