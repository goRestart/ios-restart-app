import Foundation
import RxSwift
import LGComponents

typealias LGTutorialCell = LGTutorialCollectionViewCell

final class LGTutorialViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, LGTutorialViewDelegate {
    fileprivate struct Identifier {
        static let reusableId = String(describing: LGTutorialCell.self)
    }
    
    let viewModel: LGTutorialViewModel
    let lgTutorialView = LGTutorialView()
    var collectionView: UICollectionView { return lgTutorialView.collectionView }
    var pageCount: Int { return viewModel.pages.count }
    
    init(viewModel: LGTutorialViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() {
        self.view = lgTutorialView
        lgTutorialView.delegate = self
    }
    
    override func viewDidLoad() {
        collectionView.register(LGTutorialCollectionViewCell.self, forCellWithReuseIdentifier: Identifier.reusableId)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lgTutorialView.setNumberOfPages(numberOfPages: viewModel.pages.count)
        lgTutorialView.updateAcceptButton()
        viewModel.startTutorial()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.reusableId,
                                                            for: indexPath) as? LGTutorialCell else { return UICollectionViewCell() }
        cell.populate(with: viewModel.pages[indexPath.row])
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        lgTutorialView.pageControl.currentPage = lgTutorialView.page
        lgTutorialView.updateAcceptButton()
    }
    
    func closeButtonPressed() {
        viewModel.trackCloseButtonPressed(pageNumber: lgTutorialView.pageControl.currentPage)
        dismiss(animated: true, completion: nil)
    }
    
    func getStartedButtonPressed() {
        viewModel.trackGetStartedButtonPressed()
        dismiss(animated: true, completion: nil)
    }
}
