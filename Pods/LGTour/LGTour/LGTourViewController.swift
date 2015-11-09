//
//  LGTourViewController.swift
//  LGTour
//
//  Created by Albert Hernández López on 28/10/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

//import CoreMotion
//import GLKit
import UIKit

/**
    Defines the close button types.
*/
public enum CloseButtonType {
    case Skip, Close
}

public protocol LGTourViewControllerDelegate: class {
    /**
        A tour view controller show a page.
        
        - parameter tourViewController: The tour view controller.
        - parameter index: The page index.
    */
    func tourViewController(tourViewController: LGTourViewController, didShowPageAtIndex index: Int)
    
    /**
        The users abandons the tour view controller.
    
        - parameter tourViewController: The tour view controller.
        - parameter index: The page index.
        - parameter buttonType: The button type pressed.
    */
    func tourViewController(tourViewController: LGTourViewController, didAbandonWithButtonType buttonType: CloseButtonType, atIndex index: Int)
    
    /**
        The users finishes the tour.
    
        - parameter tourViewController: The tour view controller.
    */
    func tourViewControllerDidFinish(tourViewController: LGTourViewController)
}

/**
    A controller to show tours.
*/
public class LGTourViewController: UIViewController, UIScrollViewDelegate {
    
    // UI
    // > Background & top
    @IBOutlet weak var backgroundScrollView: UIScrollView!
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            backgroundImageView.backgroundColor = backgroundColor
            backgroundImageView.image = backgroundImage
        }
    }
    @IBOutlet weak var backgroundImageViewWidthConstraint: NSLayoutConstraint!  // proportional's to scrollview width
    @IBOutlet weak var backgroundImageViewHeightConstraint: NSLayoutConstraint!  // proportional's to scrollview height
    
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.setImage(closeButtonImage, forState: .Normal)
        }
    }
    
    // > Main scroll view + page control
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    @IBOutlet weak var pageControl: UIPageControl!

    // > iPhone
    @IBOutlet weak var iPhoneTopImageView: UIImageView! {
        didSet {
            iPhoneTopImageView.image = UIImage(named: "iphone_top", inBundle: NSBundle.LGTourBundle(), compatibleWithTraitCollection: nil)
        }
    }
    @IBOutlet weak var iPhoneLeftImageView: UIImageView! {
        didSet {
            iPhoneLeftImageView.image = UIImage(named: "iphone_left", inBundle: NSBundle.LGTourBundle(), compatibleWithTraitCollection: nil)?.resizableImageWithCapInsets(UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0))
        }
    }
    @IBOutlet weak var iPhoneRightImageView: UIImageView! {
        didSet {
            iPhoneRightImageView.image = UIImage(named: "iphone_right", inBundle: NSBundle.LGTourBundle(), compatibleWithTraitCollection: nil)?.resizableImageWithCapInsets(UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0))
        }
    }
    @IBOutlet weak var iPhoneBottomImageView: UIImageView! {
        didSet {
            iPhoneBottomImageView.image = UIImage(named: "iphone_bottom", inBundle: NSBundle.LGTourBundle(), compatibleWithTraitCollection: nil)
        }
    }
    @IBOutlet weak var iPhoneScreenScrollView: UIScrollView!
    
    // > Footer
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var leftButton: UIButton! {
        didSet {
            leftButton.setImage(leftButtonImage, forState: .Normal)
        }
    }
    
    @IBOutlet weak var skipButton: UIButton! {
        didSet {
            skipButton.setImage(skipButtonImage, forState: .Normal)
            skipButton.setTitleColor(skipButtonTextColor, forState: .Normal)
            skipButton.setTitle(skipButtonNonLastPageText, forState: .Normal)
            if let bgColor = skipButtonBackgroundColor {
                let img = UIImage.imageWithColor(bgColor)
                skipButton.setBackgroundImage(img, forState: .Normal)
            }
            skipButton.layer.cornerRadius = skipButtonBorderRadius
        }
    }
    
    @IBOutlet weak var rightButton: UIButton! {
        didSet {
            rightButton.setImage(rightButtonImage, forState: .Normal)
        }
    }
    
    // > Page Views
    private var pageViews: [LGTourPageView]
    private var iPhoneScreenPageViews: [UIImageView]
    
    // Appereance
    public var backgroundColor: UIColor? {
        didSet {
            if let actualBackgroundImageView = backgroundImageView {
                actualBackgroundImageView.backgroundColor = backgroundColor
            }
        }
    }
    public var backgroundImage: UIImage? {
        didSet {
            if let actualBackgroundImageView = backgroundImageView {
                actualBackgroundImageView.image = backgroundImage
            }
        }
    }
    public var closeButtonImage: UIImage? {
        didSet {
            if let actualCloseButton = closeButton {
                actualCloseButton.setImage(closeButtonImage, forState: .Normal)
            }
        }
    }
    public var pageTitleColor: UIColor? {
        didSet {
            for pageView in pageViews {
                pageView.titleLabel.textColor = pageTitleColor
            }
        }
    }
    public var pageBodyColor: UIColor? {
        didSet {
            for pageView in pageViews {
                pageView.bodyLabel.textColor = pageBodyColor
            }
        }
    }
    public var leftButtonImage: UIImage? {
        didSet {
            if let actualLeftButton = leftButton {
                actualLeftButton.setImage(leftButtonImage, forState: .Normal)
            }
        }
    }
    
    public var skipButtonBackgroundColor: UIColor? {
        didSet {
            if let actualSkipButton = skipButton {
                actualSkipButton.backgroundColor = skipButtonBackgroundColor
            }
        }
    }
    
    public var skipButtonTextColor: UIColor? {
        didSet {
            if let actualSkipButton = skipButton {
                actualSkipButton.setTitleColor(skipButtonTextColor, forState: .Normal)
            }
        }
    }
    
    public var skipButtonBorderRadius: CGFloat = 0 {
        didSet {
            if let actualSkipButton = skipButton {
                actualSkipButton.layer.cornerRadius = skipButtonBorderRadius
            }
        }
    }

    public var skipButtonImage: UIImage?  {
        didSet {
            if let actualSkipButton = skipButton {
                actualSkipButton.setImage(skipButtonImage, forState: .Normal)
            }
        }
    }
    
    public var rightButtonImage: UIImage? {
        didSet {
            if let actualRightButton = rightButton {
                actualRightButton.setImage(rightButtonImage, forState: .Normal)
            }
        }
    }
    
    // Texts
    public var skipButtonNonLastPageText: String?
    public var skipButtonLastPageText: String?
    
    // Data & other properties
    private let pages: [LGTourPage]
    private let parallaxFactor: Float
    private var backgroundContentOffsetX: CGFloat
