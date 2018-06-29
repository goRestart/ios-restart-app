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

class FilterTagsView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FilterTagCellDelegate {

    static var collectionViewHeight: CGFloat = 52
    static var minimumInteritemSpacing: CGFloat = 5
    private static var collectionContentInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    
    private var collectionView: UICollectionView?
    private var secondaryCollectionView: UICollectionView?
    
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
        
        guard collectionView == nil || collectionView?.superview == nil else { return }
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = FilterTagsView.collectionContentInset
        flowLayout.minimumInteritemSpacing = FilterTagsView.minimumInteritemSpacing
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        guard let collectionView = collectionView else { return }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        
        collectionView.layout(with: self).fillHorizontal().top()
        collectionView.layout().height(FilterTagsView.collectionViewHeight)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        collectionView.register(type: FilterTagCell.self)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }
    }
    
    private func setupSecondaryCollectionView() {
        guard secondaryTags.count > 0 else {
            secondaryCollectionView?.removeFromSuperview()
            return
        }
        guard secondaryCollectionView == nil || secondaryCollectionView?.superview == nil else { return }
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = FilterTagsView.collectionContentInset
        flowLayout.minimumInteritemSpacing = FilterTagsView.minimumInteritemSpacing
        secondaryCollectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        guard let secondaryCollectionView = secondaryCollectionView else { return }
        secondaryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        secondaryCollectionView.backgroundColor = .clear
        secondaryCollectionView.showsHorizontalScrollIndicator = false
        addSubview(secondaryCollectionView)
        
        secondaryCollectionView.dataSource = self
        secondaryCollectionView.delegate = self
        secondaryCollectionView.scrollsToTop = false
        secondaryCollectionView.register(SelectableFilterTagCell.self, forCellWithReuseIdentifier: "SelectableFilterTagCell")
        if let layout = secondaryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        }
        
        secondaryCollectionView.layout(with: self).fillHorizontal().bottom()
        secondaryCollectionView.layout().height(FilterTagsView.collectionViewHeight)
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
    
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectableFilterTagCell", for: indexPath) as? SelectableFilterTagCell else { return UICollectionViewCell() }
            cell.setupWithTag(secondaryTags[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView == self.secondaryCollectionView {
            delegate?.filterTagsViewDidSelectTag(secondaryTags[indexPath.row])
            return true
        } else {
            return false
        }
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
        collectionView?.set(accessibilityId: .filterTagsCollectionView)
    }

    // not private for testing reasons
    func removeRelatedTags(forTag tag: FilterTag) -> [IndexPath] {
        var relatedIndexesToDelete: [IndexPath] = []
        switch tag {
        case .category(let listingCategory):
            switch listingCategory {
            case .cars:
                for (i, tag) in tags.enumerated() {
                    switch tag {
                    case .carSellerType, .make, .model, .yearsRange,
                         .carDriveTrainType, .carBodyType, .carFuelType, .carTransmissionType,
                         .mileageRange, .numberOfSeats:
                        relatedIndexesToDelete.append(IndexPath(item: i, section: 0))
                    case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .category, .taxonomyChild,
                         .taxonomy, .secondaryTaxonomyChild, .realEstateNumberOfBedrooms, .realEstateNumberOfBathrooms,
                         .realEstatePropertyType, .realEstateOfferType, .sizeSquareMetersRange, .realEstateNumberOfRooms,
                         .serviceType,
                         .serviceSubtype:
                        continue
                    }
                }
            case .services:
                for (i, tag) in tags.enumerated() {
                    switch tag {
                    case .serviceType,
                         .serviceSubtype:
                        relatedIndexesToDelete.append(IndexPath(item: i, section: 0))
                    case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .category, .taxonomyChild,
                         .taxonomy, .secondaryTaxonomyChild, .realEstateNumberOfBedrooms, .realEstateNumberOfBathrooms,
                         .realEstatePropertyType, .realEstateOfferType, .sizeSquareMetersRange, .realEstateNumberOfRooms,
                         .carSellerType, .make, .model, .yearsRange, .carDriveTrainType, .carBodyType, .carFuelType, .carTransmissionType,
                         .mileageRange, .numberOfSeats:
                        continue
                    }
                }
            case .electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                 .fashionAndAccesories, .babyAndChild, .other, .unassigned:
                break
            case .realEstate:
                for (i, tag) in tags.enumerated() {
                    switch tag {
                    case .realEstateNumberOfBedrooms, .realEstateNumberOfBathrooms, .realEstatePropertyType,
                         .realEstateOfferType, .sizeSquareMetersRange, .realEstateNumberOfRooms:
                        relatedIndexesToDelete.append(IndexPath(item: i, section: 0))
                    case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .category,
                         .taxonomyChild, .taxonomy, .secondaryTaxonomyChild, .carSellerType, .make, .model, .yearsRange, .serviceType,
                         .serviceSubtype, .carDriveTrainType, .carBodyType, .carFuelType, .carTransmissionType,
                         .mileageRange, .numberOfSeats:
                        continue
                    }
                }
            }
        case .make:
            for (i, tag) in tags.enumerated() {
                switch tag {
                case .model:
                    relatedIndexesToDelete.append(IndexPath(item: i, section: 0))
                case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .category, .carSellerType, .make, .yearsRange,
                     .taxonomyChild, .taxonomy, .secondaryTaxonomyChild, .realEstateNumberOfBedrooms,
                     .realEstateNumberOfBathrooms, .realEstatePropertyType, .realEstateOfferType,
                     .sizeSquareMetersRange, .realEstateNumberOfRooms, .serviceType,
                     .serviceSubtype, .carDriveTrainType, .carBodyType, .carFuelType, .carTransmissionType,
                     .mileageRange, .numberOfSeats:
                    continue
                }
            }
        case .serviceType:
            for (i, tag) in tags.enumerated() {
                switch tag {
                case .serviceSubtype:
                    relatedIndexesToDelete.append(IndexPath(item: i, section: 0))
                case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .category, .carSellerType, .make, .yearsRange,
                     .taxonomyChild, .taxonomy, .secondaryTaxonomyChild, .realEstateNumberOfBedrooms,
                     .realEstateNumberOfBathrooms, .realEstatePropertyType, .realEstateOfferType,
                     .sizeSquareMetersRange, .realEstateNumberOfRooms, .serviceType, .model,
                     .carDriveTrainType, .carBodyType, .carFuelType, .carTransmissionType,
                     .mileageRange, .numberOfSeats:
                    continue
                }
            }
        case .taxonomy:
            for (i, tag) in tags.enumerated() {
                switch tag {
                case .secondaryTaxonomyChild, .taxonomyChild:
                    relatedIndexesToDelete.append(IndexPath(item: i, section: 0))
                case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .carSellerType, .model, .category, .make,
                     .yearsRange, .taxonomy, .realEstateNumberOfBedrooms, .realEstateNumberOfBathrooms, .realEstatePropertyType,
                     .realEstateOfferType, .sizeSquareMetersRange, .realEstateNumberOfRooms, .serviceType,
                     .serviceSubtype, .carDriveTrainType, .carBodyType, .carFuelType, .carTransmissionType,
                     .mileageRange, .numberOfSeats:
                    continue
                }
            }
        case .location, .orderBy, .within, .priceRange, .freeStuff, .distance, .carSellerType, .model, .yearsRange, .taxonomyChild,
             .secondaryTaxonomyChild, .realEstateNumberOfBedrooms, .realEstateNumberOfBathrooms, .realEstatePropertyType,
             .realEstateOfferType, .sizeSquareMetersRange, .realEstateNumberOfRooms,
             .serviceSubtype, .carDriveTrainType, .carBodyType, .carFuelType, .carTransmissionType,
             .mileageRange, .numberOfSeats:
            break
        }
        return relatedIndexesToDelete
    }
}
