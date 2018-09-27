import Foundation
import RxSwift
import LGComponents

final class LGSmokeTestViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, LGSmokeTestViewDelegate {
    
    private let viewModel: LGSmokeTestViewModel
    private let smokeTestView: LGSmokeTestView
    var collectionView: UICollectionView { return smokeTestView.collectionView }

    
    init(viewModel: LGSmokeTestViewModel) {
        self.viewModel = viewModel
        self.smokeTestView = LGSmokeTestView(acceptButtonTitle: viewModel.actionTitle)
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() {
        self.view = smokeTestView
        smokeTestView.delegate = self
    }
    
    override func viewDidLoad() {
        collectionView.register(LGSmokeTestCollectionViewCell.self,
                                forCellWithReuseIdentifier: LGSmokeTestCollectionViewCell.reusableID)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        smokeTestView.setNumberOfPages(numberOfPages: viewModel.pagesCount)
        smokeTestView.updateAcceptButton()
        viewModel.startTutorial()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.pagesCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LGSmokeTestCollectionViewCell.reusableID,
                                                            for: indexPath) as? LGSmokeTestCollectionViewCell,
            let page = viewModel.page(at: indexPath.row) else { return UICollectionViewCell() }
        cell.populate(with: page)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        smokeTestView.pageControl.currentPage = smokeTestView.page
        smokeTestView.updateAcceptButton()
    }
    
    func closeButtonPressed() {
        viewModel.didTapCloseButton(onPageNumber: smokeTestView.pageControl.currentPage)
    }
    
    func getStartedButtonPressed() {
        viewModel.didTapStartButton()
    }
}
