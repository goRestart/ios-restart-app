//
//  RoundButton.swift
//  LetGo
//
//  Created by Facundo Menzella on 09/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

protocol RoundButtonDelegate: class {
    func roundedButtonActionDidTrigger(_ button: RoundButton)
}

final class RoundButton: UIView {
    private struct Animations {
        static let damping: CGFloat = 0.4
        static let scale: CGFloat = 0.7
        static let duration: TimeInterval = 0.3
        static let initialSpringVelocity: CGFloat = 6.0
    }

    private let ovalLayer = OvalLayer()
    override var intrinsicContentSize: CGSize { return CGSize(width: 32, height: 32) }
    weak var delegate: RoundButtonDelegate?

    convenience init() {
        self.init(frame: CGRect.zero)
        setup()
    }

    private func setup() {
        layer.addSublayer(ovalLayer)
        ovalLayer.frame = self.bounds
        ovalLayer.shadowColor = UIColor.black.cgColor
        ovalLayer.shadowRadius = 8
        ovalLayer.shadowOpacity = 0.3

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        let press = UILongPressGestureRecognizer(target: self, action: #selector(didPress))

        addGestureRecognizer(tap)
        addGestureRecognizer(press)
    }

    func expand() {
        self.ovalLayer.expand()
    }

    func compress() {
        self.ovalLayer.compress()
        self.ovalLayer.setNeedsDisplay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ovalLayer.frame = self.bounds
    }

    @objc private func didPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            scaleDown(animated: true)
        case .cancelled:
            scaleUp()
        case .ended:
            scaleUp()
        default:
            return
        }
    }

    @objc private func didTap(_ sender: UITapGestureRecognizer) {
        scaleDown(animated: false)
        scaleUp() { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.roundedButtonActionDidTrigger(strongSelf)
        }
    }

    private func scaleUp() {
        scaleUp(withCompletionBlock: nil)
    }

    private func scaleUp(withCompletionBlock completion: (()->())?) {
        UIView.animate(withDuration: Animations.duration,
                       delay: 0,
                       usingSpringWithDamping: Animations.damping,
                       initialSpringVelocity: Animations.initialSpringVelocity,
                       options: .allowUserInteraction,
                       animations: { [weak self] in
                        self?.transform = .identity
            },
                       completion: { _ in
                        completion?()
        })
    }

    private func scaleDown(animated: Bool) {
        guard animated else {
            self.transform = CGAffineTransform(scaleX: Animations.scale, y: Animations.scale)
            return
        }
        UIView.animate(withDuration: Animations.duration, animations: {
            self.transform = CGAffineTransform(scaleX: Animations.scale, y: Animations.scale)
        })
    }
}
