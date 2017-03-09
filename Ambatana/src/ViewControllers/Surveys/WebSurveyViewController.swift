//
//  WebSurveyViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 08/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class WebSurveyViewController: BaseViewController {

    private let buttonDiameter: CGFloat = 50

    fileprivate let viewModel: WebSurveyViewModel

    fileprivate let webView = UIWebView()
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
        let views = [webView,closeButton,activityIndicator]
        container.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: views)
        container.addSubviews(views)

        activityIndicator.layout(with: container).center()
        closeButton.layout(with: container).left()
        closeButton.layout().width(54).height(44)
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

        webView.delegate = self
        closeButton.rx.tap.bindNext { [weak self] in self?.viewModel.closeButtonPressed() }.addDisposableTo(disposeBag)

        let request = URLRequest(url: viewModel.url)
        webView.loadRequest(request)
    }
}

extension WebSurveyViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return viewModel.shouldLoad(url: request.url)
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        viewModel.failedLoad()
    }
}
