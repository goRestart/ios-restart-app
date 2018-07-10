import UIKit
import RxSwift
import LGComponents

private typealias FullCollectionViewDelegate = UICollectionViewDataSource & UICollectionViewDelegate
private typealias FullLayoutDelegate = FullCollectionViewDelegate & UICollectionViewDelegateFlowLayout

final class FiltersViewController: BaseViewController, FiltersViewModelDelegate, FilterDistanceSliderDelegate,
FilterPriceCellDelegate, FilterRangePriceCellDelegate, FilterCarInfoYearCellDelegate, FullLayoutDelegate {
    
    private struct Layout {
        static let distanceHeight: CGFloat = 78.0
        static let categoryHeight: CGFloat = 50.0
        static let singleCheckHeight: CGFloat = 50.0
        static let singleCheckWithMarginHeight: CGFloat = 62.0
        static let pricesHeight: CGFloat = 50.0
        static let yearHeight: CGFloat = 90.0
        static let mileageHeight: CGFloat = 90.0
        static let numberOfSeatsHeight: CGFloat = 90.0
        static let saveButtonContainerHeight: CGFloat = 76.0
        static let defaultCellSize: CGSize = CGSize(width: 50,
                                                    height: 50)
        static let minimumInterItemSpacing: CGFloat = 0
        static let minimumLineSpacing: CGFloat = 0
    }
    
    // Outlets & buttons
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = Layout.defaultCellSize
        layout.minimumInteritemSpacing = Layout.minimumInterItemSpacing
        layout.minimumLineSpacing = Layout.minimumLineSpacing
        layout.headerReferenceSize = Layout.defaultCellSize
        
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    private let saveFiltersBtn: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .medium))
        button.setTitle(R.Strings.filtersSaveButton, for: .normal)
        
        return button
    }()

    private let saveFiltersBtnContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .grayBackground
        
        return view
    }()
    
    var saveFiltersBtnContainerBottomConstraint: NSLayoutConstraint?
    
    // ViewModel
    private let viewModel: FiltersViewModel
    private let keyboardHelper: KeyboardHelper
    private var tapRec: UITapGestureRecognizer?

    // Price kb scroll
    private var priceToCellFrame: CGRect = CGRect.zero

    let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle
    
    convenience init(viewModel: FiltersViewModel) {
        self.init(viewModel: viewModel,
                  keyboardHelper: KeyboardHelper())
    }
    
    init(viewModel: FiltersViewModel,
         keyboardHelper: KeyboardHelper) {
        self.keyboardHelper = keyboardHelper
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel,
                   nibName: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupRx()
        setAccessibilityIds()
        viewModel.retrieveCategories()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
}


// MARK:- Actions
extension FiltersViewController {
    
    @objc private func collectionTapped() {
        view.endEditing(true)
    }
    
    @objc func onNavbarCancel() {
        viewModel.close()
    }
    
    @objc func onNavbarReset() {
        resignFirstResponder()
        viewModel.resetFilters()
    }
    
    @objc func didTapSaveFiltersButton() {
        guard viewModel.validateFilters() else { return }
        viewModel.saveFilters()
        viewModel.close()
    }
    
    private func updateSaveFiltersContainerBottomConstraint(forOrigin origin: CGFloat) {
        let previousKbOrigin: CGFloat = CGFloat.greatestFiniteMagnitude

        guard view.height >= origin else { return }
        
        self.saveFiltersBtnContainerBottomConstraint?.constant = -(view.height - origin)
        UIView.animate(withDuration: Double(keyboardHelper.animationTime),
                       animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
        
        if origin < previousKbOrigin {
            // keyboard is appearing
            collectionView.scrollRectToVisible(priceToCellFrame,
                                               animated: false)
        } else if origin > previousKbOrigin {
            updateTapRecognizer(false)
        }
    }
}


// MARK:- Setup Methods

extension FiltersViewController {
    
    private func setupRx() {
        keyboardHelper
            .rx_keyboardOrigin
            .asObservable()
            .skip(1)
            .distinctUntilChanged()
            .bind { [weak self] origin in
                self?.updateSaveFiltersContainerBottomConstraint(forOrigin: origin)
            }.disposed(by: disposeBag)
    }
    
