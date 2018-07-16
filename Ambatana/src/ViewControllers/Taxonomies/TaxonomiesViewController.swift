import Foundation
import LGCoreKit
import RxSwift
import LGComponents

class TaxonomiesViewController : BaseViewController, TaxonomiesViewModelDelegate {
    
    private let tableView = TaxonomiesTableView()
    private let viewModel: TaxonomiesViewModel
    
    let disposeBag = DisposeBag()
    
    
    // MARK: - LifeCycle
    
    init(viewModel: TaxonomiesViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        viewModel.delegate = self
        title = viewModel.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
        updateTableView(values: viewModel.taxonomies)
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        view.backgroundColor = UIColor.white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        tableView.layout(with: view).fill()
    }
    
    private func updateTableView(values: [Taxonomy]) {
        tableView.setupTableView(values: values, selectedTaxonomy: viewModel.currentTaxonomySelected,
                                 selectedTaxonomyChild: viewModel.currentTaxonomyChildSelected)
    }
    
    private func setupRx() {
        // Rx to select info
        tableView.taxonomySelection.asObservable().bind { [weak self] taxonomy in
            guard let taxonomy = taxonomy else { return }
            self?.viewModel.taxonomySelected(taxonomy: taxonomy)
            }.disposed(by: disposeBag)
        tableView.taxonomyChildSelection.asObservable().bind { [weak self] taxonomyChild in
            guard let taxonomyChild = taxonomyChild else { return }
            self?.viewModel.taxonomyChildSelected(taxonomyChild: taxonomyChild)
        }.disposed(by: disposeBag)
    }
}
