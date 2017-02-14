//
//  DirectAnswersBigView.swift
//  LetGo
//
//  Created by Dídac on 03/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol DirectAnswersBigViewDelegate: class {
    func directAnswersBigViewDidSelectAnswer(_ answer: QuickAnswer)
}

class DirectAnswersBigView: UIView {

    private static let defaultWidth: CGFloat = UIScreen.main.bounds.width
    private static let itemHeight: CGFloat = 45
    private static let itemMargin: CGFloat = 15

    override var isHidden: Bool {
        didSet {
            bottomConstraint?.constant = isHidden ? accurateHeight : 0
        }
    }

    var enabled: Bool = true {
        didSet {
            answerButtons.forEach { $0.isEnabled = enabled }
        }
    }

    var accurateHeight: CGFloat {
        return layeredOut ? height : intrinsicContentSize.height
    }

    weak var delegate: DirectAnswersBigViewDelegate?

    private var titleLabel: UILabel = UILabel()
    private var answerButtons: [UIButton] = []
    private var bottomConstraint: NSLayoutConstraint?
    private var lastItemConstraint: NSLayoutConstraint?

    private var directAnswers: [QuickAnswer] = []
    private var layeredOut = false

    // MARK: - Lifecycle

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize : CGSize {
        let height = DirectAnswersBigView.itemHeight + DirectAnswersBigView.itemHeight*CGFloat(answerButtons.count) +
            DirectAnswersBigView.itemMargin
        return CGSize(width: DirectAnswersBigView.defaultWidth, height: height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layeredOut = true
    }


    // MARK: - Public

    func setupOnTopOfView(_ sibling: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        guard let parentView = sibling.superview else { return }
        parentView.insertSubview(self, belowSubview: sibling)
        layout(with: parentView).fillHorizontal()
        layout(with: sibling).bottom(to: .top, by: isHidden ? accurateHeight : 0,
                                     constraintBlock: { [weak self] in self?.bottomConstraint = $0 })
    }

    func setDirectAnswers(_ directAnswers: [QuickAnswer]) {
        answerButtons.forEach { $0.removeFromSuperview() }
        answerButtons.removeAll()
        if let lastItemConstraint = lastItemConstraint {
            removeConstraint(lastItemConstraint)
            self.lastItemConstraint = nil
        }

        self.directAnswers = directAnswers

        var previousItem: UIView = titleLabel
        for (index, answer) in directAnswers.enumerated() {
            let button = buildAnswerButton(answer)
            button.tag = index
            addSubview(button)
            button.layout(with: self).fillHorizontal(by: DirectAnswersBigView.itemMargin)
            button.layout(with: previousItem).top(to: .bottom)
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)

            previousItem = button
        }
        previousItem.layout(with: self).bottom(by: -DirectAnswersBigView.itemMargin,
                                               constraintBlock: { [weak self] in self?.lastItemConstraint = $0 })
    }

    func setHidden(_ hidden: Bool, animated: Bool) {
        self.isHidden = hidden
        if animated {
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.superview?.layoutIfNeeded()
            }) 
        }
    }


    // MARK: - Private

    private func setupUI() {
        backgroundColor = UIColor.white

        titleLabel.text = LGLocalizedString.directAnswerTitle
        titleLabel.font = UIFont.systemRegularFont(size: 13)
        titleLabel.textColor = UIColor.grayDark
        titleLabel.textAlignment  = .center

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        titleLabel.layout(with: self).top()
        titleLabel.layout().height(DirectAnswersBigView.itemHeight)
        titleLabel.layout(with: self).fillHorizontal(by: DirectAnswersBigView.itemMargin)

        addTopViewBorderWith(width: LGUIKitConstants.onePixelSize, color: UIColor.lineGray)
    }

    private func buildAnswerButton(_ answer: QuickAnswer) -> UIButton {
        let width = DirectAnswersBigView.defaultWidth - DirectAnswersBigView.itemMargin*2
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: DirectAnswersBigView.itemHeight))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layout().height(DirectAnswersBigView.itemHeight)
        button.setTitle(answer.text, for: .normal)
        button.setTitleColor(UIColor.primaryColor, for: .normal)
        button.titleLabel?.font = UIFont.systemMediumFont(size: 17)
        button.isEnabled = enabled
        return button
    }

    private dynamic func buttonPressed(_ button: UIButton) {
        guard 0..<directAnswers.count ~= button.tag else { return }
        delegate?.directAnswersBigViewDidSelectAnswer(directAnswers[button.tag])
    }
}
