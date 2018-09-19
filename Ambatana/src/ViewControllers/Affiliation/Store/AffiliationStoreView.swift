import LGComponents

private enum Layout {
    static let interItemSpacing: CGFloat = 35
    static let aspect: CGFloat = 0.74
    enum Height {
        static let separator: CGFloat = 1
        static let buttonHeight: CGFloat = 50
    }
    static let separatorTop: CGFloat = 2
}

final class AffiliationStoreView: UIView {

    let viewHistoryButton: UIButton = {
        let button = LetgoButton(withStyle: ButtonStyle.link(fontSize: .medium))
        button.setTitle(R.Strings.affiliationStoreViewHistory, for: .normal)
        return button
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .lineGray
        return view
    }()

    var collectionTop: NSLayoutConstraint? = nil

    private static let flowLayout: UICollectionViewFlowLayout = {
        let flow = UICollectionViewFlowLayout.init()
        flow.minimumInteritemSpacing = Layout.interItemSpacing
        flow.scrollDirection = .vertical

        let width = min(UIScreen.main.bounds.width - 2*Metrics.bigMargin - 2, 325)
        let height = Layout.aspect * width
        flow.itemSize = CGSize(width: width, height: height)

        flow.sectionInset = UIEdgeInsetsMake(Metrics.bigMargin, Metrics.bigMargin, Metrics.bigMargin, Metrics.bigMargin)
        return flow
    }()

    let collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: AffiliationStoreView.flowLayout)
        if #available(iOS 11.0, *) {
            collection.contentInsetAdjustmentBehavior = .never
        }
        collection.contentInset = .zero
        return collection
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    private func setupUI() {
        backgroundColor = .white
        collectionView.backgroundColor = .white

        let collectionTop = collectionView.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.veryBigMargin)
        addSubviewsForAutoLayout([viewHistoryButton, separator, collectionView])
        [
            viewHistoryButton.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.margin),
            viewHistoryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.veryBigMargin),
            viewHistoryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.veryBigMargin),
            viewHistoryButton.heightAnchor.constraint(equalToConstant: Layout.Height.buttonHeight),

            separator.topAnchor.constraint(equalTo: viewHistoryButton.bottomAnchor, constant: Layout.separatorTop),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2*Metrics.veryBigMargin),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2*Metrics.veryBigMargin),
            separator.heightAnchor.constraint(equalToConstant: Layout.Height.separator),

            collectionTop,
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ].activate()
        self.collectionTop = collectionTop

        collectionView.register(type: AffiliationStoreCell.self)
    }

    func setHistory(enabled: Bool) {
        if enabled {
            let views = Layout.Height.buttonHeight + Layout.Height.separator
            collectionTop?.constant = Metrics.veryBigMargin + views + Metrics.veryShortMargin
        } else {
            collectionTop?.constant = Metrics.veryShortMargin
        }

        separator.alpha = enabled ? 1 : 0
        viewHistoryButton.alpha = enabled ? 1 : 0
    }
}
