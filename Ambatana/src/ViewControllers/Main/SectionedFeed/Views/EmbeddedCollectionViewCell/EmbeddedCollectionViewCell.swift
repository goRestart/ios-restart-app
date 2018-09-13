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
        view.contentInset = SectionControllerLayout.sectionInset
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        collectionView.setContentOffset(
            CGPoint(x: -1 * SectionControllerLayout.sectionInset.left,
                    y: -1 * SectionControllerLayout.sectionInset.top ),
            animated: false)
    }
}

