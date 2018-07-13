import UIKit
import LGComponents

final class Tooltip: UIView {

    static var peakViewCenterDistance: CGFloat = 8

    var coloredView: UIView = UIView()
    var titleLabel: UILabel = UILabel()
    var closeButton: UIButton = UIButton()
    var separationView: UIView = UIView()
    var downTooltipPeak: UIImageView = UIImageView()
    var upTooltipPeak: UIImageView = UIImageView()

    var targetView: UIView = UIView()
    var targetGlobalCenter: CGPoint = CGPoint.zero
    var superView: UIView = UIView()
    var button: UIButton?
    var title: NSAttributedString = NSAttributedString()
    var style: TooltipStyle = .black(closeEnabled: true)
    var actionBlock: ()->() = {}
    var closeBlock: (()->())?

    var peakOffset: CGFloat = 0.0 {
        didSet {
            setupConstraintsForPeakOnBottom()
            setupConstraintsForPeakOnTop()
        }
    }

    var superViewWidth: CGFloat {
        return superView.width
    }

    var peakOnTop: Bool = false
    
    var targetViewCenter: CGPoint = .zero


    // MARK: Lifecycle

    /**
     Initializes a tooltip
     
     - parameter targetView: the view that will have the related tooltip
     - parameter superView: the view where the tooltip will be added
     - parameter title: text of the tooltip
     - parameter style: style of the tooltip (Black or Blue)
     - parameter peakOnTop: true if the peak of the tooltip should go over it (tooltip will be shown UNDER targetView)
     - parameter actionBlock: the action executed when the text is tapped
     */

    convenience init(targetView: UIView,
                     superView: UIView,
                     title: NSAttributedString,
                     style: TooltipStyle,
                     peakOnTop: Bool,
                     button: UIButton? = nil,
                     actionBlock: @escaping () -> (),
                     closeBlock: (() -> ())?) {
        self.init()
        self.button = button
        self.title = title
        self.targetView = targetView
        self.targetGlobalCenter = superView.convert(targetView.center, to: nil)
        self.superView = superView
        self.style = style
        self.peakOnTop = peakOnTop
        self.actionBlock = actionBlock
        self.closeBlock = closeBlock

        setupUI()
    }
    
    convenience init(targetView: UIView,
                     superView: UIView,
                     button: UIButton? = nil,
                     configuration: TooltipConfiguration) {
        self.init(targetView: targetView,
                  superView: superView,
                  title: configuration.title,
                  style: configuration.style,
                  peakOnTop: configuration.peakOnTop,
                  button: button,
                  actionBlock: configuration.actionBlock,
                  closeBlock: configuration.closeBlock)
    }

    override init(frame: CGRect)  {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let targerCenterPoint = targetViewCenter != .zero ? targetViewCenter : superView.convert(targetView.center, to: nil)
        targetGlobalCenter = targerCenterPoint
        peakOffset = peakFinalOffset()
    }

    
    // MARK: private methods

    private func setupUI() {

        translatesAutoresizingMaskIntoConstraints = false

        coloredView.cornerRadius = LGUIKitConstants.mediumCornerRadius
        coloredView.backgroundColor = style.bgColor

        titleLabel.attributedText = title
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let tapTitle = UITapGestureRecognizer(target: self, action: #selector(titleTapped))
        titleLabel.addGestureRecognizer(tapTitle)
        coloredView.addSubviewForAutoLayout(titleLabel)

        if style.closeEnabled {
            separationView.frame = CGRect(x: 0, y: 0, width: 2, height: 28)
            separationView.backgroundColor = .white

            closeButton.setImage(R.Asset.IconsButtons.icClose.image, for: .normal)
            closeButton.addTarget(self, action: #selector(closeTooltip), for: .touchUpInside)
            coloredView.addSubviewsForAutoLayout([separationView, closeButton])
        }

        addSubviewsForAutoLayout([coloredView, upTooltipPeak, downTooltipPeak])
        setupPeak()
        
        if let button = button {
            coloredView.addSubviewForAutoLayout(button)
        }

        setupConstraints()
    }

    private func setupConstraints() {

        // self
        let mainWidth = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .lessThanOrEqual,
                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 270)
        mainWidth.priority = .required - 1
        let mainMinWidth = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .greaterThanOrEqual,
                                           toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: style.minWidth)
        mainMinWidth.priority = .required - 1

        let mainHeight = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual,
                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70)
        mainHeight.priority = .required - 1
        NSLayoutConstraint.activate([mainWidth, mainMinWidth, mainHeight])

