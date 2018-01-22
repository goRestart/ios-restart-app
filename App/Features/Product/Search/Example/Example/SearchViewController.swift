import UIKit
import Search
import Core
import UI
import SnapKit

final class SearchViewController: ViewController {
  
  private let textField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Search games..."
    return textField
  }()
  
  private var searchView = resolver.searchView
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureConstraints()
  }
  
  private func configureUI() {
    view.backgroundColor = .white
    view.addSubview(searchView)
    view.addSubview(textField)
  }
  
  private func configureConstraints() {
    textField.snp.makeConstraints { make in
      make.left.equalTo(view).offset(Margin.medium)
      make.right.equalTo(view).offset(-Margin.medium)
      make.top.equalTo(view).offset(Margin.super)
      make.height.equalTo(30)
    }
    
    searchView.snp.makeConstraints { make in
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.top.equalTo(textField.snp.bottom).offset(Margin.huge)
      make.height.equalTo(150)
    }
  }
  
  override func bindViewModel() {
    searchView.bind(textField: textField)
  }
}
