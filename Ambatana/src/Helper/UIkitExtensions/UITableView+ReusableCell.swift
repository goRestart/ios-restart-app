import Foundation

extension UITableView {
    func register<T>(type: T.Type) where T: UITableViewCell, T: ReusableCell  {
        self.register(T.self, forCellReuseIdentifier: T.reusableID)
    }
    
    func register<T>(types: [T.Type]) where T: UITableViewCell, T: ReusableCell {
        types.forEach { register(type: $0) }
    }

    func dequeue<T>(type: T.Type, for indexPath: IndexPath) -> T? where T: UITableViewCell, T: ReusableCell {
        return dequeueReusableCell(withIdentifier: type.reusableID, for: indexPath) as? T
    }
}