    private func setupUI(){
        setupCollectionView()
        setupNavigationBar()
        view.backgroundColor = .grayBackground
        saveFiltersBtn.addTarget(self,
                                 action: #selector(didTapSaveFiltersButton),
                                 for: UIControlEvents.touchUpInside)
        tapRec = UITapGestureRecognizer(target: self, action: #selector(collectionTapped))
    }
    
    private func setupConstraints() {
        view.addSubviewsForAutoLayout([collectionView, saveFiltersBtnContainer])
        saveFiltersBtnContainer.addSubviewForAutoLayout(saveFiltersBtn)
        
        saveFiltersBtnContainerBottomConstraint = saveFiltersBtnContainer.bottomAnchor
            .constraint(equalTo: safeBottomAnchor)
        saveFiltersBtnContainerBottomConstraint?.isActive = true
        collectionView.topAnchor.constraint(equalTo: safeTopAnchor).isActive = true

        collectionView.layout(with: view).fillHorizontal()
        collectionView.layout(with: saveFiltersBtnContainer).bottom()
        
        saveFiltersBtnContainer.layout(with: view).fillHorizontal()
        saveFiltersBtnContainer.layout().height(Layout.saveButtonContainerHeight)
        
        saveFiltersBtn.layout(with: saveFiltersBtnContainer).fillHorizontal(by: Metrics.margin)
        saveFiltersBtn.layout(with: saveFiltersBtnContainer).fillVertical(by: Metrics.margin)
    }
    
    private func setupCollectionView() {
        collectionView.register(type: FilterCategoryCell.self)
        collectionView.register(type: FilterSingleCheckCell.self)
        collectionView.register(type: FilterDistanceCell.self)
        collectionView.register(type: FilterDisclosureCell.self)
        collectionView.register(type: FilterSliderYearCell.self)
        collectionView.register(type: FilterRangePriceCell.self)
        collectionView.register(type: FilterTextFieldIntCell.self)
        collectionView.register(type: FilterFreeCell.self)
        collectionView.register(type: FilterAttributeGridCell.self)
        collectionView.register(type: FilterSliderCell.self)
        
        collectionView.register(FilterHeaderCell.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: FilterHeaderCell.reusableID)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, Layout.saveButtonContainerHeight, 0)
    }
    
    private func setupNavigationBar() {
        setNavBarTitle(R.Strings.filtersTitle)
        let cancelButton = UIBarButtonItem(title: R.Strings.commonCancel, style: UIBarButtonItemStyle.plain,
                                           target: self, action: #selector(FiltersViewController.onNavbarCancel))
        cancelButton.tintColor = .primaryColor
        self.navigationItem.leftBarButtonItem = cancelButton;
        let resetButton = UIBarButtonItem(title: R.Strings.filtersNavbarReset, style: UIBarButtonItemStyle.plain,
                                          target: self, action: #selector(FiltersViewController.onNavbarReset))
        resetButton.tintColor = .primaryColor
        self.navigationItem.rightBarButtonItem = resetButton
    }
    
    private func setAccessibilityIds() {
        collectionView.set(accessibilityId: .filtersCollectionView)
        saveFiltersBtn.set(accessibilityId: .filtersSaveFiltersButton)
        navigationItem.rightBarButtonItem?.set(accessibilityId: .filtersResetButton)
        navigationItem.leftBarButtonItem?.set(accessibilityId: .filtersCancelButton)
    }
}


// MARK: - FiltersViewModelDelegate Implementation

extension FiltersViewController {
    
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
            guard let maxPriceCell = collectionView.cellForItem(at: indexPath) as? FilterTextFieldIntCell else { return }
            maxPriceCell.textField.becomeFirstResponder()
        }
        
        // move to "to price" cell
        collectionView.scrollRectToVisible(priceToCellFrame, animated: false)
    }
    
    func vmForceSizeFix() {
        guard let sizeSectionIndex = viewModel.sections.index(of: .realEstateInfo) else { return }
        let indexPath = IndexPath(item: 5, section: sizeSectionIndex)
        guard let maxSizeCell = collectionView.cellForItem(at: indexPath) as? FilterTextFieldIntCell else { return }
        maxSizeCell.textField.becomeFirstResponder()
        
        // move to "from size" cell
        collectionView.scrollRectToVisible(priceToCellFrame, animated: false)
    }
}


// MARK: FilterDistanceCellDelegate Implementation

extension FiltersViewController {
    
