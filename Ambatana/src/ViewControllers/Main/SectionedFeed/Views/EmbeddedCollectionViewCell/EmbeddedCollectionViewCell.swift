import UIKit

final class EmbeddedCollectionViewCell: UICollectionViewCell {

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = true
        view.showsHorizontalScrollIndicator = false
        view.contentInset = UIEdgeInsets(top: 0,
                                         left: SectionControllerLayout.sectionInset.left,
                                         bottom: 0,
                                         right: SectionControllerLayout.sectionInset.right)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        contentView.addSubviewForAutoLayout(collectionView)
        collectionView.layout(with: contentView).fill()
    }
}

