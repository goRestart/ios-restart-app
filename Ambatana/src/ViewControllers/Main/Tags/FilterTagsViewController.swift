//
//  FilterTagsView.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

protocol FilterTagsViewDelegate : class {
    func filterTagsViewDidRemoveTag(_ controller: FilterTagsView)
}

class FilterTagsView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, FilterTagCellDelegate {
    
    var collectionView: UICollectionView!
    //var secondaryCollectionView: UICollectionView!
    
    var tags : [FilterTag] = []
    var seconaryTags : [FilterTag] = []
    
    weak var delegate: FilterTagsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        collectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        //secondaryCollectionView = UICollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
        
        translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        addSubview(collectionView)
        //addSubview(secondaryCollectionView)
        
        collectionView.layout(with: self).fillHorizontal().top().bottom()
        //collectionView.layout(with: secondaryCollectionView ?? self).bottom().proportionalHeight()
        //secondaryCollectionView.layout(with: self).fillHorizontal().bottom()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        let filterNib = UINib(nibName: "FilterTagCell", bundle: nil)
        collectionView.register(filterNib, forCellWithReuseIdentifier: "FilterTagCell")
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }
        
        //secondaryCollectionView.dataSource = self
        //secondaryCollectionView.delegate = self
        //secondaryCollectionView.scrollsToTop = false
        //secondaryCollectionView.register(filterNib, forCellWithReuseIdentifier: "FilterTagCell")
        //if let layout = secondaryCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
        //    layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        //}
    }
    
    
    // MARK: - Public methods
    
    func updateTags(_ newTags: [FilterTag]) {
        tags = newTags
        collectionView?.reloadData()
    }
    
    func updateSecondaryTags(_ newTags: [FilterTag]) {
        tags = newTags
        //secondaryCollectionView?.reloadData()
    }
    
    
    // MARK: - UICollectionViewDelegate & DataSource methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return FilterTagCell.cellSizeForTag(tags[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterTagCell", for: indexPath) as? FilterTagCell else { return UICollectionViewCell() }
        cell.delegate = self
        cell.setupWithTag(tags[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
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
        
        delegate?.filterTagsViewDidRemoveTag(self)
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
                    case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .category, .taxonomy, .taxonomyChild:
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
                case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .category, .make, .yearsRange, .taxonomyChild, .taxonomy:
                    continue
                }
            }
        case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .model, .yearsRange, .taxonomy, .taxonomyChild:
            break
        }
        return relatedIndexesToDelete
    }
}
