import Foundation

extension UITableView {
    func register<T>(type: T.Type) where T: UITableViewCell, T: ReusableCell  {
        self.register(T.self, forCellReuseIdentifier: T.reusableID)
    }
    
    func register<T>(types: [T.Type]) where T: UITableViewCell, T: ReusableCell {
        types.forEach { register(type: $0) }
    }
}
