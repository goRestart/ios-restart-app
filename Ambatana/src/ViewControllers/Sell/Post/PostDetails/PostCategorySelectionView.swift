import LGCoreKit
import RxSwift
import UIKit
import LGComponents

final class PostCategorySelectionView: UIView {
    fileprivate let categoryButtonHeight: CGFloat = 55

    fileprivate let titleLabel = UILabel()
    fileprivate let categoriesContainerView = UIView()
    fileprivate let carsCategoryButton = UIButton()
    fileprivate let motorsAndAccessoriesButton = UIButton()
    fileprivate let otherCategoryButton = UIButton()
    fileprivate let realEstateCategoryButton = UIButton()
    fileprivate let servicesCategoryButton = UIButton()
    fileprivate let jobsCategoryButton = UIButton()
    fileprivate let categoriesAvailables: [PostCategory]
    
    fileprivate let disposeBag = DisposeBag()
    
    var selectedCategory: Observable<PostCategory> {
        return selectedCategoryPublishSubject.asObservable()
    }
    fileprivate let selectedCategoryPublishSubject = PublishSubject<PostCategory>()
    private let featureFlags: FeatureFlaggeable
    
    // MARK: - Lifecycle
    
    init(categoriesAvailables: [PostCategory],
         featureFlags: FeatureFlaggeable) {
        self.categoriesAvailables = categoriesAvailables
        self.featureFlags = featureFlags
        super.init(frame: CGRect.zero)
        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Private methods

fileprivate extension PostCategorySelectionView {
    
    func addButton(button: UIButton, title: String, image: UIImage, postCategoryLink: PostCategory) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemBoldFont(size: 23)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.whiteTextHighAlpha, for: .highlighted)
        button.setImage(image, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.bigMargin, bottom: 0, right: 0)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.contentHorizontalAlignment = .left
        button.rx.tap.subscribeNext { [weak self] in
            self?.selectedCategoryPublishSubject.onNext(postCategoryLink)
            }.disposed(by: disposeBag)
        categoriesContainerView.addSubview(button)
    }
    
    func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemSemiBoldFont(size: 17)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.text = R.Strings.productPostSelectCategoryTitle
        addSubview(titleLabel)
        
        categoriesContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(categoriesContainerView)
        
        categoriesAvailables.forEach { (category) in
            switch category {
            case .car:
                addButton(button: carsCategoryButton,
                          title: R.Strings.productPostSelectCategoryCars,
                          image: R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesCarsInactive.image,
                          postCategoryLink: .car)
            case .otherItems:
                addButton(button: otherCategoryButton,
                          title: R.Strings.productPostSelectCategoryOther,
                          image: R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesOthersInactive.image,
                          postCategoryLink: .otherItems(listingCategory: nil))
            case .motorsAndAccessories:
                addButton(button: motorsAndAccessoriesButton,
                          title: R.Strings.productPostSelectCategoryMotorsAndAccessories,
                          image: R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesMotorsInactive.image,
                          postCategoryLink: .motorsAndAccessories)
            case .realEstate:
                
                addButton(button: realEstateCategoryButton,
                          title: R.Strings.productPostSelectCategoryHousing,
                          image: R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesRealestateInactive.image,
                          postCategoryLink: .realEstate)
            case .services:
                addButton(button: servicesCategoryButton,
                          title: R.Strings.productPostSelectCategoryServices,
                          image: R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesServicesInactive.image,
                          postCategoryLink: .services)
            case .jobs:
                addButton(button: jobsCategoryButton,
                          title: R.Strings.productPostSelectCategoryJobs,
                          image: R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesJobsInactive.image,
                          postCategoryLink: .jobs)
            }
        }
    }
    
    func setupAccessibilityIds() {
        carsCategoryButton.set(accessibilityId: .postingCategorySelectionCarsButton)
        motorsAndAccessoriesButton.set(accessibilityId: .postingCategorySelectionMotorsAndAccessoriesButton)
        otherCategoryButton.set(accessibilityId: .postingCategorySelectionOtherButton)
        realEstateCategoryButton.set(accessibilityId: .postingCategorySelectionRealEstateButton)
        servicesCategoryButton.set(accessibilityId: .postingCategorySelectionServicesButton)
        jobsCategoryButton.set(accessibilityId: .postingCategorySelectionJobsButton)
    }
    
    func setupLayout() {
        titleLabel.layout(with: self)
            .leading(by: Metrics.margin)
            .trailing(by: -Metrics.margin)
            .top(by: 14)
        
        categoriesContainerView.layout(with: self)
            .fillHorizontal()
            .centerY()

        var lastButton: UIView?
        for categoryButton in categoriesContainerView.subviews {
            categoryButton.layout()
                .height(categoryButtonHeight)
            categoryButton.layout(with: categoriesContainerView)
                .fillHorizontal(by: Metrics.bigMargin)
            if let lastButton = lastButton {
                lastButton.layout(with: categoryButton)
                    .above(by: -Metrics.bigMargin)
            } else {
                categoryButton.layout(with: categoriesContainerView)
                    .top()
            }
            lastButton = categoryButton
        }

        if let lastButton = lastButton {
            lastButton.layout(with: categoriesContainerView).bottom()
        }
    }
}

