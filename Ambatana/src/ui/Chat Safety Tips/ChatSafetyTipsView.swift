//
//  ChatSafetyTipsView.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

public protocol ChatSafeTipsViewDelegate {
    func chatSafeTipsViewDelegate(chatSafeTipsViewDelegate: ChatSafetyTipsView, didShowPage page: Int)
}

public class ChatSafetyTipsView: UIView, UIScrollViewDelegate {

    // Constants & enums
    private enum ChatSafetyTip {
        case One, Two, Three

        var title: String {
            get {
                switch(self) {
                case .One:
                    return LGLocalizedString.chatSafetyTipsTip1
                case .Two:
                    return LGLocalizedString.chatSafetyTipsTip2
                case .Three:
                    return LGLocalizedString.chatSafetyTipsTip3
                }
            }
        }
        
        static var allValues: [ChatSafetyTip] {
            return [.One, .Two, .Three]
        }
    }
    
    // iVars
    // > UI
    @IBOutlet weak var tipsView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageControlBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    // > Data
    public static var tipsCount: Int {
        return ChatSafetyTip.allValues.count
    }
    public var dismissBlock: (Void -> Void)?
    
    // > Delegate
    public var delegate: ChatSafeTipsViewDelegate?
    
    // MARK: - Lifecycle
    
    public static func chatSafetyTipsView() -> ChatSafetyTipsView? {
        let view = NSBundle.mainBundle().loadNibNamed("ChatSafetyTipsView", owner: self, options: nil).first as? ChatSafetyTipsView
        if let actualView = view {
            actualView.setupUI()
        }
        return view
    }
    
    // MARK: - Public methods
    
    @IBAction func overlayButtonPressed(sender: AnyObject) {
        dismissBlock?()
    }
    
    @IBAction func pageControlPressed(sender: AnyObject) {
        let currentPage = pageControl.currentPage
        setCurrentPage(currentPage, animated: true)
    }
    
    @IBAction func leftButtonPressed(sender: AnyObject) {
        let previousPage = pageControl.currentPage - 1
        setCurrentPage(previousPage, animated: true)
    }
    
    @IBAction func okButtonPressed(sender: AnyObject) {
        dismissBlock?()
    }
    
    @IBAction func rightButtonPressed(sender: AnyObject) {
        let nextPage = pageControl.currentPage + 1
        setCurrentPage(nextPage, animated: true)
    }

    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // Calculate the current page
        let xOffset = scrollView.contentOffset.x
        let floatPage = Float(xOffset / CGRectGetWidth(scrollView.frame))
        let currentPage = Int(roundf(floatPage))

        // Set it
        setCurrentPage(currentPage, animated: true)
    }
    
    // MARK: - Private methods

    /**
        Sets up the UI.
    */
    private func setupUI() {

        // UI
        tipsView.layer.cornerRadius = 4
        okButton.layer.cornerRadius = 4
        
        // i18n
        titleLabel.text = LGLocalizedString.chatSafetyTipsTitle.uppercaseString
        okButton.setTitle(LGLocalizedString.commonOk, forState: .Normal)
        
        // ScrollView setup
        let tipHMargin: CGFloat = 16
        var tipSize = scrollView.frame.size
        tipSize.height = CGRectGetHeight(scrollView.frame) - CGRectGetHeight(pageControl.frame) - pageControlBottomMarginConstraint.constant - 5    // 5: some bottom margin to pageControl
        tipSize.width -= tipHMargin * 2 // substract left & right margins
        
        var tipX: CGFloat = 0
        let tipY: CGFloat = 8
        
        let tips = ChatSafetyTip.allValues
        for tip in tips {

            // Tip label frame, add the left margin
            tipX += tipHMargin
            let tipOrigin = CGPoint(x: tipX, y: tipY)
            let tipFrame = CGRect(origin: tipOrigin, size: tipSize)
            
            // Tip label setup
            let tipLabel = UILabel(frame: tipFrame)
            tipLabel.text = tip.title
            tipLabel.textColor = StyleHelper.tipTextColor
            tipLabel.font = StyleHelper.tipTextFont
            tipLabel.numberOfLines = 0
            tipLabel.textAlignment = .Center
            scrollView.addSubview(tipLabel)
            
            // Next tip x
            tipX = CGRectGetMaxX(tipFrame) + tipHMargin
            
            // Resize the content size
            scrollView.contentSize = CGSize(width: tipX, height: CGRectGetHeight(scrollView.frame))
        }
        
        // Page control setup
        pageControl.numberOfPages = tips.count
        
        // Buttons setup
        leftButton.enabled = false
        rightButton.enabled = 0 < (tips.count - 1)
    }
    
    /**
        Sets the current page, updating the page control & the scroll view.
    
        - parameter page: The page.
        - parameter animated: If the scroll view should be scrolled with animation.
    */
    private func setCurrentPage(page: Int, animated: Bool) {
        // If page is negative or exceeds the tips count then exit
        let tipsCount = ChatSafetyTip.allValues.count
        if page < 0 || page > tipsCount {
            return
        }
        // Set the page control current page
        pageControl.currentPage = page
        
        // Update the buttons status
        leftButton.enabled = page > 0
        rightButton.enabled = page < (tipsCount - 1)
        
        // Move the scroll view to the page rect
        let pageX = CGFloat(page) * CGRectGetWidth(scrollView.frame)
        let pageOrigin = CGPoint(x: pageX, y: 0)
        let rect = CGRect(origin: pageOrigin, size: scrollView.frame.size)
        scrollView.scrollRectToVisible(rect, animated: animated)
        
        // Notify the delegate
        delegate?.chatSafeTipsViewDelegate(self, didShowPage: page)
    }
}
