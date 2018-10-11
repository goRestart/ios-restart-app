import UIKit
import RxSwift
import LGComponents

class ExpressChatViewController: BaseViewController {

    private enum Layout {
        static let cellSeparation: CGFloat = 10
        static let collectionHeight: CGFloat = 250
        static let marginForButtonToKeyboard: CGFloat = 15
        static let moreOptionsButtonHeight: CGFloat = 40
        static let contactSellersButtonTop: CGFloat = 70
    }

    static let collectionCellIdentifier = "ExpressChatCell"

    var viewModel: ExpressChatViewModel

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dontMissLabel: UILabel!
    @IBOutlet weak var contactSellersLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendMessageButton: LetgoButton!
    @IBOutlet weak var dontAskAgainButton: UIButton!

    private let moreOptionsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.icMoreOptions.image, for: .normal)
        button.set(accessibilityId: .expressChatMoreOptionsButton)
        return button
    }()
    @IBOutlet weak var contactSellersButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dontAskAgainButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dontAskAgainButtonHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    let disposeBag = DisposeBag()

    convenience init(viewModel: ExpressChatViewModel) {
        self.init(viewModel: viewModel, keyboardHelper: KeyboardHelper())
    }

    init (viewModel: ExpressChatViewModel, keyboardHelper: KeyboardHelper) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "ExpressChatViewController")
        viewModel.delegate = self
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
        view.backgroundColor = viewModel.hideDontAskAgainButton ? .white : .viewControllerBackground
        closeButton.setImage(R.Asset.CongratsScreenImages.icCloseRed.image, for: .normal)
        scrollView.backgroundColor = .clear
        automaticallyAdjustsScrollViewInsets = false

        dontMissLabel.text = viewModel.dontMissLabelText
        dontMissLabel.font = viewModel.dontMissLabelFont
        dontMissLabel.textAlignment = viewModel.dontMissLabelAlignment

        contactSellersLabel.text = viewModel.contactSellersLabelText

        sendMessageButton.setStyle(.primary(fontSize: .big))
        
        dontAskAgainButton.setTitle(R.Strings.chatExpressDontAskAgainButton.uppercased(), for: .normal)
        dontAskAgainButton.setTitleColor(UIColor.grayText, for: .normal)
        dontAskAgainButton.titleLabel?.font = UIFont.mediumBodyFont

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionViewHeightConstraint.constant = viewModel.productListCount > 2 ?
            Layout.collectionHeight : Layout.collectionHeight/2
        
        collectionView.register(type: ExpressChatCell.self)
        
        collectionView.allowsMultipleSelection = true

        for i in 0...viewModel.productListCount {
            collectionView.selectItem(at: IndexPath(item: i, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        }

        moreOptionsButton.isHidden = true

        if viewModel.hideDontAskAgainButton {
            dontAskAgainButton.isHidden = true
            view.addSubviewForAutoLayout(moreOptionsButton)
            moreOptionsButton.isHidden = false
            setupConstraintsForMoreOptionsButton()
            moreOptionsButton.addTarget(self, action: #selector(openMoreOptionsMenu), for: .touchUpInside)

            contactSellersButtonTopConstraint.constant = Layout.contactSellersButtonTop
            dontAskAgainButtonTopConstraint.constant = 0
            dontAskAgainButtonHeightConstraint.constant = 0
        }
    }

    private func setupConstraintsForMoreOptionsButton() {
        NSLayoutConstraint.activate([
            moreOptionsButton.heightAnchor.constraint(equalToConstant: Layout.moreOptionsButtonHeight),
            moreOptionsButton.widthAnchor.constraint(equalToConstant: Layout.moreOptionsButtonHeight),
            moreOptionsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Metrics.shortMargin),
            moreOptionsButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
            ])
    }

    @objc private func openMoreOptionsMenu() {
        viewModel.openMoreOptionsMenu()
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
        let cellSize = (UIScreen.main.bounds.width - (Layout.cellSeparation*3))/2
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
        cell.configure(with: title, price: price, imageUrl: imageURL)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectItemAtIndex(indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.deselectItemAtIndex(indexPath.item)
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
