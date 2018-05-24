import RxSwift
import LGCoreKit
import LGComponents

protocol TaxonomiesViewModelDelegate: BaseViewModelDelegate {}

protocol TaxonomiesDelegate: class {
    func didSelect(taxonomy: Taxonomy)
    func didSelect(taxonomyChild: TaxonomyChild)
}

class TaxonomiesViewModel : BaseViewModel {
    
    weak var delegate: TaxonomiesViewModelDelegate?
    weak var taxonomiesDelegate: TaxonomiesDelegate?
    
    var title: String
    
    let taxonomies: [Taxonomy]
    let tracker: Tracker
    let source: EventParameterTypePage
    let currentTaxonomySelected: Taxonomy?
    let currentTaxonomyChildSelected: TaxonomyChild?
    
    
    // MARK: - LifeCycle
    
    init(taxonomies: [Taxonomy], taxonomySelected: Taxonomy? , taxonomyChildSelected: TaxonomyChild?,
         source: EventParameterTypePage, tracker: Tracker) {
        title = R.Strings.categoriesTitle
        self.taxonomies = taxonomies
        self.currentTaxonomySelected = taxonomySelected
        self.currentTaxonomyChildSelected = taxonomyChildSelected
        self.source = source
        self.tracker = tracker
    }
    
    convenience init(taxonomies: [Taxonomy], taxonomySelected: Taxonomy?, taxonomyChildSelected: TaxonomyChild?, source: EventParameterTypePage) {
        self.init(taxonomies: taxonomies, taxonomySelected: taxonomySelected, taxonomyChildSelected: taxonomyChildSelected, source: source, tracker: TrackerProxy.sharedInstance)
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        let event = TrackerEvent.categoriesStart(source: source)
        tracker.trackEvent(event)
    }
    
    func taxonomySelected(taxonomy: Taxonomy) {
        let event = TrackerEvent.categoriesComplete(keywordName: taxonomy.name, source: source)
        tracker.trackEvent(event)
        taxonomiesDelegate?.didSelect(taxonomy: taxonomy)
        goBack()
    }
    
    func taxonomyChildSelected(taxonomyChild: TaxonomyChild) {
        taxonomiesDelegate?.didSelect(taxonomyChild: taxonomyChild)
        let event = TrackerEvent.categoriesComplete(keywordName: taxonomyChild.name, source: source)
        tracker.trackEvent(event)
        goBack()
    }
    
    private func goBack() {
        delegate?.vmPop()
    }
}

