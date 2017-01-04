//
//  DirectAnswersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol DirectAnswersPresenterDelegate : class {
    func directAnswersDidTapAnswer(_ presenter: DirectAnswersPresenter, answer: DirectAnswer)
    func directAnswersDidTapClose(_ presenter: DirectAnswersPresenter)
}

class DirectAnswersPresenter : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {

    private static let defaultWidth = UIScreen.main.bounds.width

    weak var delegate: DirectAnswersPresenterDelegate?

    var height: CGFloat {
        if let bigView = bigView {
            return hidden ? 0 : bigView.accurateHeight
        }
        if let _ = collectionView {
            return hidden ? 0 : directAnswersCollectionHeight
        }
        return 0
    }

    var hidden: Bool = true {
        didSet {
            bigView?.setHidden(hidden, animated: true)
            collectionView?.isHidden = hidden
        }
    }

    var enabled: Bool = true {
        didSet {
            bigView?.enabled = enabled
            if enabled {
                collectionView?.deselectAll()
            }
        }
    }

    private let directAnswersCollectionHeight: CGFloat = 48
    private weak var collectionView: UICollectionView?
    private weak var bigView: DirectAnswersBigView?


    private var answers: [DirectAnswer] = []
    private let websocketChatActive: Bool
    private let newDirectAnswers: Bool
    private static let disabledAlpha: CGFloat = 0.6


    // MARK: - Public methods
    
    init(newDirectAnswers: Bool, websocketChatActive: Bool) {
        self.newDirectAnswers = newDirectAnswers
        self.websocketChatActive = websocketChatActive
    }

    func setupOnTopOfView(_ sibling: UIView) {
        if newDirectAnswers {
            let directAnswersView = DirectAnswersBigView()
            directAnswersView.delegate = self
            directAnswersView.enabled = enabled
            directAnswersView.isHidden = hidden
            directAnswersView.setDirectAnswers(answers)
            directAnswersView.setupOnTopOfView(sibling)
            bigView = directAnswersView
        } else {
            buildCollectionAboveView(sibling)
            guard let collectionView = collectionView else { return }
            setupCollection(collectionView)
        }
    }

    func setDirectAnswers(_ answers: [DirectAnswer]) {
        self.answers = answers
        self.bigView?.setDirectAnswers(answers)
        self.collectionView?.reloadData()
    }


    // MARK: - UICollectionViewDelegate & DataSource methods

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if indexPath.row == answers.count {
            return DirectAnswersCloseCell.size()
        } else {
            return DirectAnswerCell.sizeForDirectAnswer(answers[indexPath.row])
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answers.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.row == answers.count {
            //Close btn
            return collectionView.dequeueReusableCell(withReuseIdentifier: DirectAnswersCloseCell.reusableID,
                for: indexPath)
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DirectAnswerCell.reusableID,
                for: indexPath) as? DirectAnswerCell else { return UICollectionViewCell() }

            cell.setupWithDirectAnswer(answers[indexPath.row])

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return enabled
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return enabled
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if websocketChatActive {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        guard enabled else { return }
        if indexPath.row == answers.count {
            delegate?.directAnswersDidTapClose(self)
        } else {
            delegate?.directAnswersDidTapAnswer(self, answer: answers[indexPath.row])
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return enabled
    }


    // MARK: - Private methods

    private func buildCollectionAboveView(_ sibling: UIView) {
        let view = UICollectionView(frame: CGRect(x: 0, y: sibling.top - directAnswersCollectionHeight,
            width: DirectAnswersPresenter.defaultWidth, height: directAnswersCollectionHeight),
            collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        guard let parentView = sibling.superview else { return }
        view.backgroundColor = UIColor.clear
        parentView.insertSubview(view, belowSubview: sibling)
        let bottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.bottom, relatedBy:
            NSLayoutRelation.equal, toItem: sibling, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal,
            toItem: sibling, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal,
            toItem: sibling, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
            toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: directAnswersCollectionHeight)
        view.addConstraint(height)
        parentView.addConstraints([bottom,left,right])

        view.isHidden = hidden
        collectionView = view
    }

    private func setupCollection(_ collectionView: UICollectionView) {
        // CollectionView cells
        let filterNib = UINib(nibName: DirectAnswerCell.reusableID, bundle: nil)
        collectionView.register(filterNib, forCellWithReuseIdentifier: DirectAnswerCell.reusableID)
        
        let closeNib = UINib(nibName: DirectAnswersCloseCell.reusableID, bundle: nil)
        collectionView.register(closeNib, forCellWithReuseIdentifier: DirectAnswersCloseCell.reusableID)

        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
            layout.minimumInteritemSpacing = 4.0
        }

        collectionView.accessibilityId = .DirectAnswersPresenterCollectionView
    }
}


extension DirectAnswersPresenter: DirectAnswersBigViewDelegate {
    func directAnswersBigViewDidSelectAnswer(_ answer: DirectAnswer) {
        delegate?.directAnswersDidTapAnswer(self, answer: answer)
    }
}
