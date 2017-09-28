//
//  PillPageControl.swift
//  PageControls
//
//  Created by Kyle Zaragoza on 8/8/16.
//  Copyright © 2016 Kyle Zaragoza. All rights reserved.
//
//  https://cocoapods.org/pods/PageControls - https://github.com/popwarsweet/PageControls
//

import UIKit

class PillPageControl: UIView {


    // MARK: - PageControl

    var pageCount: Int = 0 {
        didSet {
            updateNumberOfPages(pageCount)
        }
    }
    var progress: CGFloat = 0 {
        didSet {
            layoutActivePageIndicator(progress)
        }
    }
    var currentPage: Int {
        return Int(round(progress))
    }


    // MARK: - Appearance

    var pillSize: CGSize = CGSize(width: 20, height: 2) {
        didSet {
            layoutInactivePageIndicators(inactiveLayers)
            layoutActivePageIndicator(progress)
        }
    }
    var activeTint: UIColor = UIColor.whiteTextHighAlpha {
        didSet {
            activeLayer.backgroundColor = activeTint.cgColor
        }
    }
    var inactiveTint: UIColor = UIColor.whiteTextLowAlpha {
        didSet {
            inactiveLayers.forEach() { $0.backgroundColor = inactiveTint.cgColor }
        }
    }
    var indicatorPadding: CGFloat = 5 {
        didSet {
            layoutInactivePageIndicators(inactiveLayers)
        }
    }

    fileprivate var inactiveLayers = [CALayer]()

    fileprivate lazy var activeLayer: CALayer = { [unowned self] in
        let layer = CALayer()
        layer.frame = CGRect(origin: CGPoint.zero,
                             size: CGSize(width: self.pillSize.width, height: self.pillSize.height))
        layer.backgroundColor = self.activeTint.cgColor
        layer.cornerRadius = self.pillSize.height/2
        layer.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "position": NSNull()]
        return layer
        }()


    // MARK: - State Update

    fileprivate func updateNumberOfPages(_ count: Int) {
        // no need to update
        guard count != inactiveLayers.count else { return }
        // reset current layout
        inactiveLayers.forEach() { $0.removeFromSuperlayer() }
        inactiveLayers = [CALayer]()
        // add layers for new page count
        inactiveLayers = stride(from: 0, to:count, by:1).map() { _ in
            let layer = CALayer()
            layer.backgroundColor = self.inactiveTint.cgColor
            self.layer.addSublayer(layer)
            return layer
        }
        layoutInactivePageIndicators(inactiveLayers)
        // ensure active page indicator is on top
        self.layer.addSublayer(activeLayer)
        layoutActivePageIndicator(progress)
        self.invalidateIntrinsicContentSize()
    }


    // MARK: - Layout

    fileprivate func layoutActivePageIndicator(_ progress: CGFloat) {
        // ignore if progress is outside of page indicators' bounds
        guard progress >= 0 && progress <= CGFloat(pageCount - 1) else { return }
        let denormalizedProgress = progress * (pillSize.width + indicatorPadding)
        activeLayer.frame = CGRect(origin: CGPoint(x: denormalizedProgress, y: 0),
                                   size: CGSize(width: pillSize.width, height: pillSize.height))
    }

    fileprivate func layoutInactivePageIndicators(_ layers: [CALayer]) {
        var layerFrame = CGRect(origin: CGPoint.zero, size: pillSize)
        layers.forEach() { layer in
            layer.cornerRadius = layerFrame.size.height / 2
            layer.frame = layerFrame
            layerFrame.origin.x += layerFrame.width + indicatorPadding
        }
    }

    override open var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: CGFloat(inactiveLayers.count) * pillSize.width + CGFloat(inactiveLayers.count - 1) * indicatorPadding,
                      height: pillSize.height)
    }
}
