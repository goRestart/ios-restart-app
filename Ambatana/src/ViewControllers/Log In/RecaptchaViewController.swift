//
//  RecaptchaViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 19/10/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class RecaptchaViewController: BaseViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIButton!

    private let viewModel: RecaptchaViewModel

    private var currentURL: NSURL?

    init(viewModel: RecaptchaViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "RecaptchaViewController")
        automaticallyAdjustsScrollViewInsets = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setAccesibilityIds()
        webView.delegate = self

        if let url = viewModel.url {
            loadUrl(url)
        }
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        viewModel.closeButtonPressed()
    }


    // MARK: - Private methods

    private func loadUrl(url: NSURL) {
        activityIndicator.startAnimating()
        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)
    }
}


// MARK: - UIWebViewDelegate

extension RecaptchaViewController: UIWebViewDelegate {

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest,
                 navigationType: UIWebViewNavigationType) -> Bool {
        currentURL = request.URL
        if let url = currentURL {
            viewModel.startedLoadingURL(url)
        }
        return true
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()

        if let url = currentURL {
            viewModel.urlLoaded(url)
        }
    }
}


// MARK: - Accesibility ids

extension RecaptchaViewController {
    private func setAccesibilityIds() {
        closeButton.accessibilityId = .RecaptchaCloseButton
        activityIndicator.accessibilityId = .RecaptchaLoading
        webView.accessibilityId = .RecaptchaWebView
    }
}
