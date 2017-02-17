//
//  DirectAnswersHorizontalView.swift
//  LetGo
//
//  Created by Eli Kohen on 13/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

protocol DirectAnswersHorizontalViewDelegate: class {
    func directAnswersHorizontalViewDidSelect(answer: QuickAnswer)
    func directAnswersHorizontalViewDidSelectClose()
}

class DirectAnswersHorizontalView: UIView {

    static let defaultWidth: CGFloat = UIScreen.main.bounds.width
    static let defaultHeight: CGFloat = 48
    static let sideMargin: CGFloat = 8

    weak var delegate: DirectAnswersHorizontalViewDelegate?

    var answersEnabled: Bool = true {
        didSet {
            if answersEnabled {
                collectionView.deselectAll()
            }
        }
    }
    var deselectOnItemTap: Bool = true
    var closeButtonEnabled: Bool = true {
        didSet {
            collectionView.reloadData()
        }
    }

    fileprivate let collectionView: UICollectionView
    fileprivate var answers: [QuickAnswer]

    // MARK: - Lifecycle

    convenience init(answers: [QuickAnswer], sideMargin: CGFloat = DirectAnswersHorizontalView.sideMargin) {
        let frame = CGRect(x: 0, y: 0, width: DirectAnswersHorizontalView.defaultWidth, height: DirectAnswersHorizontalView.defaultHeight)
        self.init(frame: frame, answers: answers, sideMargin: sideMargin)
    }

    required init(frame: CGRect, answers: [QuickAnswer], sideMargin: CGFloat = DirectAnswersHorizontalView.sideMargin) {
        self.answers = answers
        let collectionFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        self.collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: UICollectionViewFlowLayout())
        super.init(frame: frame)
        setupUI(sideMargin: sideMargin)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: DirectAnswersHorizontalView.defaultWidth, height: DirectAnswersHorizontalView.defaultHeight)
    }

    func update(answers: [QuickAnswer]) {
        self.answers = answers
        collectionView.reloadData()
    }

    private func setupUI(sideMargin: CGFloat) {
        backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        collectionView.layout(with: self).fill()
        collectionView.layout().height(DirectAnswersHorizontalView.defaultHeight)

        setupCollection(sideMargin: sideMargin)
    }
}


// MARK: - UICollectionView method

extension DirectAnswersHorizontalView: UICollectionViewDelegate, UICollectionViewDataSource {

    fileprivate func setupCollection(sideMargin: CGFloat) {
        // CollectionView cells
        let filterNib = UINib(nibName: DirectAnswerCell.reusableID, bundle: nil)
        collectionView.register(filterNib, forCellWithReuseIdentifier: DirectAnswerCell.reusableID)

        let closeNib = UINib(nibName: DirectAnswersCloseCell.reusableID, bundle: nil)
        collectionView.register(closeNib, forCellWithReuseIdentifier: DirectAnswersCloseCell.reusableID)

        collectionView.backgroundColor = UIColor.clear
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: sideMargin, bottom: 0, right: sideMargin)

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
            layout.minimumInteritemSpacing = 4.0
        }

        collectionView.accessibilityId = .directAnswersPresenterCollectionView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if closeButtonEnabled && indexPath.row == answers.count {
            return DirectAnswersCloseCell.size()
        } else {
            return DirectAnswerCell.sizeForDirectAnswer(answers[indexPath.row])
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return closeButtonEnabled ? answers.count + 1 : answers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if closeButtonEnabled && indexPath.row == answers.count {
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
        return answersEnabled
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return answersEnabled
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if deselectOnItemTap {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        guard answersEnabled else { return }
        if closeButtonEnabled && indexPath.row == answers.count {
            delegate?.directAnswersHorizontalViewDidSelectClose()
        } else {
            delegate?.directAnswersHorizontalViewDidSelect(answer: answers[indexPath.row])
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return answersEnabled
    }
}
