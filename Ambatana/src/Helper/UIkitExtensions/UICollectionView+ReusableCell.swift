import Foundation

extension UICollectionView {
    func register<T>(type: T.Type) where T: UICollectionViewCell, T: ReusableCell {
        register(type, forCellWithReuseIdentifier: type.reusableID)
    }

    func register<T>(types: [T.Type]) where T: UICollectionViewCell, T: ReusableCell {
        types.forEach { register(type: $0) }
    }
    
    func dequeue<T>(type: T.Type, for indexPath: IndexPath) -> T? where T: UICollectionViewCell, T: ReusableCell {
        return dequeueReusableCell(withReuseIdentifier: type.reusableID, for: indexPath) as? T
    }
}
