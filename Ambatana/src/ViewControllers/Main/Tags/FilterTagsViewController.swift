//
//  FilterTagsView.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

protocol FilterTagsViewDelegate : class {
    func filterTagsViewDidRemoveTag(_ tag: FilterTag, remainingTags: [FilterTag])
    func filterTagsViewDidSelectTag(_ tag: FilterTag)
}

class FilterTagsView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, FilterTagCellDelegate {
    
    private static var collectionContentInset = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 5)
    
    var collectionView: UICollectionView!
    var secondaryCollectionView: UICollectionView?
    
    var tags: [FilterTag] = []
    var secondaryTags: [FilterTag] = []
    
    weak var delegate: FilterTagsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = FilterTagsView.collectionContentInset
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        //collectionView.collec.contentInset = FilterTagsView.collectionContentInset
        addSubview(collectionView)
        
        collectionView.layout(with: self).fillHorizontal().top()
        collectionView.layout().height(40)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        let filterNib = UINib(nibName: "FilterTagCell", bundle: nil)
        collectionView.register(filterNib, forCellWithReuseIdentifier: "FilterTagCell")
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }
        
        backgroundColor = .clear
        collectionView.backgroundColor = .clear
    }
    
    private func setupSecondaryCollectionView() {
        if secondaryTags.count <= 0 {
            secondaryCollectionView?.removeFromSuperview()
            return
        }
        
        if secondaryCollectionView == nil || secondaryCollectionView?.superview == nil {
        //guard secondaryCollectionView == nil, secondaryCollectionView?.superview == nil else { return }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = FilterTagsView.collectionContentInset
        secondaryCollectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        guard let secondaryCollectionView = secondaryCollectionView else { return }
        secondaryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        secondaryCollectionView.backgroundColor = .clear
        secondaryCollectionView.showsHorizontalScrollIndicator = false
        //secondaryCollectionView.collectionViewLayout.contentInset = FilterTagsView.collectionContentInset
        addSubview(secondaryCollectionView)
        
        secondaryCollectionView.dataSource = self
        secondaryCollectionView.delegate = self
        secondaryCollectionView.scrollsToTop = false
        secondaryCollectionView.register(SelectableFilterTagCell.self, forCellWithReuseIdentifier: "SelectableFilterTagCell")
        if let layout = secondaryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }
        
        secondaryCollectionView.layout(with: self).fillHorizontal().bottom()
        secondaryCollectionView.layout().height(40)
        
        secondaryCollectionView.backgroundColor = .clear
        }
    }
    
    
    // MARK: - Public methods
    
    func updateTags(_ newTags: [FilterTag]) {
        tags = newTags
        collectionView?.reloadData()
    }
    
    func updateSecondaryTags(_ newTags: [FilterTag]) {
        secondaryTags = newTags
        setupSecondaryCollectionView()
        secondaryCollectionView?.reloadData()
    }
    
    
    // MARK: - UICollectionViewDelegate & DataSource methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return FilterTagCell.cellSizeForTag(tags[indexPath.row])
        } else {
            return SelectableFilterTagCell.cellSizeForTag(secondaryTags[indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return tags.count
        } else {
            return secondaryTags.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterTagCell", for: indexPath) as? FilterTagCell else { return UICollectionViewCell() }
            cell.delegate = self
            cell.setupWithTag(tags[indexPath.row])
            return cell
        } else if collectionView == self.secondaryCollectionView {
            guard let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectableFilterTagCell", for: indexPath) as? SelectableFilterTagCell else { return UICollectionViewCell() }
            cell2.setupWithTag(secondaryTags[indexPath.row])
            return cell2
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView == self.collectionView {
            return false
        } else if collectionView == self.secondaryCollectionView {
            delegate?.filterTagsViewDidSelectTag(secondaryTags[indexPath.row])
            return true
        }
        return false
    }
    
    // MARK: - FilterTagCellDelegate
    func onFilterTagClosed(_ filterTagCell: FilterTagCell) {
        
        guard let cellTag = filterTagCell.filterTag else {
            return
        }

        var indexesToDelete: [IndexPath] = []
        for i in 0..<tags.count {
            if tags[i] == cellTag {
                indexesToDelete.append(IndexPath(item: i, section: 0))
                indexesToDelete.append(contentsOf: removeRelatedTags(forTag: cellTag))
                break
            }
        }

        //Animate item deletion
        if indexesToDelete.count > 0 {
            let indexesToDeleteSet: Set = Set(indexesToDelete.map { $0.item })
            // remove tags from the array in bulk
            tags = tags.enumerated().filter { !indexesToDeleteSet.contains($0.offset) }.map { $0.element }
            // remove cells from the collection
            self.collectionView?.deleteItems(at: indexesToDelete)
        }
        
        delegate?.filterTagsViewDidRemoveTag(cellTag, remainingTags: tags)
    }
    
    // MARK: - Private methods

    private func setAccessibilityIds() {
        collectionView?.accessibilityId = .filterTagsCollectionView
    }

    // not private for testing reasons
    func removeRelatedTags(forTag tag: FilterTag) -> [IndexPath] {
        var relatedIndexesToDelete: [IndexPath] = []
        switch tag {
        case .category(let listingCategory):
            switch listingCategory {
            case .cars:
                for i in 0..<tags.count {
                    switch tags[i] {
                    case .make, .model, .yearsRange:
                        relatedIndexesToDelete.append(IndexPath(item: i, section: 0))
                    case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .category, .taxonomyChild, .taxonomy, .secondaryTaxonomyChild:
                        continue
                    }
                }
            case .electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                 .fashionAndAccesories, .babyAndChild, .other, .realEstate, .unassigned:
                break
            }
        case .make:
            for i in 0..<tags.count {
                switch tags[i] {
                case .model:
                    relatedIndexesToDelete.append(IndexPath(item: i, section: 0))
                case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .category, .make, .yearsRange, .taxonomyChild, .taxonomy, .secondaryTaxonomyChild:
                    continue
                }
            }
        case .taxonomy:
            for i in 0..<tags.count {
                switch tags[i] {
                case .secondaryTaxonomyChild:
                    relatedIndexesToDelete.append(IndexPath(item: i, section: 0))
                case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .model, .category, .make, .yearsRange, .taxonomyChild, .taxonomy:
                    continue
                }
            }
        case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .model, .yearsRange, .taxonomyChild, .secondaryTaxonomyChild:
            break
        }
        return relatedIndexesToDelete
    }
}
