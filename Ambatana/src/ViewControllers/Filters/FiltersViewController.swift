//
//  FiltersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

class FiltersViewController: BaseViewController, FiltersViewModelDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        //TODO IMPLEMENT
    }
    
    @IBAction func onSaveFiltersBtn(sender: AnyObject) {
        
        //TODO IMPLEMENT
        
    }
    
    
    // MARK: - FiltersViewModelDelegate
    
    func viewModelDidUpdate(viewModel: FiltersViewModel) {
//        self.collectionView.reloadData()
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
            //TODO CUSTOMIZE
            return cell
        case .Categories:
            let category = viewModel.categoryAtIndex(indexPath.row)
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCategoryCell", forIndexPath: indexPath) as! FilterCategoryCell
            cell.titleLabel.text = category?.name
            cell.titleLabel.textColor = category?.color
            cell.categoryIcon.image = category?.image
            cell.rightSeparator.hidden = indexPath.row % 2 == 1
            
            return cell
            
        case .SortBy:
            let sortOption = viewModel.sortOptionAtIndex(indexPath.row)
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterSortByCell", forIndexPath: indexPath) as! FilterSortByCell
            cell.titleLabel.text = sortOption?.name
            cell.bottomSeparator.hidden = indexPath.row != (viewModel.numOfSortOptions - 1)
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //TODO IMPLEMENT
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
