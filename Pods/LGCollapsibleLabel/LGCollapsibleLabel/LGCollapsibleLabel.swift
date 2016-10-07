//
//  LGCollapsibleLabel.swift
//  LetGo
//
//  Created by Eli Kohen on 03/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

public class LGCollapsibleLabel: UIView {

    // Our custom view from the XIB file
    var view: UIView!

    // Outlets
    @IBOutlet public internal(set) weak var textView: UITextView!
    @IBOutlet var labelHeight: NSLayoutConstraint!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var gradientHeight: NSLayoutConstraint!
    @IBOutlet weak var expandContainer: UIView!
    @IBOutlet weak var expandContainerHeight: NSLayoutConstraint!
    @IBOutlet public internal(set) weak var expandLabel: UILabel!
    @IBOutlet public internal(set) weak var arrowIcon: UIImageView!


    /**
     Collapsed state. Changing this value will trigger the visual change too.
     */
    public var collapsed : Bool = true {
        didSet {
            guard let _ = labelHeight else { return }
            updateState()
        }
    }

    /**
     Collapsed size. Height of label in collapsed state (just label, the expand container will add 24points to this height when collapsed
     */
    public var collapsedSize: CGFloat = 80 {
        didSet {
            guard let _ = labelHeight where collapsed else { return }
            updateState()
        }
    }

    /**
     Collapsed Threshold. Will be used to check if expansion functionality is required. If total height of text is less than collapsedSize+collapseThresold
     the text will be expanded and there won't be option to expand/collapse.
     */
    public var collapseThreshold: CGFloat = 40 {
        didSet {
            guard let _ = expandContainer where totalHeight < CGFloat.max else { return }
            checkMinHeight()
        }
    }

    /**
     Text color.
     */
    public var textColor: UIColor = UIColor.whiteColor() {
        didSet {
            guard let _ = textView else { return }
            textView.textColor = textColor
        }
    }

    /**
     Color of the gradient that will 'blur' the last line of text when collapsed. TIP: Set it to the same color of background
     */
    public var gradientColor: UIColor = UIColor.whiteColor() {
        didSet {
            guard let _ = gradientView else { return }
            setupGradient()
        }
    }

    /**
     Label text
     */
    public var mainText: String = "" {
        didSet {
            guard let _ = textView else { return }
            textView.text = mainText
        }
    }

    public var expandTextColor: UIColor = UIColor.blackColor() {
        didSet {
            guard let _ = expandLabel else { return }
            setupExpandLabel()
        }
    }

    /**
     Text of button to expand when state == collapsed
     */
    public var expandText: String = "Expand" {
        didSet {
            guard let _ = expandLabel else { return }
            setupExpandLabel()
        }
    }

    /**
     Text of button to collapse when state == expanded
     */
    public var collapseText: String = "Collapse" {
        didSet {
            guard let _ = expandLabel else { return }
            setupExpandLabel()
        }
    }

    private var totalHeight : CGFloat = CGFloat.max
    private var expansionEnabled : Bool {
        get {
            guard totalHeight != CGFloat.max else { return false }
            return totalHeight > (collapsedSize + collapseThreshold)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        xibSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        xibSetup()
    }

    /**
     Will toggle the state. LGCollapsibleLabel doesn't respond to tap events so this must be done in parent.
     Also if you want to animate the effect do it inside an animation block:

     UIView.animateWithDuration(0.5) {
     self.collapsibleLabel.toggleState()
     self.view.layoutIfNeeded()
     }

     */
    public func toggleState() {
        collapsed = !collapsed
    }


    func xibSetup() {

        if view != nil {
            //Alrady initialized
            return
        }

        view = loadViewFromNib()

        // use bounds not frame or it'll be offset
        view.frame = bounds

        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]

        // Adding custom subview on top of our view
        addSubview(view)

        //Main text
        textView.text = mainText
        textView.textColor = textColor

        setupGradient()

        updateState()
    }

    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: LGCollapsibleLabel.self)
        if let url = bundle.URLForResource("LGCollapsibleLabelBundle", withExtension: "bundle") {
            return NSBundle(URL: url)!.loadNibNamed("LGCollapsibleLabel", owner: self, options: nil)!.first as! UIView
        }
        else{
            return bundle.loadNibNamed("LGCollapsibleLabel", owner: self, options: nil)!.first as! UIView
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        self.totalHeight = heightOfText()
        checkMinHeight()
    }

    private func heightOfText() -> CGFloat {
        guard !self.mainText.isEmpty else {
            return 0.0
        }

        let aTextView = UITextView(frame: self.bounds)
        aTextView.font = self.textView.font
        aTextView.text = self.mainText
        let sizeThatFits = aTextView.sizeThatFits(CGSizeMake(aTextView.frame.size.width, CGFloat.max))
        return sizeThatFits.height
    }

    private func checkMinHeight() {
        if(!expansionEnabled) {
            //Hiding elements to expand
            self.gradientView.hidden = true
            self.expandContainer.hidden = true
            self.expandContainerHeight.constant = 0.0

            //Setting it statically expanded
            labelHeight.constant = totalHeight
            self.gradientView.alpha = 0.0
        }
        else {
            //Show elements
            self.gradientView.hidden = false
            self.expandContainer.hidden = false
            self.expandContainerHeight.constant = 24.0

            updateState()
        }
    }

    private func updateState() {

        if(!expansionEnabled){
            return
        }

        setupExpandLabel()

        if collapsed {
            labelHeight.constant = collapsedSize
            self.gradientView.alpha = 1.0
        }
        else {
            labelHeight.constant = totalHeight
            self.gradientView.alpha = 0.0
        }
    }

    private func setupGradient() {
        //Clearing
        self.gradientView.layer.sublayers?.removeAll()

        //Adding gradient
        let background = CAGradientLayer.gradientWithColor(gradientColor)
        background.frame = self.gradientView.bounds
        self.gradientView.layer.insertSublayer(background, atIndex: 0)
    }

    private func setupExpandLabel() {
        expandLabel.text = collapsed ? expandText : collapseText
        expandLabel.textColor = expandTextColor
        setupArrow()
    }

    private func setupArrow() {
        let up = UIImage(named: "arrow_up", inBundle: NSBundle.LGCollapsibleLabelBundle(),
            compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)

        let down = UIImage(named: "arrow_down", inBundle: NSBundle.LGCollapsibleLabelBundle(),
            compatibleWithTraitCollection: nil)?.imageWithRenderingMode(.AlwaysTemplate)

        arrowIcon.tintColor = expandTextColor
        arrowIcon.image = collapsed ? down : up
    }
}

extension CAGradientLayer {

    static func gradientWithColor(mainColor: UIColor) -> CAGradientLayer {
        let topColor = mainColor.colorWithAlphaComponent(0.0)

        let gradientColors: Array <AnyObject> = [topColor.CGColor, mainColor.CGColor]

        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = [0.0,0.8,1.0]

        return gradientLayer
    }
}

extension NSBundle {
    internal static func LGCollapsibleLabelBundle() -> NSBundle {
        let frameworkBundle = NSBundle(forClass: LGCollapsibleLabel.self)
        let lgCoreKitBundleURL = frameworkBundle.URLForResource("LGCollapsibleLabelBundle", withExtension: "bundle")!
        return NSBundle(URL: lgCoreKitBundleURL)!
    }
}