//    private let motionManager: CMMotionManager
//    private var backgroundContentTilt: CGPoint = CGPoint(x: 0, y: 0)
//    private var rollPitchYaw: RollPitchYaw = RollPitchYaw()
    
    public var iPhoneScreenBounceEnabled: Bool
    public var currentPage: Int
    
    public var numberOfPages: Int {
        return pages.count
    }
    
    public var isLastPage: Bool {
        return currentPage >= ( numberOfPages - 1 )
    }
    
    // Delegate
    public weak var delegate: LGTourViewControllerDelegate?

    
    // MARK: - Lifecycle

    public convenience init(pages: [LGTourPage]) {
        self.init(pages: pages, parallaxFactor: 0.2)
    }
    
    public init(pages: [LGTourPage], parallaxFactor: Float) {
        self.pageViews = []
        self.iPhoneScreenPageViews = []
        self.pages = pages
        self.parallaxFactor = max(0, min(parallaxFactor, 1))
        self.backgroundContentOffsetX = 0
//        self.motionManager = CMMotionManager()
//        self.backgroundContentTilt = CGPoint(x: 0, y: 0)
        
        self.iPhoneScreenBounceEnabled = false
        self.currentPage = 0
        super.init(nibName: "LGTourViewController", bundle: NSBundle.LGTourBundle())
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the page views
        for page in pages {
            addPageViewWithPage(page)
        }
        
        // If there are pages, then notify the delegate that we're showing the first
        if numberOfPages > 0 {
            delegate?.tourViewController(self, didShowPageAtIndex: 0)
        }
       
        // @ahl: tilt stuff, commented for now
        
//        if motionManager.deviceMotionAvailable {
//            motionManager.deviceMotionUpdateInterval = 0.2
//            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) { [weak self] (deviceMotion: CMDeviceMotion?, error: NSError?) in
////                guard let strongSelf = self, let motionQuaternion = deviceMotion?.attitude.quaternion else {
////                    return
////                }
////                let quaternion = GLKQuaternionMake(Float(motionQuaternion.x), Float(motionQuaternion.y), Float(motionQuaternion.z), Float(motionQuaternion.w))
////                strongSelf.rollPitchYaw.updateWithQuaternion(quaternion)
////
//                let π = CGFloat(M_PI)
//                let π2 = 2*π
////                let roll = strongSelf.rollPitchYaw.roll
////                let pitch = strongSelf.rollPitchYaw.pitch
////                let yaw = strongSelf.rollPitchYaw.yaw
//                guard let strongSelf = self, let attitude = deviceMotion?.attitude else {
//                    return
//                }
//                
//                let roll = CGFloat(attitude.roll)
//                let pitch = CGFloat(attitude.pitch)
//                let yaw = CGFloat(attitude.yaw)
//                
//                var tx: CGFloat = min(π, max(-π, roll))
//                tx = (roll * 80) / π2
//                
//                var ty: CGFloat = min(π, max(-π, pitch))
//                ty = (pitch * 80) / π2
////                print("\(abs(tx)), \(abs(ty))")
//                
//                strongSelf.backgroundContentTilt = CGPoint(x: abs(tx), y: abs(ty))
//                strongSelf.updateContentOffset()
////                strongSelf.backgroundImageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0)//CGAffineTransformMakeTranslation(tx, ty)
//                
//            }
//        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Place the scrollView's subviews at their correct positions
        let scrollViewWidth = CGRectGetWidth(scrollView.frame)
        let scrollViewHeight = CGRectGetHeight(scrollView.frame)
        var scrollViewX: CGFloat = 0
        for page in pageViews {
            page.frame = CGRect(x: scrollViewX, y: 0, width: scrollViewWidth, height: scrollViewHeight)
            scrollViewX += scrollViewWidth
        }
        // Adjust the scrollView content size
        let scrollViewContentSize = CGSize(width: scrollViewX, height: scrollViewHeight)
        scrollView.contentSize = scrollViewContentSize
        
        // Place the iPhoneScreenScrollView's subviews at their correct positions
        let iPhoneScreenWidth = CGRectGetWidth(iPhoneScreenScrollView.frame)
        let iPhoneScreenHeight = CGRectGetHeight(iPhoneScreenScrollView.frame)
        var iPhoneScreenX: CGFloat = 0
        for iPhoneScreenPage in iPhoneScreenPageViews {
            iPhoneScreenPage.frame = CGRect(x: iPhoneScreenX, y: 0, width: iPhoneScreenWidth, height: iPhoneScreenHeight)
            iPhoneScreenX += iPhoneScreenWidth
        }
        // Adjust the iPhoneScreenScrollView content size
        let iPhoneScreenContentSize = CGSize(width: iPhoneScreenX, height: iPhoneScreenHeight)
        iPhoneScreenScrollView.contentSize = iPhoneScreenContentSize
        
        // Adjust width of the background image
        backgroundImageViewHeightConstraint.constant = backgroundScrollView.frame.height + 80
        backgroundImageViewWidthConstraint.constant = backgroundScrollView.frame.width * CGFloat(numberOfPages + 1) + 80
        
        // Updates scrollviews page (checkable on rotation)
        currentPage = currentPageOfScrollView(scrollView)
        scrollToPage(currentPage)
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // called when scroll view grinds to a halt cos' of user moving scroll view
        updateUIIfPageChanged()
        updateScrollViewsContentOffset()
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
        updateUIIfPageChanged()
        updateScrollViewsContentOffset()
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        updateScrollViewsContentOffset()
    }
    
    // MARK: - Internal methods
    
    /**
        Called when the closed button is pressed.
    
        - parameter sender: The UIButton that arised this method.
    */
    @IBAction func closeButtonPressed(sender: UIButton) {
        delegate?.tourViewController(self, didAbandonWithButtonType: .Close, atIndex: currentPage)
    }
    
    /**
        Called when the page control's page changes.
    
        - parameter sender: The UIPageControl that arised this method.
    */
    @IBAction func pageControlPageChanged(sender: UIPageControl) {
        let page = pageControl.currentPage
        scrollToPage(page)
    }
    
    /**
        Called when the left button is pressed.
    
        - parameter sender: The UIButton that arised this method.
    */
    @IBAction func leftButtonPressed(sender: UIButton) {
        let page = currentPage-1
        scrollToPage(page)
    }
    
    /**
        Called when the skip/complete button is pressed.
    
        - parameter sender: The UIButton that arised this method.
    */
    @IBAction func skipButtonPressed(sender: UIButton) {
        if isLastPage {
            delegate?.tourViewControllerDidFinish(self)
        }
        else {
            delegate?.tourViewController(self, didAbandonWithButtonType: .Skip, atIndex: currentPage)
        }
    }
    
    /**
        Called when the right button is pressed.
    
        - parameter sender: The UIButton that arised this method.
    */
    @IBAction func rightButtonPressed(sender: UIButton) {
        let page = currentPage+1
        scrollToPage(page)
    }
    
    // MARK: - Private methods
    
    // MARK: > Setup
    
    /**
        Adds a page view with the given page.
    
        - parameter page: The page.
    */
    private func addPageViewWithPage(page: LGTourPage) {
        // Create the page and add it to the pageViews
        let pageView = LGTourPageView(frame: view.frame, page: page)
        pageView.titleLabel.textColor = pageTitleColor
        pageView.bodyLabel.textColor = pageBodyColor
        pageViews.append(pageView)

        // Add it as subview
        scrollView.addSubview(pageView)
        
        // Create the page and add it to iPhoneScreenPageViews
        let iphoneScreenPageView = UIImageView(frame: view.frame)
        iphoneScreenPageView.contentMode = .Top
        iphoneScreenPageView.image = page.image
        iPhoneScreenPageViews.append(iphoneScreenPageView)
        
        // Add it as subview
        iPhoneScreenScrollView.addSubview(iphoneScreenPageView)
        
        // Update page control
        pageControl.numberOfPages = numberOfPages
        pageControl.hidden = numberOfPages <= 1
        
        view.setNeedsUpdateConstraints()
    }
    
    // MARK: > Update
    
    /**
        Updates the UI if the page has actually changed.
    */
    func updateUIIfPageChanged() {
        // If there's a page change
        let newCurrentPage = currentPageOfScrollView(scrollView)
        if currentPage != newCurrentPage {
            
            // Notify the delegate the page we're showing
            delegate?.tourViewController(self, didShowPageAtIndex: newCurrentPage)
            
            // Update current page
            currentPage = newCurrentPage
            
            // Page indicator
            pageControl.currentPage = newCurrentPage
            
            // Buttons
            updateButtonsVisibility()
        }
    }
    
    /**
        Updates the scroll views content offset.
    */
    func updateScrollViewsContentOffset() {
        
        // Update the background content offset
        let contentOffsetXPercentage = min(1, scrollView.contentOffset.x / scrollView.contentSize.width)    // max: 100%
        backgroundContentOffsetX = contentOffsetXPercentage * backgroundScrollView.frame.width * (1 + CGFloat(parallaxFactor))
        
        // Update the content offset
        updateBackgroundContentOffset()
        
        // Update the iphone scrollview content offset w or w/o bounce
        if iPhoneScreenBounceEnabled {
            iPhoneScreenScrollView.contentOffset.x = contentOffsetXPercentage * iPhoneScreenScrollView.contentSize.width
        }
        else {
            iPhoneScreenScrollView.contentOffset.x = min(max(0,contentOffsetXPercentage * iPhoneScreenScrollView.contentSize.width),iPhoneScreenScrollView.contentSize.width - iPhoneScreenScrollView.frame.width)
        }
    }
    
    /**
        Updates the background content offset.
    */
    private func updateBackgroundContentOffset() {
//        let contentOffset = CGPoint(x: backgroundContentOffsetX + backgroundContentTilt.x, y: backgroundContentTilt.y)
        backgroundScrollView.contentOffset.x = backgroundContentOffsetX + backgroundScrollView.frame.width / 2
    }
    
    /**
        Updates the buttons visibility.
    */
    private func updateButtonsVisibility() {
        let leftButtonAlpha: CGFloat = (currentPage == 0) ? 0 : 1
        UIView.animateWithDuration(0.2) {
            self.leftButton.alpha = leftButtonAlpha
        }
        
        let rightButtonAlpha: CGFloat = isLastPage ? 0 : 1
        UIView.animateWithDuration(0.2) {
            self.rightButton.alpha = rightButtonAlpha
        }
        
        skipButton.setTitle(isLastPage ? skipButtonLastPageText : skipButtonNonLastPageText, forState: .Normal)
    }
    
    /**
        Scroll to a page.
    
        - parameter page: The page.
    */
    private func scrollToPage(page: Int) {
        guard page >= 0 && page < numberOfPages else {
            return
        }
        
        // Scroll view, scroll to proper page
        let pageWidth = CGRectGetWidth(scrollView.frame)
        let rectVisible = CGRectMake(pageWidth * CGFloat(page), 0, pageWidth, CGRectGetHeight(scrollView.frame))
        scrollView.scrollRectToVisible(rectVisible, animated: true)
    }
    
    // MARK: > Helper
    
    /**
        Returns the current page of the given scrollview based on its content offset.
    
        - parameter scrollView: The scroll view.
    */
    private func currentPageOfScrollView(scrollView: UIScrollView) -> Int {
        // consider 50+% of the previous/next page is visible
        let contentOffsetX = scrollView.contentOffset.x
        let pageWidth = CGRectGetWidth(scrollView.frame)
        return Int(floor((contentOffsetX - pageWidth / 2) / pageWidth) + 1)
    }
    
    // @ahl: roll pitch yaw stuff, commented for now.
    
