//
//  CommercialDisplayViewController.swift
//  LetGo
//
//  Created by Dídac on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

enum CommercializerDisplaySource {
    // used for tracking and to decide what title should be shown
    case Push
    case Mail
    case App
}

public class CommercialDisplayViewController: BaseViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var playerView: UIView!

    @IBOutlet weak var pageControl: UIPageControl!

    @IBOutlet weak var socialShareView: SocialShareView!
    @IBOutlet weak var shareLabel: UILabel!

    var pages: [CommercialDisplayPageView]
    var viewModel: CommercialDisplayViewModel

    var source: CommercializerDisplaySource = .App

    var preDismissAction: (() -> Void)?

    // MARK: - Lifecycle

    public convenience init(viewModel: CommercialDisplayViewModel) {
        self.init(viewModel: viewModel, nibName: "CommercialDisplayViewController")
    }

    public required init(viewModel: CommercialDisplayViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        self.pages = []
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        switch source {
        case .App:
            titleLabel.text = ""
            titleLabel.hidden = true
        case .Push, .Mail:
            titleLabel.text = LGLocalizedString.commercializerDisplayTitleLabel
            titleLabel.hidden = false
        }

        bgView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        setupScrollView()
        insertCommercials()
        setupSocialShareView()
    }


    // MARK: - Actions

    @IBAction func onCloseButtonPressed(sender: AnyObject) {
        preDismissAction?()
        dismissViewControllerAnimated(true, completion: nil)
    }


    // MARK: - Private methods

    private func setupScrollView() {
        pageControl.currentPage = 0
        pageControl.numberOfPages = viewModel.numberOfCommercials
        pageControl.hidden = viewModel.numberOfCommercials <= 1

        viewModel.selectCommercialAtIndex(pageControl.currentPage)

        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.contentSize = CGSize(width: CGFloat(viewModel.numberOfCommercials) * scrollView.frame.size.width, height: scrollView.frame.size.height)
        scrollView.scrollRectToVisible(CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: false)
    }

    private func insertCommercials() {

        for index in 0..<viewModel.numberOfCommercials {
            let displayPage = CommercialDisplayPageView.instanceFromNib()
            let width = scrollView.bounds.width
            let height = scrollView.bounds.height
            let originX = width * CGFloat(index)
            displayPage.frame = CGRect(x: originX, y: 0, width: width, height: height)
            displayPage.playerView.frame = playerView.frame

            guard let url = viewModel.videoUrlAtIndex(index) else { continue }
            displayPage.setupVideoPlayerWithUrl(url)

            pages.append(displayPage)
            scrollView.addSubview(displayPage)

            guard let thumbUrl = viewModel.thumbUrlAtIndex(index) else { continue }
            displayPage.setupThumbnailWithUrl(thumbUrl)
        }
    }

    private func setupSocialShareView() {
        shareLabel.text = LGLocalizedString.commercializerDisplayShareLabel
        socialShareView.delegate = self
        socialShareView.socialMessage = viewModel.socialShareMessage
    }
}


// MARK: - UIScrollViewDelegate

extension CommercialDisplayViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let previousVC = pages[pageControl.currentPage]
        previousVC.videoPlayer.controlsAreVisible = true
        previousVC.pauseVideo()
        let newPage = floor((self.scrollView.contentOffset.x - self.scrollView.frame.size.width / 2) / self.scrollView.frame.size.width) + 1
        pageControl.currentPage = Int(newPage)
        viewModel.selectCommercialAtIndex(pageControl.currentPage)
    }
}


// MARK: - SocialShareViewDelegate

extension CommercialDisplayViewController: SocialShareViewDelegate {

    func shareInEmail(){
    }

    func shareInFacebook() {
    }

    func shareInFacebookFinished(state: SocialShareState) {
    }

    func shareInFBMessenger() {
    }

    func shareInFBMessengerFinished(state: SocialShareState) {
    }

    func shareInWhatsApp() {
    }

    func viewController() -> UIViewController? {
        return self
    }
}
