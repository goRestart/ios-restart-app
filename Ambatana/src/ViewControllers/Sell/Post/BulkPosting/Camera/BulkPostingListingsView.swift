import LGCoreKit
import LGComponents

final class BulkPostingListingsView: BaseView {

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 18
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 75, height: 75)
        return UICollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 75), collectionViewLayout: layout)
    }()

    private let listingsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()

    var viewModel: BulkPostingListingsViewModel

    init(viewModel: BulkPostingListingsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: CGRect(x: 0, y: 0, width: 300, height: 75))

        setupUI()
        collectionView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
//        NSLayoutConstraint.activate([
//            heightAnchor.constraint(equalToConstant: 100)
//        ])
        listingsLabel.text = "Your items (\(viewModel.listings.count))"

        collectionView.register(BulkPostingCell.self, forCellWithReuseIdentifier: BulkPostingCell.reusableID)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self

        addSubviewsForAutoLayout([listingsLabel, collectionView])
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: listingsLabel.topAnchor),
            leadingAnchor.constraint(equalTo: listingsLabel.leadingAnchor),
            trailingAnchor.constraint(equalTo: listingsLabel.trailingAnchor),

            listingsLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -Metrics.margin),
            leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
}

extension BulkPostingListingsView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.listings.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BulkPostingCell.reusableID, for: indexPath) as? BulkPostingCell else {
            return UICollectionViewCell()
        }
        if let imageURL = viewModel.listings[indexPath.row].thumbnail?.fileURL {
            cell.setupWith(imageURL: imageURL)
        }
        return cell
    }
}