//    struct RollPitchYaw {
//        private var roll: CGFloat
//        private var pitch: CGFloat
//        private var yaw: CGFloat
//        
//        private var rollKalman: KalmanFiltering
//        private var pitchKalman: KalmanFiltering
//        private var yawKalman: KalmanFiltering
//        
//        init() {
//            self.roll = 0
//            self.pitch = 0
//            self.yaw = 0
//            
//            self.rollKalman = KalmanFiltering()
//            self.pitchKalman = KalmanFiltering()
//            self.yawKalman = KalmanFiltering()
//        }
//        
//        mutating func updateWithQuaternion(quaternion: GLKQuaternion) {
//            let gq = orientationPortraitFromQuaternion(quaternion)
//            let x = gq.x
//            let y = gq.y
//            let z = gq.z
//            let w = gq.w
//            
//            // http://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
////            let newRoll = CGFloat(atan2f(2*(gq.x * gq.z + gq.w * gq.y), 1 - 2*(gq.z * gq.z + gq.w * gq.w)))
////            let newPitch = CGFloat(asin(2 * (gq.x * gq.w - gq.y * gq.z)))
////            let newYaw = CGFloat(atan2f(2*(gq.x * gq.y + gq.z * gq.w), 1 - 2*(gq.y * gq.y + gq.z * gq.z)))
//            
////            let newRoll = CGFloat(atan2f(2*(gq.x * gq.z + gq.w * gq.y), 1 - 2*(gq.z * gq.z + gq.w * gq.w)))
////            let newPitch = CGFloat(asin(2 * (gq.x * gq.w - gq.y * gq.z)))
////            let newYaw = CGFloat(atan2f(2*(gq.x * gq.y + gq.z * gq.w), 1 - 2*(gq.y * gq.y + gq.z * gq.z)))
//            
//            let newRoll = CGFloat(atan2(2*y*w - 2*x*z, 1 - 2*y*y - 2*z*z))
//            let newPitch = CGFloat(atan2(2*x*w - 2*y*z, 1 - 2*x*x - 2*z*z))
//            let newYaw =  CGFloat(asin(2*x*y + 2*z*w))
//            
//            roll = rollKalman.newValueWithLastValue(roll, currentValue: newRoll)
//            pitch = pitchKalman.newValueWithLastValue(pitch, currentValue: newPitch)
//            yaw = yawKalman.newValueWithLastValue(yaw, currentValue: newYaw)
//        }
//        
//        private func orientationPortraitFromQuaternion(q: GLKQuaternion) -> GLKQuaternion {
//            let gq1 = GLKQuaternionMakeWithAngleAndAxis(Float(M_PI_2), 0, 1, 0)  // add a rotation of the roll 90 degrees
//            var qp = GLKQuaternionMultiply(gq1, q)
//            let gq3 = GLKQuaternionMakeWithAngleAndAxis(-Float(M_PI_2), 1, 0, 0)  // add a rotation of the pitch 90 degrees
//            qp = GLKQuaternionMultiply(gq3, qp);
//            GLKQuaternionMake(-qp.y, qp.x, qp.z, qp.w)
//            return GLKQuaternionMake(-qp.y, qp.x, qp.z, qp.w);
//        }
//    }
//    
//    struct KalmanFiltering {
//        var q: CGFloat = 0.1   // process noise
//        var r: CGFloat = 0.1   // sensor noise
//        var p: CGFloat = 0.1   // estimated error
//        var k: CGFloat = 0.5   // kalman filter gain
//        
//        mutating func newValueWithLastValue(lastValue: CGFloat, currentValue: CGFloat) -> CGFloat {
//            var x = lastValue
//            p = p + q
//            k = p / (p + r)
//            x = x + k * (currentValue - x)
//            p = (1 - k) * p
//            return x
//        }
//    }
}