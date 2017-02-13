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
        if let bigView = bigView {
            return hidden ? 0 : bigView.accurateHeight
        }
        if let horizontalView = horizontalView {
            return hidden ? 0 : horizontalView.intrinsicContentSize.height
        }
        return 0
    }

    var hidden: Bool = true {
        didSet {
            bigView?.setHidden(hidden, animated: true)
            horizontalView?.isHidden = hidden
        }
    }

    var enabled: Bool = true {
        didSet {
            bigView?.enabled = enabled
            horizontalView?.answersEnabled = enabled
        }
    }
    private weak var bigView: DirectAnswersBigView?
    private weak var horizontalView: DirectAnswersHorizontalView?

    private var answers: [QuickAnswer] = []
    private let websocketChatActive: Bool
    private let newDirectAnswers: Bool
    private static let disabledAlpha: CGFloat = 0.6


    // MARK: - Public methods
    
    init(newDirectAnswers: Bool, websocketChatActive: Bool) {
        self.newDirectAnswers = newDirectAnswers
        self.websocketChatActive = websocketChatActive
    }

    func setupOnTopOfView(_ sibling: UIView) {
        guard let parentView = sibling.superview else { return }
        if newDirectAnswers {
            let directAnswersView = DirectAnswersBigView()
            directAnswersView.delegate = self
            directAnswersView.enabled = enabled
            directAnswersView.isHidden = hidden
            directAnswersView.setDirectAnswers(answers)
            directAnswersView.setupOnTopOfView(sibling)
            bigView = directAnswersView
        } else {
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
            directAnswers.layout(with: sibling).bottom(to: .top)
            horizontalView = directAnswers
        }
    }

    func setDirectAnswers(_ answers: [QuickAnswer]) {
        self.answers = answers
        self.bigView?.setDirectAnswers(answers)
        self.horizontalView?.update(answers: answers)
    }
}


extension DirectAnswersPresenter: DirectAnswersBigViewDelegate {
    func directAnswersBigViewDidSelectAnswer(_ answer: QuickAnswer) {
        delegate?.directAnswersDidTapAnswer(self, answer: answer)
    }
}

extension DirectAnswersPresenter: DirectAnswersHorizontalViewDelegate {
    func directAnswersBigViewDidSelect(answer: QuickAnswer) {
        delegate?.directAnswersDidTapAnswer(self, answer: answer)
    }

    func directAnswersBigViewDidSelectClose() {
        delegate?.directAnswersDidTapClose(self)
    }
}