        // colored view
        NSLayoutConstraint.activate([NSLayoutConstraint(item: coloredView, attribute: .top, relatedBy: .equal,
                                                        toItem: self, attribute: .top, multiplier: 1, constant: 10),
                                     NSLayoutConstraint(item: coloredView, attribute: .bottom, relatedBy: .equal,
                                                        toItem: self, attribute: .bottom, multiplier: 1, constant: -10),
                                     NSLayoutConstraint(item: coloredView, attribute: .left, relatedBy: .equal,
                                                        toItem: self, attribute: .left, multiplier: 1, constant: 0),
                                     NSLayoutConstraint(item: coloredView, attribute: .right, relatedBy: .equal,
                                                        toItem: self, attribute: .right, multiplier: 1, constant: 0)])

        // title label
        let labelTop = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal,
                                          toItem: coloredView, attribute: .top, multiplier: 1, constant: Metrics.shortMargin)
        let labelBottom: NSLayoutConstraint
        let labelRight: NSLayoutConstraint
        let labelLeft = NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal,
                                           toItem: coloredView, attribute: .left, multiplier: 1, constant: Metrics.margin)
        
        if let button = button {
            labelBottom = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: button,
                                             attribute: .top, multiplier: 1, constant: -Metrics.shortMargin)
            NSLayoutConstraint.activate([NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: coloredView,
                                                         attribute: .bottom, multiplier: 1, constant: -Metrics.margin),
                                        NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: coloredView,
                                                           attribute: .centerX, multiplier: 1, constant: 0)])
        } else {
            labelBottom = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: coloredView,
                                             attribute: .bottom, multiplier: 1, constant: -Metrics.shortMargin)
        }
        
        if style.closeEnabled {
            labelRight = NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal,
                                            toItem: separationView, attribute: .left, multiplier: 1, constant: -12)
            
            NSLayoutConstraint.activate([NSLayoutConstraint(item: separationView, attribute: .height, relatedBy: .equal,
                                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28),
                                         NSLayoutConstraint(item: separationView, attribute: .width, relatedBy: .equal,
                                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1),
                                         
                                         NSLayoutConstraint(item: separationView, attribute: .right, relatedBy: .equal,
                                                            toItem: closeButton, attribute: .left, multiplier: 1, constant: 0),
                                         NSLayoutConstraint(item: separationView, attribute: .centerY, relatedBy: .equal,
                                                            toItem: coloredView, attribute: .centerY, multiplier: 1, constant: 0),
                                         
                                         NSLayoutConstraint(item: closeButton, attribute: .height, relatedBy: .equal,
                                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50),
                                         NSLayoutConstraint(item: closeButton, attribute: .width, relatedBy: .equal,
                                                            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50),
                                         
                                         NSLayoutConstraint(item: closeButton, attribute: .right, relatedBy: .equal,
                                                            toItem: coloredView, attribute: .right, multiplier: 1, constant: -8),
                                         NSLayoutConstraint(item: closeButton, attribute: .centerY, relatedBy: .equal,
                                                            toItem: coloredView, attribute: .centerY, multiplier: 1, constant: 0)
                                         ])
        } else {
            labelRight = NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal,
                                                toItem: coloredView, attribute: .right, multiplier: 1, constant: -12)
        }
        NSLayoutConstraint.activate([labelTop, labelBottom, labelLeft, labelRight])
    }

    private func setupConstraintsForPeakOnTop() {
        let width = NSLayoutConstraint(item: upTooltipPeak, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15)
        let top = NSLayoutConstraint(item: upTooltipPeak, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: upTooltipPeak, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: peakOffset)
        let bottom = NSLayoutConstraint(item: upTooltipPeak, attribute: .bottom, relatedBy: .equal, toItem: coloredView, attribute: .top, multiplier: 1, constant: 0)

        NSLayoutConstraint.activate([top, centerX, bottom, width])
    }

    private func setupConstraintsForPeakOnBottom() {
        let width = NSLayoutConstraint(item: downTooltipPeak, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15)
        let top = NSLayoutConstraint(item: downTooltipPeak, attribute: .top, relatedBy: .equal, toItem: coloredView, attribute: .bottom, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: downTooltipPeak, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: peakOffset)
        let bottom = NSLayoutConstraint(item: downTooltipPeak, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)

        NSLayoutConstraint.activate([top, centerX, bottom, width])
    }

    private func setupPeak() {
        downTooltipPeak.isHidden = peakOnTop   // target view is too up, peak goes up
        upTooltipPeak.isHidden = !peakOnTop  // peak goes down
        
        // Screen divided in 3 parts to decide what kind of peak must be shown
        if targetGlobalCenter.x < superViewWidth/3 {
            // target view is on the left
            downTooltipPeak.image = style.leftSidePeak
            upTooltipPeak.image = style.leftSidePeak?.rotatedImage().rotatedImage().withRenderingMode(.alwaysTemplate)
        } else if targetGlobalCenter.x > (superViewWidth/3)*2 {
            // target view is on the right
            downTooltipPeak.image = style.rightSidePeak
            upTooltipPeak.image = style.rightSidePeak?.rotatedImage().rotatedImage().withRenderingMode(.alwaysTemplate)
        } else {
            // target view is on the center
            downTooltipPeak.image = style.centeredPeak
            upTooltipPeak.image = style.centeredPeak?.rotatedImage().rotatedImage().withRenderingMode(.alwaysTemplate)
        }
        
        downTooltipPeak.tintColor = style.bgColor
        upTooltipPeak.tintColor = style.bgColor

    }

    @objc func titleTapped() {
        actionBlock()
        removeFromSuperview()
    }

    @objc func closeTooltip() {
        closeBlock?()
        removeFromSuperview()
    }

    private func peakFinalOffset() -> CGFloat {
        let tmpPeakOffset = -(frame.origin.x+width/2-targetGlobalCenter.x)
        let maxOffset =  width/2-LGUIKitConstants.mediumCornerRadius-Tooltip.peakViewCenterDistance
        let minOffset =  -(width/2-LGUIKitConstants.mediumCornerRadius-Tooltip.peakViewCenterDistance)
        return max(min(tmpPeakOffset,maxOffset), minOffset)
    }
}


