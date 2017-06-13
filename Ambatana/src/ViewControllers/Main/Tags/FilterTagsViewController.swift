//
//  FilterTagsViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

protocol FilterTagsViewControllerDelegate : class {
    func filterTagsViewControllerDidRemoveTag(_ controller: FilterTagsViewController)
}

class FilterTagsViewController : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, FilterTagCellDelegate {
    
    weak var collectionView: UICollectionView?
    
    var tags : [FilterTag] = []
    
    weak var delegate : FilterTagsViewControllerDelegate?
    
    init(collectionView: UICollectionView){
        self.collectionView = collectionView
        super.init()
        
        //Setup
        setup()
        setAccessibilityIds()
    }
    
    // MARK: - Public methods
    func updateTags(_ newTags: [FilterTag]) {
        tags = newTags
        collectionView?.reloadData()
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
        
        delegate?.filterTagsViewControllerDidRemoveTag(self)
    }
    
    // MARK: - Private methods
    
    private func setup() {
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.scrollsToTop = false
        
        // CollectionView cells
        let filterNib = UINib(nibName: "FilterTagCell", bundle: nil)
        self.collectionView?.register(filterNib, forCellWithReuseIdentifier: "FilterTagCell")
        
        if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }
    }

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
                    case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .category:
                        continue
                    }
                }
            case .electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                 .fashionAndAccesories, .babyAndChild, .other, .unassigned:
                break
            }
        case .make:
            for i in 0..<tags.count {
                switch tags[i] {
                case .model:
                    relatedIndexesToDelete.append(IndexPath(item: i, section: 0))
                case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .category, .make, .yearsRange:
                    continue
                }
            }
        case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .model, .yearsRange:
            break
        }
        return relatedIndexesToDelete
    }
}
