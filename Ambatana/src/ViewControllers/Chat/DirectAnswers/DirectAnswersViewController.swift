//
//  DirectAnswersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol DirectAnswersViewControllerDelegate : class {
    func directAnswersDidTapAnswer(controller: DirectAnswersViewController, answer: DirectAnswer)
}

class DirectAnswersViewController : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {

    weak var collectionView: UICollectionView!

    var actions: [DirectAnswer] = []

    weak var delegate: DirectAnswersViewControllerDelegate?

    init(collectionView: UICollectionView){
        self.collectionView = collectionView
        super.init()

        setup()
    }


    // MARK: - Public methods

    func setActions(newActions: [DirectAnswer]) {
        self.actions = newActions
        self.collectionView.reloadData()
    }


    // MARK: - UICollectionViewDelegate & DataSource methods

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return DirectAnswerCell.sizeForDirectAnswer(actions[indexPath.row])
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DirectAnswerCell.reusableID(),
            forIndexPath: indexPath) as? DirectAnswerCell else { return UICollectionViewCell() }

        cell.setupWithDirectAnswer(actions[indexPath.row])

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.directAnswersDidTapAnswer(self, answer: actions[indexPath.row])
    }


    // MARK: - Private methods

    private func setup() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.scrollsToTop = false

        // CollectionView cells
        let filterNib = UINib(nibName: DirectAnswerCell.reusableID(), bundle: nil)
        self.collectionView.registerNib(filterNib, forCellWithReuseIdentifier: DirectAnswerCell.reusableID())

        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        }
    }
}