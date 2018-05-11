//
//  DirectAnswersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol DirectAnswersPresenterDelegate: class {
    func directAnswersDidTapAnswer(_ presenter: DirectAnswersPresenter, answer: QuickAnswer)
}

class DirectAnswersPresenter {

    private static let defaultWidth = UIScreen.main.bounds.width

    weak var delegate: DirectAnswersPresenterDelegate?

    var height: CGFloat {
        if hidden { return 0 }
        if let horizontalView = horizontalView {
            let margins: CGFloat = DirectAnswersHorizontalView.Layout.standardSideMargin * 2
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
    weak var horizontalView: DirectAnswersHorizontalView?

    var answers: [QuickAnswer] = []
    private static let disabledAlpha: CGFloat = 0.6

    // MARK: - Public methods

    func setDirectAnswers(_ answers: [QuickAnswer]) {
        self.answers = answers
        horizontalView?.update(answers: answers)
    }
}


extension DirectAnswersPresenter: DirectAnswersHorizontalViewDelegate {
    func directAnswersHorizontalViewDidSelect(answer: QuickAnswer) {
        delegate?.directAnswersDidTapAnswer(self, answer: answer)
    }
}
