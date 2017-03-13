//
//  WebSurveyViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 08/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift
import WebKit

class WebSurveyViewController: BaseViewController {

    private let buttonDiameter: CGFloat = 50

    fileprivate let viewModel: WebSurveyViewModel

    fileprivate let webView = WKWebView()
    fileprivate let closeButton = UIButton()
    fileprivate let activityIndicator = UIActivityIndicatorView()

    private let disposeBag = DisposeBag()

    init(viewModel: WebSurveyViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let container = UIView()
        let views = [webView, closeButton, activityIndicator]
        container.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: views)
        container.addSubviews(views)

        activityIndicator.layout(with: container).center()
        closeButton.layout(with: container).left()
        closeButton.layout().width(Metrics.closeButtonWidth).height(Metrics.closeButtonHeight)
        webView.layout(with: container).left().right().bottom()
        webView.layout(with: closeButton).below()

        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        closeButton.setImage(UIImage(named: "ic_close_red"), for: .normal)
        container.backgroundColor = UIColor.white
        webView.backgroundColor = UIColor.white

        self.view = container
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        closeButton.layout(with: topLayoutGuide).below()

        webView.navigationDelegate = self
        closeButton.rx.tap.bindNext { [weak self] in self?.viewModel.closeButtonPressed() }.addDisposableTo(disposeBag)

        let request = URLRequest(url: viewModel.url)
        webView.load(request)
    }
}

extension WebSurveyViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated, .other:
            if !viewModel.shouldLoad(url: navigationAction.request.url) {
                decisionHandler(.cancel)
            }
        default: break
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        viewModel.didFailNavigation()
    }
}
