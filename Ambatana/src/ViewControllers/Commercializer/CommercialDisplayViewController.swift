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

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var playerView: UIView!

    @IBOutlet weak var pageControl: UIPageControl!

    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!

    var pages: [CommercialDisplayPageView]
    var viewModel: CommercialDisplayViewModel

    var source: CommercializerDisplaySource = .App

    var preDismissAction: (() -> Void)?
    var postDismissAction: (() -> Void)?

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

        setupScrollView()
        insertCommercials()
        setupShareUI()
    }

    public override func viewDidFirstAppear(animated: Bool) {
        super.viewDidFirstAppear(animated)
        playSelected()
    }

    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        pages.forEach { $0.pauseVideo() }
    }

    override func viewWillDisappearToBackground(toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)
        pages.forEach { $0.pauseVideo() }
    }

    // MARK: - Actions

    @IBAction func onCloseButtonPressed(sender: AnyObject) {
        preDismissAction?()
        dismissViewControllerAnimated(true, completion: postDismissAction)
    }

    @IBAction func shareButtonPressed(sender: AnyObject) {
        let shareVC = CommercialShareViewController()
        shareVC.shareDelegate = self
        shareVC.socialMessage = viewModel.socialShareMessage
        presentViewController(shareVC, animated: true, completion: nil)
    }

    // MARK: - Private methods

    private func setupScrollView() {
        pageControl.currentPage = 0
        pageControl.numberOfPages = viewModel.numberOfCommercials
        pageControl.hidden = viewModel.numberOfCommercials <= 1

        viewModel.selectCommercialAtIndex(pageControl.currentPage)

        scrollView.delegate = self
        scrollView.pagingEnabled = true
    }

    private func insertCommercials() {

        var previousPage: UIView? = nil
        for index in 0..<viewModel.numberOfCommercials {
            let displayPage = CommercialDisplayPageView.instanceFromNib()
            displayPage.translatesAutoresizingMaskIntoConstraints = false

            pages.append(displayPage)
            scrollView.addSubview(displayPage)

            scrollView.addConstraint(NSLayoutConstraint(item: displayPage, attribute: .Top, relatedBy: .Equal,
                                                toItem: scrollView, attribute: .Top, multiplier: 1, constant: 0))
            scrollView.addConstraint(NSLayoutConstraint(item: displayPage, attribute: .Width, relatedBy: .Equal,
                                                     toItem: scrollView, attribute: .Width, multiplier: 1, constant: 0))
            displayPage.addConstraint(NSLayoutConstraint(item: displayPage, attribute: .Width, relatedBy: .Equal,
                toItem: displayPage, attribute: .Height, multiplier: 16.0/9.0, constant: 0))
            // A left constraint in installed to previous page if any, otherwise it installed against the scroll view
            if let previousPage = previousPage {
                scrollView.addConstraint(NSLayoutConstraint(item: displayPage, attribute: .Left, relatedBy: .Equal,
                                            toItem: previousPage, attribute: .Right, multiplier: 1, constant: 0))
            } else {
                scrollView.addConstraint(NSLayoutConstraint(item: displayPage, attribute: .Left, relatedBy: .Equal,
                                                    toItem: scrollView, attribute: .Left, multiplier: 1, constant: 0))
            }

            guard let url = viewModel.videoUrlAtIndex(index) else { continue }
            displayPage.setupVideoPlayerWithUrl(url)

            guard let thumbUrl = viewModel.thumbUrlAtIndex(index) else { continue }
            displayPage.setupThumbnailWithUrl(thumbUrl)

            previousPage = displayPage
        }
        if let lastPage = previousPage {
            scrollView.addConstraint(NSLayoutConstraint(item: lastPage, attribute: .Right, relatedBy: .Equal,
                                                     toItem: scrollView, attribute: .Right, multiplier: 1, constant: 0))
        }
    }

    private func setupShareUI() {
        titleLabel.text = viewModel.isMyVideo ? LGLocalizedString.commercializerDisplayTitleLabel : nil
        shareLabel.text = viewModel.isMyVideo ? LGLocalizedString.commercializerDisplayShareLabel : nil
        shareButton.setPrimaryStyle()
        let shareButtonTitle = viewModel.isMyVideo ?
            LGLocalizedString.commercializerDisplayShareMyVideoButton :
            LGLocalizedString.commercializerDisplayShareOthersVideoButton
        shareButton.setTitle(shareButtonTitle, forState: .Normal)
    }
}


// MARK: - Swipeable videos

extension CommercialDisplayViewController: UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let previousVC = pages[pageControl.currentPage]
        previousVC.videoPlayer.controlsAreVisible = true
        previousVC.pauseVideo()
        let newPage = floor((self.scrollView.contentOffset.x - self.scrollView.frame.size.width / 2) / self.scrollView.frame.size.width) + 1
        pageControl.currentPage = Int(newPage)
        viewModel.selectCommercialAtIndex(pageControl.currentPage)
    }

    public func playSelected() {
        let currentVC = pages[pageControl.currentPage]
        currentVC.playVideo()
    }
}


// MARK: - SocialShareViewDelegate

extension CommercialDisplayViewController: SocialShareViewDelegate {

    func shareInEmail(){
        viewModel.didShareInEmail()
    }

    func shareInEmailFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.didShareInEmailCompleted()
        case .Cancelled, .Failed:
            break
        }
    }

    func shareInFacebook() {
        viewModel.didShareInFacebook()
    }

    func shareInFacebookFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.didShareInFBCompleted()
        case .Cancelled:
            break
        case .Failed:
            showAutoFadingOutMessageAlert(LGLocalizedString.sellSendErrorSharingFacebook)
        }
    }

    func shareInFBMessenger() {
        viewModel.didShareInFBMessenger()
    }

    func shareInFBMessengerFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.didShareInFBMessengerCompleted()
        case .Cancelled:
            break
        case .Failed:
            showAutoFadingOutMessageAlert(LGLocalizedString.sellSendErrorSharingFacebook)
        }
    }

    func shareInWhatsApp() {
        viewModel.didShareInWhatsApp()
    }

    func shareInTwitter() {
        viewModel.didShareInTwitter()
    }

    func shareInTwitterFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.didShareInTwitterCompleted()
        case .Cancelled, .Failed:
            break
        }
    }

    func shareInTelegram() {
        viewModel.didShareInTelegram()
    }

    func viewController() -> UIViewController? {
        return self
    }
    
    func shareInSMS() {
        viewModel.didShareInSMS()
    }
    
    func shareInSMSFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.didShareInSMSCompleted()
        case .Cancelled, .Failed:
            break
        }
    }
    
    func shareInCopyLink() {
        viewModel.didShareInCopyLink()
    }
}
