//
//  FilterTagsViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

protocol FilterTagsViewControllerDelegate : class {
    func filterTagsViewControllerDidRemoveTag(controller: FilterTagsViewController)
}

class FilterTagsViewController : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, FilterTagCellDelegate {
    
    weak var collectionView: UICollectionView!
    
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
    func updateTags(newTags: [FilterTag]) {
        self.tags = newTags
        self.collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDelegate & DataSource methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return FilterTagCell.cellSizeForTag(tags[indexPath.row])
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterTagCell", forIndexPath: indexPath) as? FilterTagCell else { return UICollectionViewCell() }
        cell.delegate = self
        cell.setupWithTag(tags[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    // MARK: - FilterTagCellDelegate
    func onFilterTagClosed(filterTagCell: FilterTagCell) {
        
        guard let cellTag = filterTagCell.filterTag else {
            return
        }
        
        var deleteIndex = -1
        for i in 0..<tags.count {
            if tags[i] == cellTag {
                tags.removeAtIndex(i)
                deleteIndex = i
                break
            }
        }
        
        //Animate item deletion
        if deleteIndex >= 0 {
            self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forRow: deleteIndex, inSection: 0)])
        }
        
        delegate?.filterTagsViewControllerDidRemoveTag(self)
    }
    
    // MARK: - Private methods
    
    private func setup() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.scrollsToTop = false
        
        // CollectionView cells
        let filterNib = UINib(nibName: "FilterTagCell", bundle: nil)
        self.collectionView.registerNib(filterNib, forCellWithReuseIdentifier: "FilterTagCell")
        
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        }
    }

    private func setAccessibilityIds() {
        collectionView.accessibilityId = .FilterTagsCollectionView
    }
}