// MARK: global methods related to Tooltip

/**
 Positions the tooltip inside its superview

 - parameter tooltip: the tooltip where to apply the constraints
 - parameter targetView: the view that will have the related tooltip
 - parameter containerView: the view where the tooltip will be added
 */

func setupExternalConstraintsForTooltip(_ tooltip: Tooltip, targetView: UIView, containerView: UIView,
                                        margin: CGFloat = 0) {

    let targetGlobalCenter = containerView.convert(targetView.center, to: nil)
    
    let tooltipLeadingAnchor = tooltip.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 40)
    let tooltipTrailingAnchor =  tooltip.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -40)

    let peakAligment: NSLayoutConstraint
    if tooltip.peakOnTop {
        peakAligment = tooltip.topAnchor.constraint(equalTo: targetView.bottomAnchor, constant: margin)
        containerView.addConstraint(NSLayoutConstraint(item: tooltip, attribute: .top, relatedBy: .equal,
            toItem: targetView, attribute: .bottom, multiplier: 1, constant: margin))
    } else {
        peakAligment = tooltip.bottomAnchor.constraint(equalTo: targetView.topAnchor, constant: -margin)
    }

    let alignmentConstraint: NSLayoutConstraint

    if targetGlobalCenter.x < containerView.width/3 {
        alignmentConstraint = tooltip.leadingAnchor.constraint(equalTo: targetView.leadingAnchor)
    } else if targetGlobalCenter.x > (containerView.width/3)*2 {
        alignmentConstraint = tooltip.trailingAnchor.constraint(equalTo: targetView.trailingAnchor)
    } else {
        alignmentConstraint = tooltip.centerXAnchor.constraint(equalTo: targetView.centerXAnchor)
    }
    NSLayoutConstraint.activate([peakAligment, alignmentConstraint, tooltipLeadingAnchor, tooltipTrailingAnchor])
}
