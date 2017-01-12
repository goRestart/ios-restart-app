//
//  RecaptchaViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 19/10/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class RecaptchaViewController: BaseViewController {
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var bgOverlayView: UIView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIButton!

    fileprivate let viewModel: RecaptchaViewModel
    private let backgroundImage: UIImage?

    fileprivate var currentURL: URL?

    init(viewModel: RecaptchaViewModel, backgroundImage: UIImage?) {
        self.viewModel = viewModel
        self.backgroundImage = backgroundImage
        super.init(viewModel: viewModel, nibName: "RecaptchaViewController")
        automaticallyAdjustsScrollViewInsets = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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

    private func setupUI() {
        bgImageView.image = backgroundImage
        let isTransparentMode = backgroundImage != nil
        bgOverlayView.isHidden = !isTransparentMode
        let closeButtonImageName = isTransparentMode ? "ic_close" : "ic_close_red"
        closeButton.setImage(UIImage(named: closeButtonImageName), for: .normal)
    }

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
        closeButton.accessibilityId = .recaptchaCloseButton
        activityIndicator.accessibilityId = .recaptchaLoading
        webView.accessibilityId = .recaptchaWebView
    }
}
