//
//  DirectAnswersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol DirectAnswersPresenterDelegate: class {
    func directAnswersDidTapAnswer(_ presenter: DirectAnswersPresenter, answer: QuickAnswer)
    func directAnswersDidTapClose(_ presenter: DirectAnswersPresenter)
}

class DirectAnswersPresenter {

    private static let defaultWidth = UIScreen.main.bounds.width

    weak var delegate: DirectAnswersPresenterDelegate?

    var height: CGFloat {
        if hidden { return 0 }
        if let horizontalView = horizontalView {
            let margins: CGFloat = DirectAnswersHorizontalView.defaultSideMargin * 2
            return horizontalView.intrinsicContentSize.height + margins
        }
        return 0
    }

    var hidden: Bool = true {
        didSet {
            horizontalView?.resetScrollPosition()
            horizontalView?.isHidden = hidden
        }
    }

    var enabled: Bool = true {
        didSet {
            horizontalView?.answersEnabled = enabled
        }
    }
    private weak var horizontalView: DirectAnswersHorizontalView?

    private var answers: [QuickAnswer] = []
    private let websocketChatActive: Bool
    private static let disabledAlpha: CGFloat = 0.6


    // MARK: - Public methods
    
    init(websocketChatActive: Bool) {
        self.websocketChatActive = websocketChatActive
    }

    func setupOnTopOfView(_ sibling: UIView) {
        guard let parentView = sibling.superview else { return }
        let initialFrame = CGRect(x: 0, y: sibling.top - DirectAnswersHorizontalView.defaultHeight,
                                  width: DirectAnswersPresenter.defaultWidth, height: DirectAnswersHorizontalView.defaultHeight)
        let directAnswers = DirectAnswersHorizontalView(frame: initialFrame, answers: answers)
        directAnswers.deselectOnItemTap = websocketChatActive
        directAnswers.delegate = self
        directAnswers.answersEnabled = enabled
        directAnswers.isHidden = hidden
        directAnswers.translatesAutoresizingMaskIntoConstraints = false
        parentView.insertSubview(directAnswers, belowSubview: sibling)
        directAnswers.layout(with: parentView).leading().trailing()
        directAnswers.layout(with: sibling).bottom(to: .top, by: -DirectAnswersHorizontalView.defaultSideMargin)
        horizontalView = directAnswers
    }

    func setDirectAnswers(_ answers: [QuickAnswer]) {
        self.answers = answers
        self.horizontalView?.update(answers: answers)
    }
}


extension DirectAnswersPresenter: DirectAnswersHorizontalViewDelegate {
    func directAnswersHorizontalViewDidSelect(answer: QuickAnswer) {
        delegate?.directAnswersDidTapAnswer(self, answer: answer)
    }

    func directAnswersHorizontalViewDidSelectClose() {
        delegate?.directAnswersDidTapClose(self)
    }
}
