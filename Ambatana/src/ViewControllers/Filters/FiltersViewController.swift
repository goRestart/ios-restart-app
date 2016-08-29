//
//  FiltersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class FiltersViewController: BaseViewController, FiltersViewModelDelegate, FilterDistanceCellDelegate, FilterPriceCellDelegate,
UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Outlets & buttons
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveFiltersBtn: UIButton!
    
    // ViewModel
    private var viewModel : FiltersViewModel!
    
    private let keyboardHelper: KeyboardHelper

    //Constants
    private let sections : [FilterSection] = FilterSection.allValues()
    private var distanceCellSize = CGSize(width: 0.0, height: 0.0)
    private var categoryCellSize = CGSize(width: 0.0, height: 0.0)
    private var singleCheckCellSize = CGSize(width: 0.0, height: 0.0)
    private var priceCellSize = CGSize(width: 0.0, height: 0.0)

    // Rx
    let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle

    convenience init() {
        self.init(viewModel: FiltersViewModel())
    }
    
    convenience init(viewModel: FiltersViewModel) {
        self.init(viewModel: viewModel, nibName: "FiltersViewController", keyboardHelper: KeyboardHelper.sharedInstance)
    }
    
    required init(viewModel: FiltersViewModel, nibName nibNameOrNil: String?, keyboardHelper: KeyboardHelper) {
        self.keyboardHelper = keyboardHelper
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel = viewModel
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUi()
        setAccessibilityIds()
        
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

    func vmForcePriceFix() {
        let indexPath = NSIndexPath(forItem: 0,inSection: FilterSection.Price.rawValue)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: true)
        guard let minPriceCell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterPriceCell else { return }
        minPriceCell.textField.becomeFirstResponder()
    }

    // MARK: FilterDistanceCellDelegate
    
    func filterDistanceChanged(filterDistanceCell: FilterDistanceCell) {
        viewModel.currentDistanceRadius = filterDistanceCell.distance
    }

    // MARK: FilterPriceCellDelegate

    func priceTextFieldValueChanged(value: String?, tag: Int) {
        switch tag {
        case 0:
            viewModel.setMinPrice(value)
        case 1:
            viewModel.setMaxPrice(value)
        default:
            break
        }
    }

    func priceTextFieldValueActive(tag: Int) {
        keyboardHelper.rx_keyboardOrigin.asObservable().bindNext { [weak self] origin in
            guard let viewHeight = self?.view.height where viewHeight >= origin else { return }
            guard let collectionView = self?.collectionView else { return }
            collectionView.contentInset.bottom = viewHeight - origin
            let indexPath = NSIndexPath(forItem: tag,inSection: FilterSection.Price.rawValue)
            guard let activeCell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterPriceCell else { return }
            let activeCellFrame = activeCell.frame
            collectionView.scrollRectToVisible(activeCellFrame, animated: true)
        }.addDisposableTo(disposeBag)
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
            case .Price:
                return priceCellSize
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
        case .Price:
            return 2
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
                cell.selected = viewModel.categorySelectedAtIndex(indexPath.row)
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
            case .Price:
                guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterPriceCell",
                    forIndexPath: indexPath) as? FilterPriceCell else { return UICollectionViewCell() }
                switch indexPath.row {
                case 0:
                    cell.tag = 0
                    cell.titleLabel.text = LGLocalizedString.filtersPriceFrom
                    cell.bottomSeparator.hidden = true
                    cell.topSeparator.hidden = false
                case 1:
                    cell.tag = 1
                    cell.titleLabel.text = LGLocalizedString.filtersPriceTo
                    cell.bottomSeparator.hidden = false
                    cell.topSeparator.hidden = true
                default:
                    break
                }
                print(viewModel.priceAtIndex(indexPath.row))
                cell.textField.text = viewModel.priceAtIndex(indexPath.row)
                cell.delegate = self
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
        case .Price:
            //Do nothing on price
            break
        }
    }


    // MARK: Private methods
    
    private func setupUi(){
        // CollectionView cells
        let categoryNib = UINib(nibName: "FilterCategoryCell", bundle: nil)
        self.collectionView.registerNib(categoryNib, forCellWithReuseIdentifier: "FilterCategoryCell")
        let sortByNib = UINib(nibName: "FilterSingleCheckCell", bundle: nil)
        self.collectionView.registerNib(sortByNib, forCellWithReuseIdentifier: "FilterSingleCheckCell")
        let distanceNib = UINib(nibName: "FilterDistanceCell", bundle: nil)
        self.collectionView.registerNib(distanceNib, forCellWithReuseIdentifier: "FilterDistanceCell")
        let locationNib = UINib(nibName: "FilterLocationCell", bundle: nil)
        self.collectionView.registerNib(locationNib, forCellWithReuseIdentifier: "FilterLocationCell")
        let headerNib = UINib(nibName: "FilterHeaderCell", bundle: nil)
        self.collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: "FilterHeaderCell")
        let priceNib = UINib(nibName: "FilterPriceCell", bundle: nil)
        self.collectionView.registerNib(priceNib, forCellWithReuseIdentifier: "FilterPriceCell")

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
        categoryCellSize = CGSize(width: screenWidth, height: 50.0)
        singleCheckCellSize = CGSize(width: screenWidth, height: 50.0)
        priceCellSize = CGSize(width: screenWidth, height: 50.0)

        // Rounded save button
        saveFiltersBtn.setStyle(.Primary(fontSize: .Medium))
        saveFiltersBtn.setTitle(LGLocalizedString.filtersSaveButton, forState: UIControlState.Normal)
    }

    private func setAccessibilityIds() {
        collectionView.accessibilityId = .FiltersCollectionView
        saveFiltersBtn.accessibilityId = .FiltersSaveFiltersButton
        self.navigationItem.rightBarButtonItem?.accessibilityId = .FiltersResetButton
        self.navigationItem.leftBarButtonItem?.accessibilityId = .FiltersCancelButton
    }
}
