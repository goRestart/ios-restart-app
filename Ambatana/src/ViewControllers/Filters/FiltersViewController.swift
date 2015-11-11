//
//  FiltersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

class FiltersViewController: BaseViewController, FiltersViewModelDelegate, FilterDistanceCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Outlets & buttons
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveFiltersBtn: UIButton!
    
    // ViewModel
    private var viewModel : FiltersViewModel!
    
    
    //Constants
    private let sections : [FilterSection] = [.Distance, .Categories, .SortBy]
    private var distanceCellSize = CGSize(width: 0.0, height: 0.0)
    private var categoryCellSize = CGSize(width: 0.0, height: 0.0)
    private var sortByCellSize = CGSize(width: 0.0, height: 0.0)
    
    
    // MARK: - Lifecycle
    convenience init() {
        self.init(viewModel: FiltersViewModel())
    }
    
    convenience init(viewModel: FiltersViewModel) {
        self.init(viewModel: viewModel, nibName: "FiltersViewController")
    }
    
    required init(viewModel: FiltersViewModel, nibName nibNameOrNil: String?) {
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO LOCALIZE!
        
        setupUi()
        
        // Get categories
        viewModel.retrieveCategories()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions & Navbar
    
    func onNavbarCancel(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onNavbarReset(){
        viewModel.resetFilters()
    }
    
    @IBAction func onSaveFiltersBtn(sender: AnyObject) {
        viewModel.saveFilters()
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - FiltersViewModelDelegate
    
    func viewModelDidUpdate(viewModel: FiltersViewModel) {
        self.collectionView.reloadData()
    }
    
    // MARK: FilterDistanceCellDelegate
    
    func filterDistanceChanged(filterDistanceCell: FilterDistanceCell) {
        viewModel.currentDistanceKms = filterDistanceCell.distance
    }
    
    // MARK: - UICollectionViewDelegate & DataSource methods
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch sections[indexPath.section] {
        case .Distance:
            return distanceCellSize
        case .Categories:
            return categoryCellSize
        case .SortBy:
            return sortByCellSize
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .Distance:
            return 1
        case .Categories:
            return viewModel.numOfCategories
        case .SortBy:
            return viewModel.numOfSortOptions
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionElementKindSectionHeader) {
            let section = sections[indexPath.section]
            let headerCell = self.collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "FilterHeaderCell", forIndexPath: indexPath) as! FilterHeaderCell
            
            headerCell.titleLabel.text = section.name
            
            return headerCell
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        switch sections[indexPath.section] {
        case .Distance:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterDistanceCell", forIndexPath: indexPath) as! FilterDistanceCell
            cell.delegate = self
            cell.distanceType = viewModel.distanceType
            cell.setupWithDistance(viewModel.currentDistanceKms)
            return cell
        case .Categories:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCategoryCell", forIndexPath: indexPath) as! FilterCategoryCell
            cell.titleLabel.text = viewModel.categoryTextAtIndex(indexPath.row)
            cell.categoryIcon.image = viewModel.categoryIconAtIndex(indexPath.row)
            let color = viewModel.categoryColorAtIndex(indexPath.row)
            cell.categoryIcon.tintColor = color
            cell.titleLabel.textColor = color
            
            cell.rightSeparator.hidden = indexPath.row % 2 == 1
            
            return cell
            
        case .SortBy:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterSortByCell", forIndexPath: indexPath) as! FilterSortByCell
            cell.titleLabel.text = viewModel.sortOptionTextAtIndex(indexPath.row)
            cell.selected = viewModel.sortOptionSelectedAtIndex(indexPath.row)
            cell.bottomSeparator.hidden = indexPath.row != (viewModel.numOfSortOptions - 1)
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        
        switch sections[indexPath.section] {
        //Do nothing on distance
        case .Distance:
            break
        case .Categories:
            viewModel.selectCategoryAtIndex(indexPath.row)
        case .SortBy:
            viewModel.selectSortOptionAtIndex(indexPath.row)
        }
    }

    // MARK: Private methods
    
    private func setupUi(){
        // CollectionView cells
        let filterNib = UINib(nibName: "FilterCategoryCell", bundle: nil)
        self.collectionView.registerNib(filterNib, forCellWithReuseIdentifier: "FilterCategoryCell")
        let sortByNib = UINib(nibName: "FilterSortByCell", bundle: nil)
        self.collectionView.registerNib(sortByNib, forCellWithReuseIdentifier: "FilterSortByCell")
        let distanceNib = UINib(nibName: "FilterDistanceCell", bundle: nil)
        self.collectionView.registerNib(distanceNib, forCellWithReuseIdentifier: "FilterDistanceCell")
        let headerNib = UINib(nibName: "FilterHeaderCell", bundle: nil)
        self.collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "FilterHeaderCell")
        
        // Navbar
        self.setLetGoNavigationBarStyle("Filters")
        let cancelButton = UIBarButtonItem(title: LGLocalizedString.commonCancel, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onNavbarCancel"))
        cancelButton.tintColor = StyleHelper.red
        self.navigationItem.leftBarButtonItem = cancelButton;
        let resetButton = UIBarButtonItem(title: "Reset", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onNavbarReset"))
        resetButton.tintColor = StyleHelper.red
        self.navigationItem.rightBarButtonItem = resetButton;
        
        // Cells sizes
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        distanceCellSize = CGSize(width: screenWidth, height: 78.0)
        categoryCellSize = CGSize(width: screenWidth * 0.5, height: 50.0)
        sortByCellSize = CGSize(width: screenWidth, height: 50.0)
        
        // Rounded save button
        saveFiltersBtn.layer.cornerRadius = 4
    }
}
