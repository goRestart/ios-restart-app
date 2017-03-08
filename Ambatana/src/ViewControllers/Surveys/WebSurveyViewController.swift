//
//  WebSurveyViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 08/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class WebSurveyViewController: BaseViewController, WebSurveyViewModelDelegate {

    private let buttonDiameter: CGFloat = 50

    private let viewModel: WebSurveyViewModel

    fileprivate let webView = UIWebView()
    fileprivate let closeButton = UIButton()
    fileprivate let activityIndicator = UIActivityIndicatorView()

    private let disposeBag = DisposeBag()

    init(viewModel: WebSurveyViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let container = UIView()
        let views = [webView,closeButton,activityIndicator]
        container.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: views)
        container.addSubviews(views)

        webView.layout(with: container).fill()
        activityIndicator.layout(with: container).center()
        closeButton.layout(with: container).left()
        closeButton.layout(with: topLayoutGuide).below()
        closeButton.layout().width(54).height(44)

        activityIndicator.hidesWhenStopped = true
        closeButton.setImage(UIImage(named: "ic_close_red"), for: .normal)

        self.view = container
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.delegate = self
        closeButton.rx.tap.bindNext { [weak self] in self?.viewModel.closeButtonPressed() }.addDisposableTo(disposeBag)

        if let url = viewModel.url {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }
}

extension WebSurveyViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("👀 started loading: \(request.url)")
        return true
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {

    }
}
