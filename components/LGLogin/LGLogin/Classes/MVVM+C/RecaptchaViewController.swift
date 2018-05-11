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

    fileprivate let viewModel: RecaptchaViewModel

    fileprivate var currentURL: URL?

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

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeButtonPressed()
    }


    // MARK: - Private methods

    private func loadUrl(_ url: URL) {
        activityIndicator.startAnimating()
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }
}


// MARK: - UIWebViewDelegate

extension RecaptchaViewController: UIWebViewDelegate {

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest,
                 navigationType: UIWebViewNavigationType) -> Bool {
        currentURL = request.url
        if let url = currentURL {
            viewModel.startedLoadingURL(url)
        }
        return true
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()

        if let url = currentURL {
            viewModel.urlLoaded(url)
        }
    }
}


// MARK: - Accesibility ids

fileprivate extension RecaptchaViewController {
    func setAccesibilityIds() {
        closeButton.set(accessibilityId: AccessibilityId.LGLogin.recaptchaCloseButton)
        activityIndicator.set(accessibilityId: AccessibilityId.LGLogin.recaptchaLoading)
        webView.set(accessibilityId: AccessibilityId.LGLogin.recaptchaWebView)
    }
}
