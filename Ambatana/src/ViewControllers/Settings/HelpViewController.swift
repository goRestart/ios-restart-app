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
        
        // Navigation Bar
        title = NSLocalizedString("help_title", comment: "")
        setLetGoRightButtonsWithImageNames(["ic_contact"], andSelectors: ["openContact"])
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if let url = viewModel.url {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
    }
    
    // MARK: - Private methods
    
    dynamic private func openContact() {
        let vc = ContactViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