    func filterDistanceChanged(distance: Int) {
        viewModel.currentDistanceRadius = distance
    }
}


// MARK: - FilterPriceCellDelegate Implementation

extension FiltersViewController {
    
    func priceTextFieldValueChanged(_ value: String?, tag: Int) {
        switch tag {
        case TextFieldNumberType.priceFrom.rawValue:
            viewModel.setMinPrice(value)
        case TextFieldNumberType.priceTo.rawValue:
            viewModel.setMaxPrice(value)
        case TextFieldNumberType.sizeFrom.rawValue:
            viewModel.setMinSize(value)
        case TextFieldNumberType.sizeTo.rawValue:
            viewModel.setMaxSize(value)
        default:
            break
        }
    }
    
    func priceTextFieldValueActive() {
        updateTapRecognizer(true)
    }
    
    private func updateTapRecognizer(_ add: Bool) {
        guard let tapRec = tapRec else { return }
        if let recognizers = collectionView.gestureRecognizers, recognizers.contains(tapRec) {
            collectionView.removeGestureRecognizer(tapRec)
        }
        guard add else { return }
        collectionView.addGestureRecognizer(tapRec)
    }
}


// MARK: - FilterCarInfoYearCellDelegate Implementation

extension FiltersViewController {
    
    func filterYearChanged(withStartYear startYear: Int?, endYear: Int?) {
        if let startYear = startYear {
            viewModel.carYearStart = startYear
        }
        if let endYear = endYear {
            viewModel.carYearEnd = endYear
        }
    }
}


// MARK: - UICollectionViewDelegate & DataSource methods

extension FiltersViewController {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.section < viewModel.sections.count else { return .zero }
        switch viewModel.sections[indexPath.section] {
        case .distance:
            return CGSize(width: view.bounds.width, height: Layout.distanceHeight)
        case .categories:
            let viewWidth = view.width
            let width = viewModel.isTaxonomiesAndTaxonomyChildrenInFeedEnabled ? viewWidth : viewWidth * 0.5
            return CGSize(width: width, height: Layout.categoryHeight)
        case .carsInfo:
            let carSection = viewModel.carSections[indexPath.item]
            switch carSection {
            case .dealership:
                return CGSize(width: view.bounds.width, height: Layout.singleCheckWithMarginHeight)
            case .individual, .make, .model:
                return CGSize(width: view.bounds.width, height: Layout.singleCheckHeight)
            case .year:
                return CGSize(width: view.bounds.width, height: Layout.yearHeight)
            case .mileage:
                return CGSize(width: view.bounds.width, height: Layout.mileageHeight)
            case .numberOfSeats:
                return CGSize(width: view.bounds.width, height: Layout.numberOfSeatsHeight)
            case .bodyType, .transmission, .fuelType, .driveTrain:
                let height = viewModel.attributeGridHeight(forCarSection: carSection,
                                                  forContainerWidth: view.bounds.width)
                return CGSize(width: view.bounds.width, height: height)
            }
            
        case .sortBy, .within, .location:
            return CGSize(width: view.bounds.width, height: Layout.singleCheckHeight)
        case .price:
            return CGSize(width: view.bounds.width, height: Layout.pricesHeight)
        case .realEstateInfo:
            let filterRealEstateSection = viewModel.filterRealEstateSections[indexPath.item]
            switch filterRealEstateSection {
            case .propertyType, .numberOfBathrooms, .numberOfBedrooms, .numberOfRooms:
                return CGSize(width: view.bounds.width, height: Layout.singleCheckHeight)
            case .offerTypeRent, .offerTypeSale:
                return CGSize(width: view.bounds.width, height: Layout.singleCheckWithMarginHeight)
            case .sizeFrom, .sizeTo:
                return CGSize(width: view.bounds.width * 0.5, height: Layout.pricesHeight)
            }
        case .servicesInfo:
            return CGSize(width: view.bounds.width, height: Layout.singleCheckHeight)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch viewModel.sections[section] {
        case .location:
            return 1
        case .distance:
            return 1
        case .categories:
            return viewModel.isTaxonomiesAndTaxonomyChildrenInFeedEnabled ? 1 : viewModel.numOfCategories
        case .carsInfo:
            return viewModel.carSections.count
        case .within:
            return viewModel.numOfWithinTimes
        case .sortBy:
            return viewModel.numOfSortOptions
        case .price:
            return viewModel.numberOfPriceRows
        case .realEstateInfo:
            return viewModel.numberOfRealEstateRows
        case .servicesInfo:
            return viewModel.serviceSections.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
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
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            switch viewModel.sections[indexPath.section] {
            case .location:
                guard let cell = collectionView.dequeue(type: FilterDisclosureCell.self,
                                                        for: indexPath) else { return UICollectionViewCell() }
                cell.titleLabel.text = R.Strings.changeLocationTitle
                cell.subtitleLabel.text = viewModel.place?.fullText(showAddress: false)
                return cell
            case .distance:
                guard let cell = collectionView.dequeue(type: FilterDistanceCell.self,
                                                        for: indexPath) else { return UICollectionViewCell() }
                cell.delegate = self
                cell.distanceType = viewModel.distanceType
                cell.setupWithDistance(viewModel.currentDistanceRadius)
                return cell
            case .categories:
                if viewModel.isTaxonomiesAndTaxonomyChildrenInFeedEnabled {
                    guard let cell = collectionView.dequeue(type: FilterDisclosureCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.titleLabel.text = R.Strings.categoriesTitle
                    cell.subtitleLabel.text = viewModel.currentCategoryNameSelected
                    return cell
                } else {
                    guard let cell = collectionView.dequeue(type: FilterCategoryCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
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
                let carSection = viewModel.carSections[indexPath.item]
                switch carSection {
                case .individual:
                    guard let cell = collectionView.dequeue(type: FilterSingleCheckCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.titleLabel.text = viewModel.carCellTitle(section: carSection)
                    cell.isSelected = viewModel.isCarSellerTypeSelected(type: carSection)
                    cell.topSeparator.isHidden = false
                    return cell
                case .dealership:
                    guard let cell = collectionView.dequeue(type: FilterSingleCheckCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.titleLabel.text = viewModel.carCellTitle(section: carSection)
                    cell.isSelected = viewModel.isCarSellerTypeSelected(type: carSection)
                    cell.setMargin(bottom: true)
                    cell.bottomSeparator.isHidden = false
                    return cell
                case .make:
                    guard let cell = collectionView.dequeue(type: FilterDisclosureCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    
                    cell.titleLabel.text = viewModel.carCellTitle(section: carSection)
                    cell.subtitleLabel.text = viewModel.currentCarMakeName ?? R.Strings.filtersCarMakeNotSet
                    cell.topSeparator?.isHidden = false
                    return cell
                case .model:
                    guard let cell = collectionView.dequeue(type: FilterDisclosureCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = viewModel.modelCellEnabled
                    cell.titleLabel.isEnabled = viewModel.modelCellEnabled
                    cell.titleLabel.text = viewModel.carCellTitle(section: carSection)
                    cell.subtitleLabel.text = viewModel.currentCarModelName ?? R.Strings.filtersCarModelNotSet
                    cell.topSeparator?.isHidden = false
                    return cell
                case .year:
                    guard let cell = collectionView.dequeue(type: FilterSliderYearCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.setupSlider(minimumValue: SharedConstants.filterMinCarYear,
                                     maximumValue: Date().year,
                                     minimumValueSelected: viewModel.carYearStart,
                                     maximumValueSelected: viewModel.carYearEnd)
                    cell.delegate = self
                    return cell
                case .mileage, .numberOfSeats:
                    guard let cell = collectionView.dequeue(type: FilterSliderCell.self,
                                                            for: indexPath),
                        let sliderViewModel = viewModel.sliderViewModel(forSection: carSection)
                        else { return UICollectionViewCell() }
                    
                    cell.setup(withViewModel: sliderViewModel,
                               minimumValueSelectedAction: { [weak self] (minValue) in
                                self?.viewModel.didSelectMinimumValue(forSection: carSection,
                                                                      value: minValue)
                        }, maximumValueSelectedAction: { [weak self] (maxValue) in
                            self?.viewModel.didSelectMaximumValue(forSection: carSection,
                                                                  value: maxValue)
                    })
                    return cell
                case .bodyType, .transmission, .fuelType, .driveTrain:
                    guard let cell = collectionView.dequeue(type: FilterAttributeGridCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.setup(withTitle: viewModel.carCellTitle(section: carSection),
                               values: viewModel.carExtrasAttributeItems(forSection: carSection),
                               selectedValues: viewModel.selectedCarExtrasAttributeItems(forSection: carSection),
                               selectionAction: { [weak self] item in
                                self?.viewModel.didSelectItem(item,
                                                              forSection: carSection)
                        }, deselectionAction: { [weak self] item in
                            self?.viewModel.didDeselectItem(item,
                                                            forSection: carSection)
                    })
                    return cell
                }
            case .realEstateInfo:
                let realEstateSection = viewModel.filterRealEstateSections[indexPath.item]
                switch realEstateSection {
                case .propertyType:
                    guard let cell = collectionView.dequeue(type: FilterDisclosureCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = true
                    cell.titleLabel.isEnabled = true
                    cell.titleLabel.text = R.Strings.realEstateTypePropertyTitle
                    cell.subtitleLabel.text = viewModel.currentPropertyTypeName ?? R.Strings.filtersRealEstatePropertyTypeNotSet
                    return cell
                case .offerTypeSale:
                    guard let cell = collectionView.dequeue(type: FilterSingleCheckCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.titleLabel.text = viewModel.offerTypeNameAtIndex(indexPath.row - 1)
                    cell.isSelected = viewModel.isOfferTypeSelectedAtIndex(indexPath.row - 1)
                    cell.topSeparator.isHidden = false
                    cell.bottomSeparator.isHidden = true
                    cell.setMargin(top: true)
                    return cell
                case .offerTypeRent:
                    guard let cell = collectionView.dequeue(type: FilterSingleCheckCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.titleLabel.text = viewModel.offerTypeNameAtIndex(indexPath.row - 1)
                    cell.isSelected = viewModel.isOfferTypeSelectedAtIndex(indexPath.row - 1)
                    cell.topSeparator.isHidden = false
                    cell.bottomSeparator.isHidden = false
                    cell.setMargin(bottom: true)
                    return cell
                case .numberOfBedrooms:
                    guard let cell = collectionView.dequeue(type: FilterDisclosureCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = true
                    cell.titleLabel.isEnabled = true
                    cell.titleLabel.text = R.Strings.realEstateBedroomsTitle
                    cell.subtitleLabel.text = viewModel.currentNumberOfBedroomsName ?? R.Strings.filtersRealEstateBedroomsNotSet
                    cell.topSeparator?.isHidden = false
                    return cell
                case .numberOfBathrooms:
                    guard let cell = collectionView.dequeue(type: FilterDisclosureCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = true
                    cell.titleLabel.isEnabled = true
                    cell.titleLabel.text = R.Strings.realEstateBathroomsTitle
                    cell.subtitleLabel.text = viewModel.currentNumberOfBathroomsName ?? R.Strings.filtersRealEstateBathroomsNotSet
                    return cell
                case .numberOfRooms:
                    guard let cell = collectionView.dequeue(type: FilterDisclosureCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.isUserInteractionEnabled = true
                    cell.titleLabel.isEnabled = true
                    cell.titleLabel.text = R.Strings.realEstateRoomsTitle
                    cell.subtitleLabel.text = viewModel.currentNumberOfRoomsName ?? R.Strings.filtersRealEstateBedroomsNotSet
                    cell.topSeparator?.isHidden = false
                    return cell
                case .sizeFrom, .sizeTo:
                    guard let cell = collectionView.dequeue(type: FilterTextFieldIntCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.tag = realEstateSection == .sizeFrom ? TextFieldNumberType.sizeFrom.rawValue : TextFieldNumberType.sizeTo.rawValue
                    cell.textField.placeholder = SharedConstants.sizeSquareMetersUnit
                    cell.titleLabel.text = realEstateSection == .sizeFrom ? R.Strings.filtersPriceFrom :
                        R.Strings.filtersPriceTo
                    cell.bottomSeparator?.isHidden =  false
                    cell.topSeparator?.isHidden =  false
                    cell.textField.text = realEstateSection == .sizeFrom ? viewModel.minSizeString : viewModel.maxSizeString
                    cell.delegate = self
                    if realEstateSection == .sizeTo {
                        priceToCellFrame = cell.frame
                    }
                    return cell
                }
                
            case .servicesInfo:
                let serviceSection = viewModel.serviceSections[indexPath.item]
                guard let cell = collectionView.dequeue(type: FilterDisclosureCell.self,
                                                        for: indexPath) else { return UICollectionViewCell() }
                cell.titleLabel.text = serviceSection.title
                switch serviceSection {
                case .type:
                    cell.subtitleLabel.text = viewModel.currentServiceTypeName ?? R.Strings.filtersServiceTypeNotSet
                    cell.topSeparator?.isHidden = false
                case .subtype:
                    cell.isUserInteractionEnabled = viewModel.serviceSubtypeCellEnabled
                    cell.titleLabel.isEnabled = viewModel.serviceSubtypeCellEnabled
                    cell.subtitleLabel.text = viewModel.selectedServiceSubtypesDisplayName ?? R.Strings.filtersServiceSubtypeNotSet
                }
                return cell
            case .within:
                guard let cell = collectionView.dequeue(type: FilterSingleCheckCell.self,
                                                        for: indexPath) else { return UICollectionViewCell() }
                cell.titleLabel.text = viewModel.withinTimeNameAtIndex(indexPath.row)
                cell.isSelected = viewModel.withinTimeSelectedAtIndex(indexPath.row)
                cell.bottomSeparator.isHidden = indexPath.row != (viewModel.numOfWithinTimes - 1)
                return cell
                
            case .sortBy:
                guard let cell = collectionView.dequeue(type: FilterSingleCheckCell.self,
                                                        for: indexPath) else { return UICollectionViewCell() }
                cell.titleLabel.text = viewModel.sortOptionTextAtIndex(indexPath.row)
                cell.isSelected = viewModel.sortOptionSelectedAtIndex(indexPath.row)
                cell.bottomSeparator.isHidden = indexPath.row != (viewModel.numOfSortOptions - 1)
                return cell
            case .price:
                if viewModel.isTaxonomiesAndTaxonomyChildrenInFeedEnabled {
                    if indexPath.row == 0 {
                        guard let cell = collectionView.dequeue(type: FilterFreeCell.self,
                                                                for: indexPath) else { return UICollectionViewCell() }
                        cell.bottomSeparator?.isHidden = true
                        cell.topSeparator?.isHidden = false
                        cell.titleLabel.text = R.Strings.filtersSectionPriceFreeTitle
                        cell.delegate = viewModel
                        cell.freeSwitch.setOn(viewModel.isFreeActive, animated: false)
                        return cell
                    } else if indexPath.row == 1 {
                        guard let cell = collectionView.dequeue(type: FilterRangePriceCell.self,
                                                                for: indexPath) else { return UICollectionViewCell() }
                        cell.titleLabelFrom.text = R.Strings.filtersPriceFrom
                        cell.titleLabelTo.text = R.Strings.filtersPriceTo
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
                    guard let cell = collectionView.dequeue(type: FilterTextFieldIntCell.self,
                                                            for: indexPath) else { return UICollectionViewCell() }
                    cell.tag = indexPath.row
                    cell.textField.placeholder = R.Strings.filtersSectionPrice
                    cell.titleLabel.text = indexPath.row == 0 ? R.Strings.filtersPriceFrom :
                        R.Strings.filtersPriceTo
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
            let carSection = viewModel.carSections[indexPath.item]
            switch carSection {
            case .individual, .dealership:
                viewModel.selectCarSeller(section: carSection)
            case .make:
                viewModel.makeButtonPressed()
            case .model:
                viewModel.modelButtonPressed()
            case .year, .bodyType, .transmission, .fuelType, .driveTrain, .mileage, .numberOfSeats:
                break
            }
            
        case .realEstateInfo:
            switch viewModel.filterRealEstateSections[indexPath.item] {
            case .propertyType:
                viewModel.propertyTypeButtonPressed()
            case .offerTypeRent, .offerTypeSale:
                viewModel.selectOfferTypeAtIndex(indexPath.row - 1)
            case .numberOfBedrooms:
                viewModel.numberOfBedroomsPressed()
            case .numberOfBathrooms:
                viewModel.numberOfBathroomsPressed()
            case .numberOfRooms:
                viewModel.numberOfRoomsPressed()
            case .sizeTo, .sizeFrom:
                break
            }
        case .servicesInfo:
            switch viewModel.serviceSections[indexPath.item] {
            case .type:
                viewModel.servicesTypePressed()
            case .subtype:
                viewModel.servicesSubtypePressed()
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
}
