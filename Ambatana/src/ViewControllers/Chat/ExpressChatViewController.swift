import UIKit
import RxSwift
import LGComponents

class ExpressChatViewController: BaseViewController {

    static let collectionCellIdentifier = "ExpressChatCell"
    static let cellSeparation: CGFloat = 10
    static let collectionHeight: CGFloat = 250
    static let marginForButtonToKeyboard: CGFloat = 15

    var viewModel: ExpressChatViewModel

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dontMissLabel: UILabel!
    @IBOutlet weak var contactSellersLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendMessageButton: LetgoButton!
    @IBOutlet weak var dontAskAgainButton: UIButton!

    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    let disposeBag = DisposeBag()

    convenience init(viewModel: ExpressChatViewModel) {
        self.init(viewModel: viewModel, keyboardHelper: KeyboardHelper())
    }

    init (viewModel: ExpressChatViewModel, keyboardHelper: KeyboardHelper) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "ExpressChatViewController")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRX()
        setupAccessibilityIds()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func setupUI() {
        scrollView.backgroundColor = .clear
        automaticallyAdjustsScrollViewInsets = false

        dontMissLabel.text = R.Strings.chatExpressDontMissLabel.uppercased()
        contactSellersLabel.text = R.Strings.chatExpressContactSellersLabel

        sendMessageButton.setStyle(.primary(fontSize: .big))
        
        dontAskAgainButton.setTitle(R.Strings.chatExpressDontAskAgainButton.uppercased(), for: .normal)
        dontAskAgainButton.setTitleColor(UIColor.grayText, for: .normal)
        dontAskAgainButton.titleLabel?.font = UIFont.mediumBodyFont

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionViewHeightConstraint.constant = viewModel.productListCount > 2 ?
            ExpressChatViewController.collectionHeight : ExpressChatViewController.collectionHeight/2
        let cellNib = UINib(nibName: "ExpressChatCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: ExpressChatViewController.collectionCellIdentifier)
        collectionView.allowsMultipleSelection = true

        for i in 0...viewModel.productListCount {
            collectionView.selectItem(at: IndexPath(item: i, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
    }

    func setupRX() {
        viewModel.sendMessageTitle.asObservable().bind(to: sendMessageButton.rx.title(for: .normal)).disposed(by: disposeBag)
        viewModel.sendButtonEnabled.asObservable().bind(to: sendMessageButton.rx.isEnabled).disposed(by: disposeBag)
    }

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeExpressChat(true)
    }

    @IBAction func sendMessageButtonPressed(_ sender: AnyObject) {
        viewModel.sendMessage()
    }

    @IBAction func dontAskAgainButtonPressed(_ sender: AnyObject) {
        viewModel.closeExpressChat(false)
    }
}


extension ExpressChatViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = (UIScreen.main.bounds.width - (ExpressChatViewController.cellSeparation*3))/2
        return CGSize(width: cellSize, height: cellSize)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.productListCount
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: ExpressChatViewController.collectionCellIdentifier,
                                                    for: indexPath) as? ExpressChatCell else {
                                                        return UICollectionViewCell()
        }
        let title = viewModel.titleForItemAtIndex(indexPath.item)
        let imageURL = viewModel.imageURLForItemAtIndex(indexPath.item)
        let price = viewModel.priceForItemAtIndex(indexPath.item)
        cell.configureCellWithTitle(title, imageUrl: imageURL, price: price)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectItemAtIndex(indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.deselectItemAtIndex(indexPath.item)
    }
}


extension ExpressChatViewController: ExpressChatViewModelDelegate {
    func sendMessageSuccess() {

    }
}


extension ExpressChatViewController {
    func setupAccessibilityIds() {
        self.closeButton.set(accessibilityId: .expressChatCloseButton)
        self.collectionView.set(accessibilityId: .expressChatCollection)
        self.sendMessageButton.set(accessibilityId: .expressChatSendButton)
        self.dontAskAgainButton.set(accessibilityId: .expressChatDontAskButton)
   }
}
