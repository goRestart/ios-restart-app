//
//  FiltersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

fileprivate typealias FullColectionViewDelegate = UICollectionViewDataSource & UICollectionViewDelegate
fileprivate typealias FullLayoutDelegate = FullColectionViewDelegate & UICollectionViewDelegateFlowLayout

class FiltersViewController: BaseViewController, FiltersViewModelDelegate, FilterDistanceSliderDelegate, FilterPriceCellDelegate,
    FilterRangePriceCellDelegate, FilterCarInfoYearCellDelegate, FullLayoutDelegate {
    struct Layout {
        struct Height {
            static let distance: CGFloat = 78.0
            static let category: CGFloat = 50.0
            static let singleCheck: CGFloat = 50.0
            static let singleCheckWithMargin: CGFloat = 62.0
            static let prices: CGFloat = 50.0
            static let year: CGFloat = 90.0
        }
    }
    // Outlets & buttons
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveFiltersBtn: UIButton!

    @IBOutlet weak var saveFiltersBtnContainer: UIView!
    @IBOutlet weak var saveFiltersBtnContainerBottomConstraint: NSLayoutConstraint!
    
    // ViewModel
    private var viewModel : FiltersViewModel
    private let keyboardHelper: KeyboardHelper
    private var tapRec: UITapGestureRecognizer?

    // Price kb scroll
    private var priceToCellFrame: CGRect = CGRect.zero

    let disposeBag = DisposeBag()

    // MARK: - Lifecycle
    
    convenience init(viewModel: FiltersViewModel) {
        self.init(viewModel: viewModel,
                  nibName: "FiltersViewController",
                  keyboardHelper: KeyboardHelper())
    }
    
    required init(viewModel: FiltersViewModel,
                  nibName nibNameOrNil: String?,
                  keyboardHelper: KeyboardHelper) {
        self.keyboardHelper = keyboardHelper
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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
    
    @objc func onNavbarCancel() {
        viewModel.close()
    }
    
    @objc func onNavbarReset() {
        viewModel.resetFilters()
    }
    
    @IBAction func onSaveFiltersBtn(_ sender: AnyObject) {
        guard viewModel.validateFilters() else { return }
        viewModel.saveFilters()
        viewModel.close()
    }
    
    
    // MARK: - FiltersViewModelDelegate

    func vmDidUpdate() {
        collectionView.reloadData()
    }

    func vmForcePriceFix() {
        // make sure the "to price" cell exists
        guard let priceSectionIndex = viewModel.sections.index(of: .price) else { return }
        let indexPath = IndexPath(item: 1,section: priceSectionIndex)
        if viewModel.isTaxonomiesAndTaxonomyChildrenInFeedEnabled {
            guard let maxPriceCell = collectionView.cellForItem(at: indexPath) as? FilterRangePriceCell else { return }
            maxPriceCell.textFieldTo.becomeFirstResponder()
        } else {
            guard let maxPriceCell = collectionView.cellForItem(at: indexPath) as? FilterPriceCell else { return }
            maxPriceCell.textField.becomeFirstResponder()
        }

        // move to "to price" cell
        collectionView.scrollRectToVisible(priceToCellFrame, animated: false)
    }

    // MARK: FilterDistanceCellDelegate
    
    func filterDistanceChanged(distance: Int) {
        viewModel.currentDistanceRadius = distance
    }

    // MARK: FilterCarInfoYearCellDelegate

    func filterYearChanged(withStartYear startYear: Int?, endYear: Int?) {
        if let startYear = startYear {
            viewModel.carYearStart = startYear
        }
        if let endYear = endYear {
            viewModel.carYearEnd = endYear
        }
    }

    // MARK: FilterPriceCellDelegate

    func priceTextFieldValueChanged(_ value: String?, tag: Int) {
        switch tag {
        case TextFieldPriceType.priceFrom.rawValue:
            viewModel.setMinPrice(value)
        case TextFieldPriceType.priceTo.rawValue:
            viewModel.setMaxPrice(value)
        case TextFieldPriceType.sizeFrom.rawValue:
            viewModel.setMinSize(value)
        case TextFieldPriceType.sizeTo.rawValue:
            viewModel.setMaxSize(value)
        default:
            break
        }
    }

    func priceTextFieldValueActive() {
        updateTapRecognizer(true)
    }

    // MARK: - UICollectionViewDelegate & DataSource methods

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch viewModel.sections[indexPath.section] {
        case .distance:
            return CGSize(width: view.bounds.width, height: Layout.Height.distance)
        case .categories:
            let viewWidth = view.width
            let width = viewModel.isTaxonomiesAndTaxonomyChildrenInFeedEnabled ? viewWidth : viewWidth * 0.5
            return CGSize(width: width, height: Layout.Height.category)
        case .carsInfo:
            switch indexPath.item {
            case 0, 1:
                return CGSize(width: view.bounds.width, height: Layout.Height.singleCheck)
            case 2:
                return CGSize(width: view.bounds.width, height: Layout.Height.year)
            default:
                return CGSize(width: view.bounds.width, height: Layout.Height.singleCheck)
            }
        case .sortBy, .within, .location:
            return CGSize(width: view.bounds.width, height: Layout.Height.singleCheck)
        case .price:
            return CGSize(width: view.bounds.width, height: Layout.Height.prices)
        case .realEstateInfoStandard:
            if indexPath.item == 1 || indexPath.item == 2 {
                return CGSize(width: view.bounds.width, height: Layout.Height.singleCheckWithMargin)
            }
            return CGSize(width: view.bounds.width, height: Layout.Height.singleCheck)
        case .realEstateInfoTurkish:
            if indexPath.item == 1 || indexPath.item == 2 {
                return CGSize(width: view.bounds.width, height: Layout.Height.singleCheckWithMargin)
            }
            if indexPath.item == 4 || indexPath.item == 5 {
                return CGSize(width: view.bounds.width * 0.5, height: Layout.Height.prices)
            }
            return CGSize(width: view.bounds.width, height: Layout.Height.singleCheck)
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
            return viewModel.isTaxonomiesAndTaxonomyChildrenInFeedEnabled ? 1 : viewModel.numOfCategories
        case .carsInfo:
            return 3
        case .within:
            return viewModel.numOfWithinTimes
        case .sortBy:
            return viewModel.numOfSortOptions
        case .price:
            return viewModel.numberOfPriceRows
        case .realEstateInfoStandard:
            return viewModel.numberOfRealEstateRows
        case .realEstateInfoTurkish:
            return viewModel.numberOfRealEstateTurkishRows
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {
        
            if (kind == UICollectionElementKindSectionHeader) {
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                    withReuseIdentifier: FilterHeaderCell.reusableID, for: indexPath)
                guard let headerCell = cell as? FilterHeaderCell else { return UICollectionReusableView() }
                
                let section = viewModel.sections[indexPath.section]
                headerCell.topSeparator?.isHidden = indexPath.section == 0
                headerCell.titleLabel.text = section.name
                
                return headerCell
            }
            
            return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            switch viewModel.sections[indexPath.section] {
            case .location:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDisclosureCell.reusableID,
                    for: indexPath) as? FilterDisclosureCell else { return UICollectionViewCell() }
                cell.titleLabel.text = LGLocalizedString.changeLocationTitle
                cell.subtitleLabel.text = viewModel.place?.fullText(showAddress: false)
                return cell
            case .distance:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDistanceCell.reusableID,
                    for: indexPath) as? FilterDistanceCell else { return UICollectionViewCell() }
                cell.delegate = self
                cell.distanceType = viewModel.distanceType
                cell.setupWithDistance(viewModel.currentDistanceRadius)
                return cell
            case .categories:
                if viewModel.isTaxonomiesAndTaxonomyChildrenInFeedEnabled {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDisclosureCell.reusableID,
                                                                        for: indexPath) as? FilterDisclosureCell else { return UICollectionViewCell() }
                    cell.titleLabel.text = LGLocalizedString.categoriesTitle
                    cell.subtitleLabel.text = viewModel.currentCategoryNameSelected
                    return cell
                } else {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCategoryCell.reusableID,
                                                                        for: indexPath) as? FilterCategoryCell else { return UICollectionViewCell() }
                    cell.titleLabel.text = viewModel.categoryTextAtIndex(indexPath.row)
                    cell.categoryIcon.image = viewModel.categoryIconAtIndex(indexPath.row)
                    let colorText = viewModel.categoryColorAtIndex(indexPath.row)
                    let colorIcon = viewModel.categoryIconColorAtIndex(indexPath.row)
                    cell.categoryIcon.tintColor = colorIcon
                    cell.titleLabel.textColor = colorText
                    cell.rightSeparator?.isHidden = indexPath.row % 2 == 1
                    cell.isSelected = viewModel.categorySelectedAtIndex(indexPath.row)
                    return cell
                }
                
            case .carsInfo:
                switch indexPath.item {
                case 0:
                    // make
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDisclosureCell.reusableID,
                                                                        for: indexPath) as? FilterDisclosureCell else { return UICollectionViewCell() }

                    cell.titleLabel.text = LGLocalizedString.postCategoryDetailCarMake
                    cell.subtitleLabel.text = viewModel.currentCarMakeName ?? LGLocalizedString.filtersCarMakeNotSet
                    return cell
                case 1:
                    // Model
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDisclosureCell.reusableID,
                                                                        for: indexPath) as? FilterDisclosureCell else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = viewModel.modelCellEnabled
                    cell.titleLabel.isEnabled = viewModel.modelCellEnabled
                    cell.titleLabel.text = LGLocalizedString.postCategoryDetailCarModel
                    cell.subtitleLabel.text = viewModel.currentCarModelName ?? LGLocalizedString.filtersCarModelNotSet
                    return cell
                case 2:
                    // Year
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterSliderYearCell.reusableID,
                                                                        for: indexPath) as? FilterSliderYearCell else { return UICollectionViewCell() }
                    cell.setupSlider(minimumValue: Constants.filterMinCarYear, 
                                     maximumValue: Date().year,
                                     minimumValueSelected: viewModel.carYearStart,
                                     maximumValueSelected: viewModel.carYearEnd)
                    cell.delegate = self
                    return cell
                default:
                    return UICollectionViewCell()
                }
            case .realEstateInfoStandard:
                switch indexPath.item {
                case 0:
                    // propertyType
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDisclosureCell.reusableID,
                                                                        for: indexPath) as? FilterDisclosureCell else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = true
                    cell.titleLabel.isEnabled = true
                    cell.titleLabel.text = LGLocalizedString.realEstateTypePropertyTitle
                    cell.subtitleLabel.text = viewModel.currentPropertyTypeName ?? LGLocalizedString.filtersRealEstatePropertyTypeNotSet
                    return cell
                case 1:
                    // For sale option
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterSingleCheckCell.reusableID,
                                                                        for: indexPath) as? FilterSingleCheckCell else { return UICollectionViewCell() }
                    cell.titleLabel.text = viewModel.offerTypeNameAtIndex(indexPath.row - 1)
                    cell.isSelected = viewModel.isOfferTypeSelectedAtIndex(indexPath.row - 1)
                    cell.topSeparator.isHidden = false
                    cell.bottomSeparator.isHidden = true
                    cell.setMargin(top: true)
                    return cell
                case 2:
                    // For rent option
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterSingleCheckCell.reusableID,
                                                                        for: indexPath) as? FilterSingleCheckCell else { return UICollectionViewCell() }
                    cell.titleLabel.text = viewModel.offerTypeNameAtIndex(indexPath.row - 1)
                    cell.isSelected = viewModel.isOfferTypeSelectedAtIndex(indexPath.row - 1)
                    cell.topSeparator.isHidden = false
                    cell.bottomSeparator.isHidden = false
                    cell.setMargin(bottom: true)
                    return cell
                case 3:
                    // Number of bedrooms
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDisclosureCell.reusableID,
                                                                        for: indexPath) as? FilterDisclosureCell else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = true
                    cell.titleLabel.isEnabled = true
                    cell.titleLabel.text = LGLocalizedString.realEstateBedroomsTitle
                    cell.subtitleLabel.text = viewModel.currentNumberOfBedroomsName ?? LGLocalizedString.filtersRealEstateBedroomsNotSet
                    cell.topSeparator?.isHidden = false
                    return cell
                case 4:
                    // Number of bathrooms
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDisclosureCell.reusableID,
                                                                        for: indexPath) as? FilterDisclosureCell else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = true
                    cell.titleLabel.isEnabled = true
                    cell.titleLabel.text = LGLocalizedString.realEstateBathroomsTitle
                    cell.subtitleLabel.text = viewModel.currentNumberOfBathroomsName ?? LGLocalizedString.filtersRealEstateBathroomsNotSet
                    return cell
                default:
                    return UICollectionViewCell()
                }
            case .realEstateInfoTurkish:
                switch indexPath.item {
                case 0:
                    // propertyType
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDisclosureCell.reusableID,
                                                                        for: indexPath) as? FilterDisclosureCell else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = true
                    cell.titleLabel.isEnabled = true
                    cell.titleLabel.text = LGLocalizedString.realEstateTypePropertyTitle
                    cell.subtitleLabel.text = viewModel.currentPropertyTypeName ?? LGLocalizedString.filtersRealEstatePropertyTypeNotSet
                    return cell
                case 1:
                    // For sale option
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterSingleCheckCell.reusableID,
                                                                        for: indexPath) as? FilterSingleCheckCell else { return UICollectionViewCell() }
                    cell.titleLabel.text = viewModel.offerTypeNameAtIndex(indexPath.row - 1)
                    cell.isSelected = viewModel.isOfferTypeSelectedAtIndex(indexPath.row - 1)
                    cell.topSeparator.isHidden = false
                    cell.bottomSeparator.isHidden = true
                    cell.setMargin(top: true)
                    return cell
                case 2:
                    // For rent option
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterSingleCheckCell.reusableID,
                                                                        for: indexPath) as? FilterSingleCheckCell else { return UICollectionViewCell() }
                    cell.titleLabel.text = viewModel.offerTypeNameAtIndex(indexPath.row - 1)
                    cell.isSelected = viewModel.isOfferTypeSelectedAtIndex(indexPath.row - 1)
                    cell.topSeparator.isHidden = false
                    cell.bottomSeparator.isHidden = false
                    cell.setMargin(bottom: true)
                    return cell
                case 3:
                    // Number of rooms
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterDisclosureCell.reusableID,
                                                                        for: indexPath) as? FilterDisclosureCell else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = true
                    cell.titleLabel.isEnabled = true
                    cell.titleLabel.text = LGLocalizedString.realEstateRoomsTitle
                    cell.subtitleLabel.text = viewModel.currentNumberOfBedroomsName ?? LGLocalizedString.filtersRealEstateBedroomsNotSet
                    cell.topSeparator?.isHidden = false
                    return cell
                case 4, 5:
                    // price
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterPriceCell.reusableID,
                                                                        for: indexPath) as? FilterPriceCell else { return UICollectionViewCell() }
                    cell.tag = indexPath.row == 4 ? TextFieldPriceType.sizeFrom.rawValue : TextFieldPriceType.sizeTo.rawValue
                    cell.titleLabel.text = indexPath.row == 4 ? LGLocalizedString.filtersPriceFrom :
                        LGLocalizedString.filtersPriceTo
                    cell.bottomSeparator?.isHidden =  false
                    cell.topSeparator?.isHidden =  false
                    cell.textField.text = indexPath.row == 4 ? viewModel.minSizeString : viewModel.maxSizeString
                    cell.delegate = self
                    if indexPath.row == 5 {
                        priceToCellFrame = cell.frame
                    }
                    return cell
                default:
                    return UICollectionViewCell()
                }
            case .within:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterSingleCheckCell.reusableID,
                    for: indexPath) as? FilterSingleCheckCell else { return UICollectionViewCell() }
                cell.titleLabel.text = viewModel.withinTimeNameAtIndex(indexPath.row)
                cell.isSelected = viewModel.withinTimeSelectedAtIndex(indexPath.row)
                cell.bottomSeparator.isHidden = indexPath.row != (viewModel.numOfWithinTimes - 1)
                return cell
                
            case .sortBy:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterSingleCheckCell.reusableID,
                    for: indexPath) as? FilterSingleCheckCell else { return UICollectionViewCell() }
                cell.titleLabel.text = viewModel.sortOptionTextAtIndex(indexPath.row)
                cell.isSelected = viewModel.sortOptionSelectedAtIndex(indexPath.row)
                cell.bottomSeparator.isHidden = indexPath.row != (viewModel.numOfSortOptions - 1)
                return cell
            case .price:
                if viewModel.isTaxonomiesAndTaxonomyChildrenInFeedEnabled {
                    if indexPath.row == 0 {
                        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterFreeCell.reusableID,
                                                                            for: indexPath) as? FilterFreeCell else { return UICollectionViewCell() }
                        cell.bottomSeparator?.isHidden = true
                        cell.topSeparator?.isHidden = false
                        cell.titleLabel.text = LGLocalizedString.filtersSectionPriceFreeTitle
                        cell.delegate = viewModel
                        cell.freeSwitch.setOn(viewModel.isFreeActive, animated: false)
                        return cell
                    } else if indexPath.row == 1 {
                        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterRangePriceCell.reusableID,
                                                                            for: indexPath) as? FilterRangePriceCell else { return UICollectionViewCell() }
                        cell.titleLabelFrom.text = LGLocalizedString.filtersPriceFrom
                        cell.titleLabelTo.text = LGLocalizedString.filtersPriceTo
                        cell.bottomSeparator?.isHidden =  false
                        cell.topSeparator?.isHidden =  false
                        cell.textFieldFrom.text = viewModel.minPriceString
                        cell.textFieldTo.text = viewModel.maxPriceString
                        cell.delegate = self
                        return cell
                    } else {
                        return UICollectionViewCell()
                    }
                } else {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterPriceCell.reusableID,
                                                                        for: indexPath) as? FilterPriceCell else { return UICollectionViewCell() }
                    cell.tag = indexPath.row
                    cell.titleLabel.text = indexPath.row == 0 ? LGLocalizedString.filtersPriceFrom :
                        LGLocalizedString.filtersPriceTo
                    cell.bottomSeparator?.isHidden =  indexPath.row == 0
                    cell.topSeparator?.isHidden =  indexPath.row != 0
                    cell.textField.text = indexPath.row == 0 ? viewModel.minPriceString : viewModel.maxPriceString
                    cell.delegate = self
                    if indexPath.row == 1 {
                        priceToCellFrame = cell.frame
                    }
                    return cell
                }
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
            if viewModel.isTaxonomiesAndTaxonomyChildrenInFeedEnabled {
                viewModel.categoriesButtonPressed()
            } else {
                viewModel.selectCategoryAtIndex(indexPath.row)
            }
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
        case .realEstateInfoStandard:
            switch indexPath.item {
            case 0:
                // propertyType
                viewModel.propertyTypeButtonPressed()
            case 1:
                // for sale
                viewModel.selectOfferTypeAtIndex(indexPath.row - 1)
            case 2:
                // for rent
                viewModel.selectOfferTypeAtIndex(indexPath.row - 1)
            case 3:
                // bedrooms
                viewModel.numberOfBedroomsPressed()
            case 4:
                // bathrooms
                viewModel.numberOfBathroomsPressed()
            default:
                break
            }
        case .realEstateInfoTurkish:
            switch indexPath.item {
            case 0:
                // propertyType
                viewModel.propertyTypeButtonPressed()
            case 1:
                // for sale
                viewModel.selectOfferTypeAtIndex(indexPath.row - 1)
            case 2:
                // for rent
                viewModel.selectOfferTypeAtIndex(indexPath.row - 1)
            case 3:
                // bedrooms
                viewModel.numberOfBedroomsPressed()
            case 4:
                // price
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
        collectionView.register(FilterCategoryCell.self, forCellWithReuseIdentifier: FilterCategoryCell.reusableID)
        collectionView.register(FilterSingleCheckCell.self, forCellWithReuseIdentifier: FilterSingleCheckCell.reusableID)
        collectionView.register(FilterDistanceCell.self, forCellWithReuseIdentifier: FilterDistanceCell.reusableID)
        collectionView.register(FilterDisclosureCell.self, forCellWithReuseIdentifier: FilterDisclosureCell.reusableID)
        collectionView.register(FilterSliderYearCell.self, forCellWithReuseIdentifier: FilterSliderYearCell.reusableID)
        collectionView.register(FilterHeaderCell.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: FilterHeaderCell.reusableID)
        collectionView.register(FilterRangePriceCell.self, forCellWithReuseIdentifier: FilterRangePriceCell.reusableID)
        collectionView.register(FilterPriceCell.self, forCellWithReuseIdentifier: FilterPriceCell.reusableID)
        collectionView.register(FilterFreeCell.self, forCellWithReuseIdentifier: FilterFreeCell.reusableID)

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

        // Rounded save button
        saveFiltersBtn.setStyle(.primary(fontSize: .medium))
        saveFiltersBtn.setTitle(LGLocalizedString.filtersSaveButton, for: .normal)

        // hide keyboard on tap
        tapRec = UITapGestureRecognizer(target: self, action: #selector(collectionTapped))
    }

    private func setupRx() {
        var previousKbOrigin: CGFloat = CGFloat.greatestFiniteMagnitude
        keyboardHelper.rx_keyboardOrigin.asObservable().skip(1).distinctUntilChanged().bind { [weak self] origin in
            guard let strongSelf = self else { return }
            let viewHeight = strongSelf.view.height
            let animationTime = strongSelf.keyboardHelper.animationTime
            guard viewHeight >= origin else { return }
            self?.saveFiltersBtnContainerBottomConstraint.constant = -(viewHeight - origin)
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
        }.disposed(by: disposeBag)
    }

    @objc private dynamic func collectionTapped() {
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
