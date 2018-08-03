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
}

enum DirectAnswersStyle {
    case dark, light
}

class DirectAnswersHorizontalView: UIView {
    struct Layout {
        struct Width { static let standard: CGFloat = UIScreen.main.bounds.width  }
        struct Height {
            static let standard: CGFloat = DirectAnswerCell.cellHeight
            static let estimatedRow: CGFloat = 140
        }
        static let standardSideMargin: CGFloat = 8
    }

    weak var delegate: DirectAnswersHorizontalViewDelegate?

    var answersEnabled: Bool = true {
        didSet {
            if answersEnabled {
                collectionView.deselectAll()
            }
            collectionView.reloadData()
        }
    }
    var sideMargin: CGFloat = Layout.standardSideMargin {
        didSet {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: sideMargin, bottom: 0, right: sideMargin)
        }
    }
    var style: DirectAnswersStyle = .dark

    fileprivate var heightConstraint = NSLayoutConstraint()
    fileprivate let collectionView: UICollectionView
    fileprivate var answers: [QuickAnswer]
    fileprivate var isDynamic: Bool = false

    
    // MARK: - Lifecycle

    convenience init(answers: [QuickAnswer], sideMargin: CGFloat = Layout.standardSideMargin) {
        let frame = CGRect(x: 0, y: 0, width: Layout.Width.standard, height: DirectAnswerCell.cellHeight)
        self.init(frame: frame, answers: answers, sideMargin: sideMargin)
    }

    required init(frame: CGRect, answers: [QuickAnswer], sideMargin: CGFloat = Layout.standardSideMargin) {
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
        return CGSize(width: Layout.Width.standard, height: Layout.Height.standard)
    }

    func update(answers: [QuickAnswer]) {
        self.answers = answers
        collectionView.reloadData()
    }

    func resetScrollPosition() {
        let rectToScroll = CGRect(x: 0, y: 0, width: 1, height: 1)
        collectionView.scrollRectToVisible(rectToScroll, animated: false)
    }

    private func setupUI(sideMargin: CGFloat) {
        backgroundColor = .clear
        clipsToBounds = true
        let height = Layout.Height.standard
        layout().height(height, constraintBlock: { [weak self] in self?.heightConstraint = $0 })
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        collectionView.layout(with: self).leading().trailing().top()
        collectionView.layout().height(DirectAnswerCell.cellHeight)

        setupCollection(sideMargin: sideMargin)
    }
}


// MARK: - UICollectionView methods
extension DirectAnswersHorizontalView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    fileprivate func setupCollection(sideMargin: CGFloat) {
        // CollectionView cells
        let filterNib = UINib(nibName: DirectAnswerCell.reusableID, bundle: nil)
        collectionView.register(filterNib, forCellWithReuseIdentifier: DirectAnswerCell.reusableID)

        collectionView.backgroundColor = .clear
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

        collectionView.set(accessibilityId: .directAnswersPresenterCollectionView)
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return DirectAnswerCell.sizeForDirectAnswer(answers[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DirectAnswerCell.reusableID,
                                                            for: indexPath) as? DirectAnswerCell else { return UICollectionViewCell() }

        cell.setupWithDirectAnswer(answers[indexPath.row], answersEnabled: answersEnabled)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return answersEnabled
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return answersEnabled
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer { collectionView.deselectItem(at: indexPath, animated: true) }
        guard answersEnabled else { return }
        delegate?.directAnswersHorizontalViewDidSelect(answer: answers[indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return answersEnabled
    }
}
