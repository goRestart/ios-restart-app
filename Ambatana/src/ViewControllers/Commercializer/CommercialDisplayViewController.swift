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
    case push
    case mail
    case app
}

class CommercialDisplayViewController: BaseViewController {

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

    var source: CommercializerDisplaySource = .app

    var preDismissAction: (() -> Void)?
    var postDismissAction: (() -> Void)?

    var topPageConstraints: [NSLayoutConstraint] = []

    // MARK: - Lifecycle

    convenience init(viewModel: CommercialDisplayViewModel) {
        self.init(viewModel: viewModel, nibName: "CommercialDisplayViewController")
    }

    required init(viewModel: CommercialDisplayViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        self.pages = []
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.viewLoaded()
        setupScrollView()
        insertCommercials()
        setupShareUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topPageConstraints.forEach { $0.constant = playerView.top }
    }

    override func viewDidFirstAppear(_ animated: Bool) {
        super.viewDidFirstAppear(animated)
        playSelected()
    }

    override func viewWillDisappearToBackground(_ toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)
        pages.forEach {
            $0.pauseVideo()
            $0.didBecomeInactive()
        }
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        pages.forEach {
            $0.didBecomeActive()
        }
    }

    
    // MARK: - Actions

    @IBAction func onCloseButtonPressed(_ sender: AnyObject) {
        preDismissAction?()
        dismiss(animated: true, completion: postDismissAction)
    }

    @IBAction func shareButtonPressed(_ sender: AnyObject) {
        pages.forEach {
            $0.pauseVideo()
        }
        let shareVC = CommercialShareViewController()
        shareVC.shareDelegate = self
        shareVC.socialSharerDelegate = self
        shareVC.socialMessage = viewModel.socialShareMessage
        present(shareVC, animated: true, completion: nil)
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
        scrollView.isPagingEnabled = true

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

            let topConstraint = NSLayoutConstraint(item: displayPage, attribute: .top, relatedBy: .equal,
                                        toItem: scrollView, attribute: .top, multiplier: 1, constant: playerView.top)
            topPageConstraints.append(topConstraint)
            scrollView.addConstraint(topConstraint)
            scrollView.addConstraint(NSLayoutConstraint(item: displayPage, attribute: .width, relatedBy: .equal,
                                                     toItem: scrollView, attribute: .width, multiplier: 1, constant: 0))
            displayPage.addConstraint(NSLayoutConstraint(item: displayPage, attribute: .width, relatedBy: .equal,
                toItem: displayPage, attribute: .height, multiplier: 16.0/9.0, constant: 0))
            // A left constraint in installed to previous page if any, otherwise it installed against the scroll view
            if let previousPage = previousPage {
                scrollView.addConstraint(NSLayoutConstraint(item: displayPage, attribute: .left, relatedBy: .equal,
                                            toItem: previousPage, attribute: .right, multiplier: 1, constant: 0))
            } else {
                scrollView.addConstraint(NSLayoutConstraint(item: displayPage, attribute: .left, relatedBy: .equal,
                                                    toItem: scrollView, attribute: .left, multiplier: 1, constant: 0))
            }

            guard let url = viewModel.videoUrlAtIndex(index) else { continue }
            displayPage.setupVideoPlayerWithUrl(url)

            guard let thumbUrl = viewModel.thumbUrlAtIndex(index) else { continue }
            displayPage.setupThumbnailWithUrl(thumbUrl)

            previousPage = displayPage
        }
        if let lastPage = previousPage {
            scrollView.addConstraint(NSLayoutConstraint(item: lastPage, attribute: .right, relatedBy: .equal,
                                                     toItem: scrollView, attribute: .right, multiplier: 1, constant: 0))
        }
    }

    private func setupShareUI() {
        closeButton.tintColor = UIColor.primaryColor
        titleLabel.text = viewModel.isMyVideo ? LGLocalizedString.commercializerDisplayTitleLabel : nil
        shareLabel.text = viewModel.isMyVideo ? LGLocalizedString.commercializerDisplayShareLabel : nil
        shareButton.setStyle(.primary(fontSize: .medium))
        let shareButtonTitle = viewModel.isMyVideo ?
            LGLocalizedString.commercializerDisplayShareMyVideoButton :
            LGLocalizedString.commercializerDisplayShareOthersVideoButton
        shareButton.setTitle(shareButtonTitle, for: UIControlState())
    }
}


// MARK: - Swipeable videos

extension CommercialDisplayViewController: UIScrollViewDelegate, CommercialDisplayPageViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let previousVC = pages[pageControl.currentPage]
        previousVC.videoPlayer.controlsAreVisible = true
        previousVC.pauseVideo()
        let newPage = floor((self.scrollView.contentOffset.x - self.scrollView.frame.size.width / 2) / self.scrollView.frame.size.width) + 1
        pageControl.currentPage = Int(newPage)
        viewModel.selectCommercialAtIndex(pageControl.currentPage)
    }

    func playSelected() {
        let currentVC = pages[pageControl.currentPage]
        currentVC.playVideo()
    }

    func pageViewWillShowFullScreen() {
        pageViewWillChangeToFullScreen(true)
    }

    func pageViewWillHideFullScreen() {
        pageViewWillChangeToFullScreen(false)
    }

    private func pageViewWillChangeToFullScreen(_ fullscreen: Bool ) {
        titleLabel.isHidden = fullscreen
        shareLabel.isHidden = fullscreen
        shareButton.isHidden = fullscreen
        pageControl.isHidden = fullscreen
        scrollView.isScrollEnabled = !fullscreen
        closeButton.isHidden = fullscreen
        UIApplication.shared.setStatusBarHidden(fullscreen, with: .fade)
    }
}


// MARK: - SocialSharerDelegate

extension CommercialDisplayViewController: SocialSharerDelegate {
    func shareStartedIn(_ shareType: ShareType) {
        viewModel.shareStartedIn(shareType)
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        viewModel.shareFinishedIn(shareType, withState: state)
    }
}


// MARK: - SocialShareViewDelegate

extension CommercialDisplayViewController: SocialShareViewDelegate {
    func viewController() -> UIViewController? {
        return self
    }
}
