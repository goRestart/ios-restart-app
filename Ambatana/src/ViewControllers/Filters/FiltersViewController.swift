//
//  FiltersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class FiltersViewController: BaseViewController, FiltersViewModelDelegate, FilterDistanceSliderDelegate, FilterPriceCellDelegate,
FilterCarInfoYearCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    // Outlets & buttons
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveFiltersBtn: UIButton!

    @IBOutlet weak var saveFiltersBtnContainer: UIView!
    @IBOutlet weak var saveFiltersBtnContainerBottomConstraint: NSLayoutConstraint!
    
    // ViewModel
    private var viewModel : FiltersViewModel
    
    private let keyboardHelper: KeyboardHelper
    private var tapRec: UITapGestureRecognizer?

    //Constants
    private var distanceCellSize = CGSize.zero
    private var categoryCellSize = CGSize.zero
    private var singleCheckCellSize = CGSize.zero
    private var priceCellSize = CGSize.zero
    private var yearRangeCellSize = CGSize.zero

    // Price kb scroll
    private var priceToCellFrame: CGRect = CGRect.zero

    // Rx
    let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle
    
    convenience init(viewModel: FiltersViewModel) {
        self.init(viewModel: viewModel, nibName: "FiltersViewController", keyboardHelper: KeyboardHelper())
    }
    
    required init(viewModel: FiltersViewModel, nibName nibNameOrNil: String?, keyboardHelper: KeyboardHelper) {
        self.keyboardHelper = keyboardHelper
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRx()
        setAccessibilityIds()

        // Get categories
        viewModel.retrieveCategories()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }


    // MARK: - IBActions & Navbar
    
    func onNavbarCancel(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func onNavbarReset(){
        viewModel.resetFilters()
    }
    
    @IBAction func onSaveFiltersBtn(_ sender: AnyObject) {
        guard viewModel.validateFilters() else { return }
        viewModel.saveFilters()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - FiltersViewModelDelegate

    func vmDidUpdate() {
        collectionView.reloadData()
    }

    func vmForcePriceFix() {
        // make sure the "to price" cell exists
        guard let priceSectionIndex = viewModel.sections.index(of: .price) else { return }
        let indexPath = IndexPath(item: 1,section: priceSectionIndex)
        guard let maxPriceCell = collectionView.cellForItem(at: indexPath) as? FilterPriceCell else { return }
        maxPriceCell.textField.becomeFirstResponder()

        // move to "to price" cell
        collectionView.scrollRectToVisible(priceToCellFrame, animated: false)
    }

    // MARK: FilterDistanceCellDelegate
    
    func filterDistanceChanged(distance: Int) {
        viewModel.currentDistanceRadius = distance
    }

    // MARK: FilterCarInfoYearCellDelegate

    func filterYearChanged(withStartYear startYear: Int?, endYear: Int?) {
        viewModel.carYearStart = startYear
        viewModel.carYearEnd = endYear
    }

    // MARK: FilterPriceCellDelegate

    func priceTextFieldValueChanged(_ value: String?, tag: Int) {
        switch tag {
        case 0:
            viewModel.setMinPrice(value)
        case 1:
            viewModel.setMaxPrice(value)
        default:
            break
        }
    }

    func priceTextFieldValueActive() {
        updateTapRecognizer(true)
    }

    // MARK: - UICollectionViewDelegate & DataSource methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
            switch viewModel.sections[indexPath.section] {
            case .distance:
                return distanceCellSize
            case .categories:
                return categoryCellSize
            case .carsInfo:
                switch indexPath.item {
                case 0, 1:
                    return singleCheckCellSize
                case 2:
                    return yearRangeCellSize
                default:
                    return singleCheckCellSize
                }
            case .sortBy, .within, .location:
                return singleCheckCellSize
            case .price:
                return priceCellSize
            }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewModel.sections[section] {
        case .location:
            return 1
        case .distance:
            return 1
        case .categories:
            return viewModel.numOfCategories
        case .carsInfo:
            return 3
        case .within:
            return viewModel.numOfWithinTimes
        case .sortBy:
            return viewModel.numOfSortOptions
        case .price:
            return  2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {
        
            if (kind == UICollectionElementKindSectionHeader) {
                let cell = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                    withReuseIdentifier: "FilterHeaderCell", for: indexPath)
                guard let headerCell = cell as? FilterHeaderCell else { return UICollectionReusableView() }
                
                let section = viewModel.sections[indexPath.section]
                headerCell.separator.isHidden = indexPath.section == 0
                headerCell.titleLabel.text = section.name
                
                return headerCell
            }
            
            return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            // TODO: Refactor cells into CellDrawer pattern
            switch viewModel.sections[indexPath.section] {
            case .location:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterLocationCell",
                    for: indexPath) as? FilterLocationCell else { return UICollectionViewCell() }
                cell.locationLabel.text = viewModel.place?.fullText(showAddress: false)
                return cell
            case .distance:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterDistanceCell",
                    for: indexPath) as? FilterDistanceCell else { return UICollectionViewCell() }
                cell.delegate = self
                cell.distanceType = viewModel.distanceType
                cell.setupWithDistance(viewModel.currentDistanceRadius)
                return cell
            case .categories:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCategoryCell",
                    for: indexPath) as? FilterCategoryCell else { return UICollectionViewCell() }
                cell.titleLabel.text = viewModel.categoryTextAtIndex(indexPath.row)
                cell.categoryIcon.image = viewModel.categoryIconAtIndex(indexPath.row)
                let colorText = viewModel.categoryColorAtIndex(indexPath.row)
                let colorIcon = viewModel.categoryIconColorAtIndex(indexPath.row)
                cell.categoryIcon.tintColor = colorIcon
                cell.titleLabel.textColor = colorText
                cell.rightSeparator.isHidden = indexPath.row % 2 == 1
                cell.isSelected = viewModel.categorySelectedAtIndex(indexPath.row)
                return cell
            case .carsInfo:
                switch indexPath.item {
                case 0:
                    // make
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCarInfoMakeModelCell",
                                                                        for: indexPath) as? FilterCarInfoMakeModelCell else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = true
                    cell.titleLabel.isEnabled = true
                    cell.titleLabel.text = LGLocalizedString.postCategoryDetailCarMake
                    cell.infoLabel.text = viewModel.currentCarMakeName ?? LGLocalizedString.filtersCarMakeNotSet
                    return cell
                case 1:
                    // Model
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCarInfoMakeModelCell",
                                                                        for: indexPath) as? FilterCarInfoMakeModelCell else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = viewModel.modelCellEnabled
                    cell.titleLabel.isEnabled = viewModel.modelCellEnabled
                    cell.titleLabel.text = LGLocalizedString.postCategoryDetailCarModel
                    cell.infoLabel.text = viewModel.currentCarModelName ?? LGLocalizedString.filtersCarModelNotSet
                    return cell
                case 2:
                    // Year
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCarInfoYearCell",
                                                                        for: indexPath) as? FilterCarInfoYearCell else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = true
                    cell.delegate = self
                    cell.titleLabel.text = LGLocalizedString.postCategoryDetailCarYear
                    cell.drawSlider(withStartingYear: viewModel.carYearStart, endYear: viewModel.carYearEnd)
                    return cell
                default:
                    return UICollectionViewCell()
                }
            case .within:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterSingleCheckCell",
                    for: indexPath) as? FilterSingleCheckCell else { return UICollectionViewCell() }
                cell.titleLabel.text = viewModel.withinTimeNameAtIndex(indexPath.row)
                cell.isSelected = viewModel.withinTimeSelectedAtIndex(indexPath.row)
                cell.bottomSeparator.isHidden = true
                return cell
                
            case .sortBy:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterSingleCheckCell",
                    for: indexPath) as? FilterSingleCheckCell else { return UICollectionViewCell() }
                cell.titleLabel.text = viewModel.sortOptionTextAtIndex(indexPath.row)
                cell.isSelected = viewModel.sortOptionSelectedAtIndex(indexPath.row)
                cell.bottomSeparator.isHidden = indexPath.row != (viewModel.numOfSortOptions - 1)
                return cell
            case .price:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterPriceCell",
                    for: indexPath) as? FilterPriceCell else { return UICollectionViewCell() }
                cell.tag = indexPath.row
                cell.titleLabel.text = indexPath.row == 0 ? LGLocalizedString.filtersPriceFrom :
                    LGLocalizedString.filtersPriceTo
                cell.bottomSeparator.isHidden =  indexPath.row == 0
                cell.topSeparator.isHidden =  indexPath.row != 0
                cell.textField.text = indexPath.row == 0 ? viewModel.minPriceString : viewModel.maxPriceString
                cell.delegate = self
                if indexPath.row == 1 {
                    priceToCellFrame = cell.frame
                }
                return cell
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        switch viewModel.sections[indexPath.section] {
        case .location:
            viewModel.locationButtonPressed()
        case .distance:
            //Do nothing on distance
            break
        case .categories:
            viewModel.selectCategoryAtIndex(indexPath.row)
        case .carsInfo:
            switch indexPath.item {
            case 0:
                // make
                viewModel.makeButtonPressed()
            case 1:
                // Model
                viewModel.modelButtonPressed()
            case 2:
                // Do nothing for year
                break
            default:
                break
            }
        case .within:
            viewModel.selectWithinTimeAtIndex(indexPath.row)
        case .sortBy:
            viewModel.selectSortOptionAtIndex(indexPath.row)
        case .price:
            //Do nothing on price
            break
        }
    }
    

    // MARK: Private methods
    
    private func setupUI(){
        // CollectionView cells
        let categoryNib = UINib(nibName: "FilterCategoryCell", bundle: nil)
        self.collectionView.register(categoryNib, forCellWithReuseIdentifier: "FilterCategoryCell")
        let sortByNib = UINib(nibName: "FilterSingleCheckCell", bundle: nil)
        self.collectionView.register(sortByNib, forCellWithReuseIdentifier: "FilterSingleCheckCell")
        let distanceNib = UINib(nibName: "FilterDistanceCell", bundle: nil)
        self.collectionView.register(distanceNib, forCellWithReuseIdentifier: "FilterDistanceCell")
        let locationNib = UINib(nibName: "FilterLocationCell", bundle: nil)
        self.collectionView.register(locationNib, forCellWithReuseIdentifier: "FilterLocationCell")
        let carMakeModelNib = UINib(nibName: "FilterCarInfoMakeModelCell", bundle: nil)
        self.collectionView.register(carMakeModelNib, forCellWithReuseIdentifier: "FilterCarInfoMakeModelCell")
        let carYearNib = UINib(nibName: "FilterCarInfoYearCell", bundle: nil)
        self.collectionView.register(carYearNib, forCellWithReuseIdentifier: "FilterCarInfoYearCell")
        let headerNib = UINib(nibName: "FilterHeaderCell", bundle: nil)
        self.collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: "FilterHeaderCell")
        let priceNib = UINib(nibName: "FilterPriceCell", bundle: nil)
        self.collectionView.register(priceNib, forCellWithReuseIdentifier: "FilterPriceCell")

        // Navbar
        setNavBarTitle(LGLocalizedString.filtersTitle)
        let cancelButton = UIBarButtonItem(title: LGLocalizedString.commonCancel, style: UIBarButtonItemStyle.plain,
            target: self, action: #selector(FiltersViewController.onNavbarCancel))
        cancelButton.tintColor = UIColor.primaryColor
        self.navigationItem.leftBarButtonItem = cancelButton;
        let resetButton = UIBarButtonItem(title: LGLocalizedString.filtersNavbarReset, style: UIBarButtonItemStyle.plain,
            target: self, action: #selector(FiltersViewController.onNavbarReset))
        resetButton.tintColor = UIColor.primaryColor
        self.navigationItem.rightBarButtonItem = resetButton;
        
        // Cells sizes
        let screenWidth = UIScreen.main.bounds.size.width
        distanceCellSize = CGSize(width: screenWidth, height: 78.0)
        categoryCellSize = CGSize(width: screenWidth * 0.5, height: 50.0)
        singleCheckCellSize = CGSize(width: screenWidth, height: 50.0)
        priceCellSize = CGSize(width: screenWidth, height: 50.0)
        yearRangeCellSize = CGSize(width: screenWidth, height: 100.0)

        // Rounded save button
        saveFiltersBtn.setStyle(.primary(fontSize: .medium))
        saveFiltersBtn.setTitle(LGLocalizedString.filtersSaveButton, for: .normal)

        // hide keyboard on tap
        tapRec = UITapGestureRecognizer(target: self, action: #selector(collectionTapped))
    }

    private func setupRx() {
        var previousKbOrigin: CGFloat = CGFloat.greatestFiniteMagnitude
        keyboardHelper.rx_keyboardOrigin.asObservable().skip(1).distinctUntilChanged().bindNext { [weak self] origin in
            guard let strongSelf = self else { return }
            let viewHeight = strongSelf.view.height
            let animationTime = strongSelf.keyboardHelper.animationTime
            guard viewHeight >= origin else { return }
            self?.saveFiltersBtnContainerBottomConstraint.constant = viewHeight - origin
            UIView.animate(withDuration: Double(animationTime), animations: {
                strongSelf.view.layoutIfNeeded()
            })
            if origin < previousKbOrigin {
                // keyboard is appearing
                strongSelf.collectionView.scrollRectToVisible(strongSelf.priceToCellFrame, animated: false)
            } else if origin > previousKbOrigin {
                self?.updateTapRecognizer(false)
            }
            previousKbOrigin = origin
        }.addDisposableTo(disposeBag)
    }

    private dynamic func collectionTapped() {
        view.endEditing(true)
    }

    private func updateTapRecognizer(_ add: Bool) {
        guard let tapRec = tapRec else { return }
        if let recognizers = collectionView.gestureRecognizers, recognizers.contains(tapRec) {
            collectionView.removeGestureRecognizer(tapRec)
        }
        guard add else { return }
        collectionView.addGestureRecognizer(tapRec)
    }

    private func setAccessibilityIds() {
        collectionView.accessibilityId = .filtersCollectionView
        saveFiltersBtn.accessibilityId = .filtersSaveFiltersButton
        self.navigationItem.rightBarButtonItem?.accessibilityId = .filtersResetButton
        self.navigationItem.leftBarButtonItem?.accessibilityId = .filtersCancelButton
    }
}

extension FiltersViewController: UINavigationControllerDelegate {
        func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController, animated: Bool) {

    }
}
