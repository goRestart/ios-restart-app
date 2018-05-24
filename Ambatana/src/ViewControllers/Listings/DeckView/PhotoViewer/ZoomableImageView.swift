//
//  ZoomableImageView.swift
//  LetGo
//
//  Created by Facundo Menzella on 09/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

fileprivate struct Zoom {
    let minimumScale: CGFloat
    let maximumScale: CGFloat
    let zoomScale: CGFloat
    let referenceZoomLevel: CGFloat

    static func makeDefault() -> Zoom {
        return Zoom(scale: 1)
    }

    private init(scale: CGFloat) {
        self.minimumScale = 1
        self.maximumScale = 1
        self.zoomScale = 1
        self.referenceZoomLevel = 1
    }

    init(withImage image: UIImage, screenAspectRatio: CGFloat) {
        let imgAspectRatio = image.size.width / image.size.height

        let zoomLevel = screenAspectRatio / imgAspectRatio
        let actualZoomLevel = imgAspectRatio >= LGUIKitConstants.horizontalImageMinAspectRatio ? zoomLevel : 1.0

        referenceZoomLevel = actualZoomLevel
        zoomScale = actualZoomLevel
        minimumScale = min(1, actualZoomLevel)
        maximumScale = 2.0
    }
}

final class ZoomableImageView: UIView, UIScrollViewDelegate {
    var isZooming: Bool { return scrollView.zoomScale != referenceZoomLevel }

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()

    private var zoom = Zoom.makeDefault()
    private var referenceZoomLevel: CGFloat { return zoom.referenceZoomLevel }

    init() {
        super.init(frame: .zero)
        setupScrollView()
        setupPreview()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setImage(_ image: UIImage?) {
        guard let zoomableImage = image else {
            imageView.image = nil
            return
        }
        let zoom = Zoom(withImage: zoomableImage, screenAspectRatio: UIScreen.main.aspectRatio)

        scrollView.updateWithZoom(zoom)
        scrollView.contentSize = imageView.bounds.size

        imageView.bounds = CGRect(x: 0, y: 0, width: bounds.width / zoom.referenceZoomLevel, height: bounds.height)
        imageView.center = scrollView.center
        imageView.alpha = 1
        imageView.image = zoomableImage
        self.zoom = zoom
        scrollView.isScrollEnabled = false
    }

    func resetZoom(_ animated: Bool = false) {
        scrollView.isScrollEnabled = false
        let duration: TimeInterval = animated ? 0.5 : 0

        let referenceLevel = referenceZoomLevel
        UIView.animate(withDuration: duration) { [weak self] in
            self?.scrollView.zoomScale = referenceLevel
        }
    }
    
    private func setupScrollView() {
        scrollView.isScrollEnabled = false
        addSubviewForAutoLayout(scrollView)
        scrollView.layout(with: self).fill()
        scrollView.delegate = self

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
    }

    private func setupPreview() {
        scrollView.addSubview(imageView)
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.isUserInteractionEnabled = true
    }

    private func updateImageViewCenter() {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)

        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                                   y: scrollView.contentSize.height * 0.5 + offsetY)
    }

    private func updateImageBounds() {
        guard !isZooming else { return }
        imageView.bounds = CGRect(x: 0,
                                  y: 0,
                                  width: bounds.width / referenceZoomLevel,
                                  height: bounds.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateImageBounds()
    }

    // MARK: UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateImageViewCenter()
        let zooming = scrollView.zoomScale != zoom.referenceZoomLevel
        scrollView.isScrollEnabled = zooming
    }
}

fileprivate extension UIScrollView {
    func updateWithZoom(_ zoom: Zoom) {
        maximumZoomScale = zoom.maximumScale
        minimumZoomScale = min(1, zoom.referenceZoomLevel)
        setZoomScale(zoom.zoomScale, animated: false)
    }
}

fileprivate extension UIScreen {
    var aspectRatio: CGFloat { return UIScreen.main.bounds.width / UIScreen.main.bounds.height }
}
