//
//  HelpViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 24/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

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
        
        // Navigation Bar
        setLetGoNavigationBarStyle(LGLocalizedString.helpTitle)
        setLetGoRightButtonWith(imageName: "ic_more_options", selector: "showOptions")

        if let url = viewModel.url {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
    
    // MARK: - Private methods

    dynamic private func showOptions() {
        let alert = UIAlertController(title: nil, message: nil,
            preferredStyle: .ActionSheet)

        alert.addAction(UIAlertAction(title: LGLocalizedString.mainSignUpTermsConditionsTermsPart, style: .Default,
            handler: self.showTerms))
        alert.addAction(UIAlertAction(title: LGLocalizedString.mainSignUpTermsConditionsPrivacyPart, style: .Default,
            handler: self.showPrivacy))
        alert.addAction(UIAlertAction(title: LGLocalizedString.contactTitle, style: .Default,
            handler: self.openContact))
        alert.addAction(UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    private func showTerms(action: UIAlertAction) {
        if let termsUrl = viewModel.termsAndConditionsURL {
            UIApplication.sharedApplication().openURL(termsUrl)
        }
    }

    private func showPrivacy(action: UIAlertAction) {
        if let privacyUrl = viewModel.privacyURL {
            UIApplication.sharedApplication().openURL(privacyUrl)
        }
    }

    private func openContact(action: UIAlertAction) {
        let vc = ContactViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
