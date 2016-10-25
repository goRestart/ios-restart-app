//
//  CameraHeaderView.swift
//  LetGo
//
//  Created by Eli Kohen on 24/10/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import FastttCamera

protocol CameraHeaderViewDelegate: class {
    func camereaHeaderViewPressed()
}

class CameraHeaderView: UIView {

    static let viewHeight: CGFloat = 120

    weak var delegate: CameraHeaderViewDelegate?

    private var fastCamera: FastttCamera?

    // MARK: - Lifecycle

    static func setupOnContainer(container: UIView) -> CameraHeaderView {
        let header = CameraHeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(header)
        var views = [String: AnyObject]()
        views["header"] = header
        var metrics = [String: AnyObject]()
        metrics["height"] = CameraHeaderView.viewHeight
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[header]-0-|",
            options: [], metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[header(height)]-0-|",
            options: [], metrics: metrics, views: views))
        return header
    }

    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 200, height: UserPushPermissionsHeader.viewHeight))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTap()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        fastCamera?.view.frame = bounds
    }

    // MARK: - Private methods

    private func setupUI() {
        configureCamera()
    }

    func configureCamera() {
        fastCamera?.view.removeFromSuperview()

        fastCamera = FastttCamera()
        guard let fastCamera = fastCamera else { return }

        fastCamera.scalesImage = false
        fastCamera.normalizesImageOrientations = true
        fastCamera.interfaceRotatesWithOrientation = false
        fastCamera.cameraFlashMode = .Off
        fastCamera.cameraDevice = .Rear

        fastCamera.beginAppearanceTransition(true, animated: false)
        addSubview(fastCamera.view)
        fastCamera.endAppearanceTransition()
        fastCamera.view.frame = bounds
        fastCamera.view.userInteractionEnabled = false
    }


    private func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }

    private dynamic func viewTapped() {
        delegate?.camereaHeaderViewPressed()
    }
}
