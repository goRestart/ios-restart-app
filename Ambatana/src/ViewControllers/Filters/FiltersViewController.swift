//
//  FiltersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGSemiModalNavController

class FiltersViewController: BaseViewController, FiltersViewModelDelegate, FilterDistanceCellDelegate,
UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Outlets & buttons
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveFiltersBtn: UIButton!
    
    // ViewModel
    private var viewModel : FiltersViewModel!
    
    
    //Constants
    private let sections : [FilterSection] = FilterSection.allValues()
    private var distanceCellSize = CGSize(width: 0.0, height: 0.0)
    private var categoryCellSize = CGSize(width: 0.0, height: 0.0)
    private var singleCheckCellSize = CGSize(width: 0.0, height: 0.0)
    
    
    // MARK: - Factory

    static func presentAsSemimodalOnViewController(parentVC : UIViewController,
        withViewModel viewModel: FiltersViewModel = FiltersViewModel()){
        
            let vc = FiltersViewController(viewModel: viewModel)
            
            let semiModal = LGSemiModalNavViewController(rootViewController: vc)
            semiModal.view.frame = CGRectMake(0, 0, parentVC.view.frame.size.width,
                parentVC.view.frame.size.height * 0.85)
            //Selected customization properties, see more in the header of the LGSemiModalNavViewController
            semiModal.backgroundShadeColor = UIColor.blackColor()
            semiModal.animationSpeed = 0.35
            semiModal.tapDismissEnabled = true
            semiModal.backgroundShadeAlpha = 0.4;
            semiModal.scaleTransform = CGAffineTransformMakeScale(0.94, 0.94)
            
            parentVC.presentViewController(semiModal, animated: true, completion: nil)
    }
    
    
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
        setupAccessibilityIds()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    func vmDidUpdate() {
        collectionView.reloadData()
    }

    func vmOpenLocation(locationViewModel: EditLocationViewModel) {
        let ctrl = EditLocationViewController(viewModel: locationViewModel)
        pushViewController(ctrl, animated: true, completion: nil)
    }

    // MARK: FilterDistanceCellDelegate
    
    func filterDistanceChanged(filterDistanceCell: FilterDistanceCell) {
        viewModel.currentDistanceRadius = filterDistanceCell.distance
    }


    // MARK: - UICollectionViewDelegate & DataSource methods
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            switch sections[indexPath.section] {
            case .Distance:
                return distanceCellSize
            case .Categories:
                return categoryCellSize
            case .SortBy, .Within, .Location:
                return singleCheckCellSize
            }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .Location:
            return 1
        case .Distance:
            return 1
        case .Categories:
            return viewModel.numOfCategories
        case .Within:
            return viewModel.numOfWithinTimes
        case .SortBy:
            return viewModel.numOfSortOptions
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
            if (kind == UICollectionElementKindSectionHeader) {
                let cell = self.collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                    withReuseIdentifier: "FilterHeaderCell", forIndexPath: indexPath)
                guard let headerCell = cell as? FilterHeaderCell else { return UICollectionReusableView() }
                
                let section = sections[indexPath.section]
                headerCell.separator.hidden = indexPath.section == 0
                headerCell.titleLabel.text = section.name
                
                return headerCell
            }
            
            return UICollectionReusableView()
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {

            // TODO: Refactor cells into CellDrawer pattern
            switch sections[indexPath.section] {
            case .Location:
                guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterLocationCell",
                    forIndexPath: indexPath) as? FilterLocationCell else { return UICollectionViewCell() }
                cell.locationLabel.text = viewModel.place?.fullText(showAddress: false)
                return cell
            case .Distance:
                guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterDistanceCell",
                    forIndexPath: indexPath) as? FilterDistanceCell else { return UICollectionViewCell() }
                cell.delegate = self
                cell.distanceType = viewModel.distanceType
                cell.setupWithDistance(viewModel.currentDistanceRadius)
                return cell
            case .Categories:
                guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCategoryCell",
                    forIndexPath: indexPath) as? FilterCategoryCell else { return UICollectionViewCell() }
                cell.titleLabel.text = viewModel.categoryTextAtIndex(indexPath.row)
                cell.categoryIcon.image = viewModel.categoryIconAtIndex(indexPath.row)
                let color = viewModel.categoryColorAtIndex(indexPath.row)
                cell.categoryIcon.tintColor = color
                cell.titleLabel.textColor = color
                
                cell.rightSeparator.hidden = indexPath.row % 2 == 1
                return cell
            case .Within:
                guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterSingleCheckCell",
                    forIndexPath: indexPath) as? FilterSingleCheckCell else { return UICollectionViewCell() }
                cell.titleLabel.text = viewModel.withinTimeNameAtIndex(indexPath.row)
                cell.selected = viewModel.withinTimeSelectedAtIndex(indexPath.row)
                cell.bottomSeparator.hidden = true
                return cell
                
            case .SortBy:
                guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterSingleCheckCell",
                    forIndexPath: indexPath) as? FilterSingleCheckCell else { return UICollectionViewCell() }
                cell.titleLabel.text = viewModel.sortOptionTextAtIndex(indexPath.row)
                cell.selected = viewModel.sortOptionSelectedAtIndex(indexPath.row)
                cell.bottomSeparator.hidden = indexPath.row != (viewModel.numOfSortOptions - 1)
                return cell
            }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        
        switch sections[indexPath.section] {
        case .Location:
            viewModel.locationButtonPressed()
        case .Distance:
            //Do nothing on distance
            break
        case .Categories:
            viewModel.selectCategoryAtIndex(indexPath.row)
        case .Within:
            viewModel.selectWithinTimeAtIndex(indexPath.row)
        case .SortBy:
            viewModel.selectSortOptionAtIndex(indexPath.row)
        }
    }


    // MARK: Private methods
    
    private func setupUi(){
        // CollectionView cells
        let filterNib = UINib(nibName: "FilterCategoryCell", bundle: nil)
        self.collectionView.registerNib(filterNib, forCellWithReuseIdentifier: "FilterCategoryCell")
        let sortByNib = UINib(nibName: "FilterSingleCheckCell", bundle: nil)
        self.collectionView.registerNib(sortByNib, forCellWithReuseIdentifier: "FilterSingleCheckCell")
        let distanceNib = UINib(nibName: "FilterDistanceCell", bundle: nil)
        self.collectionView.registerNib(distanceNib, forCellWithReuseIdentifier: "FilterDistanceCell")
        let locationNib = UINib(nibName: "FilterLocationCell", bundle: nil)
        self.collectionView.registerNib(locationNib, forCellWithReuseIdentifier: "FilterLocationCell")
        let headerNib = UINib(nibName: "FilterHeaderCell", bundle: nil)
        self.collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: "FilterHeaderCell")
        
        // Navbar
        setNavBarTitle(LGLocalizedString.filtersTitle)
        let cancelButton = UIBarButtonItem(title: LGLocalizedString.commonCancel, style: UIBarButtonItemStyle.Plain,
            target: self, action: #selector(FiltersViewController.onNavbarCancel))
        cancelButton.tintColor = UIColor.primaryColor
        self.navigationItem.leftBarButtonItem = cancelButton;
        let resetButton = UIBarButtonItem(title: LGLocalizedString.filtersNavbarReset, style: UIBarButtonItemStyle.Plain,
            target: self, action: #selector(FiltersViewController.onNavbarReset))
        resetButton.tintColor = UIColor.primaryColor
        self.navigationItem.rightBarButtonItem = resetButton;
        
        // Cells sizes
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        distanceCellSize = CGSize(width: screenWidth, height: 78.0)
        categoryCellSize = CGSize(width: screenWidth * 0.5, height: 50.0)
        singleCheckCellSize = CGSize(width: screenWidth, height: 50.0)
        
        // Rounded save button
        saveFiltersBtn.setStyle(.Primary(fontSize: .Medium))
        saveFiltersBtn.setTitle(LGLocalizedString.filtersSaveButton, forState: UIControlState.Normal)
    }

    private func setupAccessibilityIds() {
        collectionView.accessibilityId = .FiltersCollectionView
        saveFiltersBtn.accessibilityId = .FiltersSaveFiltersButton
        self.navigationItem.rightBarButtonItem?.accessibilityId = .FiltersResetButton
        self.navigationItem.leftBarButtonItem?.accessibilityId = .FiltersCancelButton
    }
}
