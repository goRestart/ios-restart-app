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
            guard let _ = labelHeight, collapsed else { return }
            updateState()
        }
    }

    /**
     Collapsed Threshold. Will be used to check if expansion functionality is required. If total height of text is less than collapsedSize+collapseThresold
     the text will be expanded and there won't be option to expand/collapse.
     */
    public var collapseThreshold: CGFloat = 40 {
        didSet {
            guard let _ = expandContainer, totalHeight < CGFloat.greatestFiniteMagnitude else { return }
            checkMinHeight()
        }
    }

    /**
     Text color.
     */
    public var textColor: UIColor = UIColor.white {
        didSet {
            guard let _ = textView else { return }
            textView.textColor = textColor
        }
    }

    /**
     Color of the gradient that will 'blur' the last line of text when collapsed. TIP: Set it to the same color of background
     */
    public var gradientColor: UIColor = UIColor.white {
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

    public var expandTextColor: UIColor = UIColor.black {
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

    private var totalHeight : CGFloat = CGFloat.greatestFiniteMagnitude
    private var expansionEnabled : Bool {
        get {
            guard totalHeight != CGFloat.greatestFiniteMagnitude else { return false }
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
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        // Adding custom subview on top of our view
        addSubview(view)

        //Main text
        textView.text = mainText
        textView.textColor = textColor

        setupGradient()

        updateState()
    }

    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: LGCollapsibleLabel.self)
        if let url = bundle.url(forResource: "LGCollapsibleLabelBundle", withExtension: "bundle") {
            return Bundle(url: url)!.loadNibNamed("LGCollapsibleLabel", owner: self, options: nil)!.first as! UIView
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
        let sizeThatFits = aTextView.sizeThatFits(CGSize(width: aTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        return sizeThatFits.height
    }

    private func checkMinHeight() {
        if(!expansionEnabled) {
            //Hiding elements to expand
            self.gradientView.isHidden = true
            self.expandContainer.isHidden = true
            self.expandContainerHeight.constant = 0.0

            //Setting it statically expanded
            labelHeight.constant = totalHeight
            self.gradientView.alpha = 0.0
        }
        else {
            //Show elements
            self.gradientView.isHidden = false
            self.expandContainer.isHidden = false
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
        self.gradientView.layer.insertSublayer(background, at: 0)
    }

    private func setupExpandLabel() {
        expandLabel.text = collapsed ? expandText : collapseText
        expandLabel.textColor = expandTextColor
        setupArrow()
    }

    private func setupArrow() {
        let up = UIImage(named: "arrow_up", in: Bundle.LGCollapsibleLabelBundle(),
            compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

        let down = UIImage(named: "arrow_down", in: Bundle.LGCollapsibleLabelBundle(),
            compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

        arrowIcon.tintColor = expandTextColor
        arrowIcon.image = collapsed ? down : up
    }
}

extension CAGradientLayer {

    static func gradientWithColor(_ mainColor: UIColor) -> CAGradientLayer {
        let topColor = mainColor.withAlphaComponent(0.0)

        let gradientColors: Array <AnyObject> = [topColor.cgColor, mainColor.cgColor]

        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = [0.0,0.8,1.0]

        return gradientLayer
    }
}

extension Bundle {
    internal static func LGCollapsibleLabelBundle() -> Bundle {
        let frameworkBundle = Bundle(for: LGCollapsibleLabel.self)
        let lgCoreKitBundleURL = frameworkBundle.url(forResource: "LGCollapsibleLabelBundle", withExtension: "bundle")!
        return Bundle(url: lgCoreKitBundleURL)!
    }
}

