//
//  DirectAnswersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol DirectAnswersViewControllerDelegate : class {
    func directAnswersDidTapAnswer(controller: DirectAnswersViewController, answer: DirectAnswer)
    func directAnswersDidTapClose(controller: DirectAnswersViewController)
}

class DirectAnswersViewController : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {

    weak var delegate: DirectAnswersViewControllerDelegate?

    var directAnswersHeight: CGFloat {
        return hidden ? 0 : 48
    }

    var hidden: Bool = false {
        didSet {
            collectionView?.hidden = hidden
        }
    }

    private weak var collectionView: UICollectionView?
    private var answers: [DirectAnswer] = []


    // MARK: - Public methods

    func setupOnTopOfView(sibling: UIView) {
        buildCollectionOverView(sibling)
        guard let collectionView = collectionView else { return }
        setupCollection(collectionView)
    }

    func setDirectAnswers(answers: [DirectAnswer]) {
        self.answers = answers
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
            return collectionView.dequeueReusableCellWithReuseIdentifier(DirectAnswersCloseCell.reusableID(),
                forIndexPath: indexPath)
        } else {
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DirectAnswerCell.reusableID(),
                forIndexPath: indexPath) as? DirectAnswerCell else { return UICollectionViewCell() }

            cell.setupWithDirectAnswer(answers[indexPath.row])

            return cell
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == answers.count {
            delegate?.directAnswersDidTapClose(self)
        } else {
            delegate?.directAnswersDidTapAnswer(self, answer: answers[indexPath.row])
        }
    }


    // MARK: - Private methods

    private func buildCollectionOverView(sibling: UIView) {
        let view = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: directAnswersHeight),
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
            toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: directAnswersHeight)
        view.addConstraint(height)
        parentView.addConstraints([bottom,left,right])

        view.hidden = hidden
        collectionView = view
    }

    private func setupCollection(collectionView: UICollectionView) {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

        // CollectionView cells
        let filterNib = UINib(nibName: DirectAnswerCell.reusableID(), bundle: nil)
        collectionView.registerNib(filterNib, forCellWithReuseIdentifier: DirectAnswerCell.reusableID())

        let closeNib = UINib(nibName: DirectAnswersCloseCell.reusableID(), bundle: nil)
        collectionView.registerNib(closeNib, forCellWithReuseIdentifier: DirectAnswersCloseCell.reusableID())

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        }
    }
}