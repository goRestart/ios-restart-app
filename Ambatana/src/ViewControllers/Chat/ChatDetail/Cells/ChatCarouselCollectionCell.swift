import Foundation
import LGComponents
import LGCoreKit

final class ChatCarouselCollectionCell: UITableViewCell, ReusableCell {
    
    static let topBottomInsetForShadows: CGFloat = 4
    static let bottomMargin: CGFloat = Metrics.shortMargin
    
    private enum Layout {
        static let leftInset = ChatBubbleLayout.avatarSize + ChatBubbleLayout.margin*2
        static let minimumInteritemSpacing: CGFloat = 10.0
    }
    
    weak var delegate: ChatDeeplinkCellDelegate?
    private let collectionView = UICollectionView(frame: CGRect.zero,
                                                  collectionViewLayout: UICollectionViewFlowLayout())
    private var cards: [ChatCarouselCard] = []
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cards = []
    }
    
    // MARK: Setup
    
    private func setupUI() {
        backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.scrollsToTop = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: ChatCarouselCollectionCell.topBottomInsetForShadows,
                                                   left: Layout.leftInset,
                                                   bottom: ChatCarouselCollectionCell.topBottomInsetForShadows,
                                                   right: 0)
        collectionView.register(ChatCarouselCollectionCardCell.self,
                                forCellWithReuseIdentifier: ChatCarouselCollectionCardCell.reusableID)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = UICollectionViewScrollDirection.horizontal
            layout.itemSize = ChatCarouselCollectionCardCell.cellSize
            layout.minimumInteritemSpacing = Layout.minimumInteritemSpacing
        }
    }
    
    private func setupConstraints() {
        contentView.addSubviewForAutoLayout(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ChatCarouselCollectionCell.bottomMargin),
            ])
    }
    
    func set(cards: [ChatCarouselCard]) {
        self.cards = cards
        collectionView.reloadData()
    }
}

extension ChatCarouselCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource {
    private func item(at index: Int) -> ChatCarouselCard? {
        guard cards.indices.contains(index) else { return nil }
        return cards[index]
    }
    
    private func performAction(with data: ChatCarouselCollectionCardCellActionData) {
        guard let deeplinkURL = data.deeplinkURL else { return }
        delegate?.openDeeplink(url: deeplinkURL, trackingKey: data.key)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let card = item(at: indexPath.row),
            let cell = collectionView.dequeue(type: ChatCarouselCollectionCardCell.self, for: indexPath)
            else { return UICollectionViewCell() }
        
        cell.set(card: card)
        cell.buttonAction = { [weak self] in self?.performAction(with: $0) }
        cell.cardAction = { [weak self] in self?.performAction(with: $0) }
        return cell
    }
}
