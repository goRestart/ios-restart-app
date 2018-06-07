import RxSwift

final class SellNavigationViewModel : BaseViewModel {
    let numberOfSteps = Variable<CGFloat>(0)
    let currentStep = Variable<CGFloat>(0)
    let categorySelected = Variable<PostCategory?>(nil)
    var hideProgressHeader: Observable<Bool> {
        return currentStep.asObservable().map { [weak self] currentStep -> Bool in
            guard let isActive = self?.featureFlags.summaryAsFirstStep.isActive, let totalSteps = self?.totalSteps else {
                return false
            }
            return isActive || currentStep == 0 || currentStep > totalSteps
        }
    }
    private let disposeBag = DisposeBag()

    var shouldModifyProgress: Bool = false
    var hasInitialCategory: Bool = false
    
    let featureFlags: FeatureFlags

    var actualStep: CGFloat {
        return currentStep.value
    }
    
    var totalSteps: CGFloat {
        return numberOfSteps.value
    }
   
    var postingFlowType: PostingFlowType {
        return featureFlags.postingFlowType
    }
    
    init(featureFlags: FeatureFlags) {
        self.featureFlags = featureFlags
        super.init()
        setupRx()
    }
    
    override convenience init() {
        self.init(featureFlags: FeatureFlags.sharedInstance)
    }

    private func setupRx() {
        categorySelected
            .asObservable()
            .map { return $0?.numberOfSteps ?? 1 }
            .bind(to: numberOfSteps)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    func navigationControllerPushed() {
        if shouldModifyProgress {
            currentStep.value = currentStep.value + 1
        }
    }
    
    func navigationControllerPop() {
        if shouldModifyProgress {
            currentStep.value = currentStep.value - 1
        }
    }
}
