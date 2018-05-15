final class MainViewModel {
    weak var navigator: MainViewModelNavigator?

    init() {
    }

    func numberOfItems() -> Int {
        return MainViewModelItem.allValues.count
    }

    func titleForItemAt(index: Int) -> String? {
        guard let item = itemAt(index: index) else { return nil }
        switch item {
        case .fullScreen:
            return "Full Screen"
        }
    }

    func selectItemAt(index: Int) {
        guard let item = itemAt(index: index) else { return }
        switch item {
        case .fullScreen:
            navigator?.openFullScreenLogin()
        }
    }

    private func itemAt(index: Int) -> MainViewModelItem? {
        let items = MainViewModelItem.allValues
        guard 0 <= index && index < items.count else { return nil }
        return items[index]
    }
}

private enum MainViewModelItem {
    case fullScreen

    static let allValues: [MainViewModelItem] = [.fullScreen]
}
