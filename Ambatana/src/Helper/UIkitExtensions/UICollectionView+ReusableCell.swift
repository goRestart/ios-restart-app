import Foundation

extension UICollectionView {
    func register<T>(type: T.Type) where T: UICollectionViewCell, T: ReusableCell {
        register(type, forCellWithReuseIdentifier: type.reusableID)
    }

    func register<T>(types: [T.Type]) where T: UICollectionViewCell, T: ReusableCell {
        types.forEach { register(type: $0) }
    }
}
