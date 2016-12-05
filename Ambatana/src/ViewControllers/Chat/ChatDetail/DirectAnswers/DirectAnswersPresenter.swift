//
//  DirectAnswersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol DirectAnswersPresenterDelegate : class {
    func directAnswersDidTapAnswer(presenter: DirectAnswersPresenter, answer: DirectAnswer)
    func directAnswersDidTapClose(presenter: DirectAnswersPresenter)
}

class DirectAnswersPresenter : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {

    private static let defaultWidth = UIScreen.mainScreen().bounds.width

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

    var hidden: Bool = false {
        didSet {
            bigView?.hidden = hidden
            collectionView?.hidden = hidden
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

    func setupOnTopOfView(sibling: UIView) {
        if newDirectAnswers {
            let directAnswersView = DirectAnswersBigView()
            directAnswersView.delegate = self
            directAnswersView.enabled = enabled
            directAnswersView.hidden = hidden
            directAnswersView.setDirectAnswers(answers)
            directAnswersView.setupOnTopOfView(sibling)
            bigView = directAnswersView
        } else {
            buildCollectionOverView(sibling)
            guard let collectionView = collectionView else { return }
            setupCollection(collectionView)
        }
    }

    func setDirectAnswers(answers: [DirectAnswer]) {
        self.answers = answers
        self.bigView?.setDirectAnswers(answers)
        self.collectionView?.reloadData()
    }


    // MARK: - UICollectionViewDelegate & DataSource methods

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.row == answers.count {
            return DirectAnswersCloseCell.size()
        } else {
            return DirectAnswerCell.sizeForDirectAnswer(answers[indexPath.row])
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answers.count + 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        if indexPath.row == answers.count {
            //Close btn
            return collectionView.dequeueReusableCellWithReuseIdentifier(DirectAnswersCloseCell.reusableID,
                forIndexPath: indexPath)
        } else {
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DirectAnswerCell.reusableID,
                forIndexPath: indexPath) as? DirectAnswerCell else { return UICollectionViewCell() }

            cell.setupWithDirectAnswer(answers[indexPath.row])

            return cell
        }
    }

    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return enabled
    }

    func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return enabled
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if websocketChatActive {
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        }
        guard enabled else { return }
        if indexPath.row == answers.count {
            delegate?.directAnswersDidTapClose(self)
        } else {
            delegate?.directAnswersDidTapAnswer(self, answer: answers[indexPath.row])
        }
    }

    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return enabled
    }


    // MARK: - Private methods

    private func buildCollectionOverView(sibling: UIView) {
        let view = UICollectionView(frame: CGRect(x: 0, y: sibling.top - directAnswersCollectionHeight,
            width: DirectAnswersPresenter.defaultWidth, height: directAnswersCollectionHeight),
            collectionViewLayout: UICollectionViewFlowLayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        guard let parentView = sibling.superview else { return }
        view.backgroundColor = UIColor.clearColor()
        parentView.addSubview(view)
        let bottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy:
            NSLayoutRelation.Equal, toItem: sibling, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal,
            toItem: sibling, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal,
            toItem: sibling, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal,
            toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: directAnswersCollectionHeight)
        view.addConstraint(height)
        parentView.addConstraints([bottom,left,right])

        view.hidden = hidden
        collectionView = view
    }

    private func setupCollection(collectionView: UICollectionView) {
        // CollectionView cells
        let filterNib = UINib(nibName: DirectAnswerCell.reusableID, bundle: nil)
        collectionView.registerNib(filterNib, forCellWithReuseIdentifier: DirectAnswerCell.reusableID)
        
        let closeNib = UINib(nibName: DirectAnswersCloseCell.reusableID, bundle: nil)
        collectionView.registerNib(closeNib, forCellWithReuseIdentifier: DirectAnswersCloseCell.reusableID)

        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
            layout.minimumInteritemSpacing = 4.0
        }

        collectionView.accessibilityId = .DirectAnswersPresenterCollectionView
    }
}


extension DirectAnswersPresenter: DirectAnswersBigViewDelegate {
    func directAnswersBigViewDidSelectAnswer(answer: DirectAnswer) {
        delegate?.directAnswersDidTapAnswer(self, answer: answer)
    }
}
