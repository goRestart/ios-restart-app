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
    @IBOutlet weak var pageControlBottom: NSLayoutConstraint!

    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!

    var pages: [CommercialDisplayPageView]
    var viewModel: CommercialDisplayViewModel

    var source: CommercializerDisplaySource = .App

    var preDismissAction: (() -> Void)?
    var postDismissAction: (() -> Void)?

    var topPageConstraints: [NSLayoutConstraint] = []

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
        
        viewModel.viewLoaded()
        setupScrollView()
        insertCommercials()
        setupShareUI()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topPageConstraints.forEach { $0.constant = playerView.top }
    }

    public override func viewDidFirstAppear(animated: Bool) {
        super.viewDidFirstAppear(animated)
        playSelected()
    }

    override func viewWillDisappearToBackground(toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)
        pages.forEach {
            $0.pauseVideo()
            $0.didBecomeInactive()
        }
    }

    override func viewWillAppearFromBackground(fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        pages.forEach {
            $0.didBecomeActive()
        }
    }

    
    // MARK: - Actions

    @IBAction func onCloseButtonPressed(sender: AnyObject) {
        preDismissAction?()
        dismissViewControllerAnimated(true, completion: postDismissAction)
    }

    @IBAction func shareButtonPressed(sender: AnyObject) {
        pages.forEach {
            $0.pauseVideo()
        }
        let shareVC = CommercialShareViewController()
        shareVC.shareDelegate = self
        shareVC.socialSharerDelegate = self
        shareVC.socialMessage = viewModel.socialShareMessage
        presentViewController(shareVC, animated: true, completion: nil)
    }

    
    // MARK: - Private methods
    
    private func setupScrollView() {
        pageControl.pageIndicatorTintColor = UIColor.pageIndicatorTintColorDark
        pageControl.currentPageIndicatorTintColor = UIColor.currentPageIndicatorTintColorDark
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = viewModel.numberOfCommercials
        pageControl.hidesForSinglePage = true
        
        viewModel.selectCommercialAtIndex(pageControl.currentPage)

        scrollView.delegate = self
        scrollView.pagingEnabled = true

        if DeviceFamily.current == .iPhone4 {
            pageControlBottom.constant = 8
        }
    }

    private func insertCommercials() {

        var previousPage: UIView? = nil
        for index in 0..<viewModel.numberOfCommercials {
            let displayPage = CommercialDisplayPageView.instanceFromNib()
            displayPage.translatesAutoresizingMaskIntoConstraints = false
            displayPage.delegate = self
            pages.append(displayPage)
            scrollView.addSubview(displayPage)

            let topConstraint = NSLayoutConstraint(item: displayPage, attribute: .Top, relatedBy: .Equal,
                                        toItem: scrollView, attribute: .Top, multiplier: 1, constant: playerView.top)
            topPageConstraints.append(topConstraint)
            scrollView.addConstraint(topConstraint)
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
        closeButton.tintColor = UIColor.primaryColor
        titleLabel.text = viewModel.isMyVideo ? LGLocalizedString.commercializerDisplayTitleLabel : nil
        shareLabel.text = viewModel.isMyVideo ? LGLocalizedString.commercializerDisplayShareLabel : nil
        shareButton.setStyle(.Primary(fontSize: .Medium))
        let shareButtonTitle = viewModel.isMyVideo ?
            LGLocalizedString.commercializerDisplayShareMyVideoButton :
            LGLocalizedString.commercializerDisplayShareOthersVideoButton
        shareButton.setTitle(shareButtonTitle, forState: .Normal)
    }
}


// MARK: - Swipeable videos

extension CommercialDisplayViewController: UIScrollViewDelegate, CommercialDisplayPageViewDelegate {

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

    func pageViewWillShowFullScreen() {
        pageViewWillChangeToFullScreen(true)
    }

    func pageViewWillHideFullScreen() {
        pageViewWillChangeToFullScreen(false)
    }

    private func pageViewWillChangeToFullScreen(fullscreen: Bool ) {
        titleLabel.hidden = fullscreen
        shareLabel.hidden = fullscreen
        shareButton.hidden = fullscreen
        pageControl.hidden = fullscreen
        scrollView.scrollEnabled = !fullscreen
        closeButton.hidden = fullscreen
        UIApplication.sharedApplication().setStatusBarHidden(fullscreen, withAnimation: .Fade)
    }
}


// MARK: - SocialSharerDelegate

extension CommercialDisplayViewController: SocialSharerDelegate {
    func shareStartedIn(shareType: ShareType) {
        viewModel.shareStartedIn(shareType)
    }

    func shareFinishedIn(shareType: ShareType, withState state: SocialShareState) {
        viewModel.shareFinishedIn(shareType, withState: state)
    }
}


// MARK: - SocialShareViewDelegate

extension CommercialDisplayViewController: SocialShareViewDelegate {
    func viewController() -> UIViewController? {
        return self
    }
}
