//
//  FilterTagsViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

class FilterTagsViewController : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, FilterTagCellDelegate {
    
    weak var collectionView: UICollectionView!
    
    private var tags : [FilterTag] = []
    
    init(collectionView: UICollectionView){
        self.collectionView = collectionView
        super.init()
        
        //Setup
        setup()
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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterTagCell", forIndexPath: indexPath) as! FilterTagCell
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
        
        for i in 0..<tags.count {
            if tags[i] == cellTag {
                tags.removeAtIndex(i)
                break
            }
        }
        
        self.collectionView.reloadData()
        
        //TODO CALL CONTROLLER DELEGATE
    }
    
    // MARK: - Private methods
    
    private func setup() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        // CollectionView cells
        let filterNib = UINib(nibName: "FilterTagCell", bundle: nil)
        self.collectionView.registerNib(filterNib, forCellWithReuseIdentifier: "FilterTagCell")
    }

}