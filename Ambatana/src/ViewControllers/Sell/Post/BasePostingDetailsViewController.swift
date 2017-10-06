//
//  BaseRealEstateViewController.swift
//  LetGo
//
//  Created by Juan Iglesias on 04/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

class BasePostingDetailsViewController : BaseViewController, TaxonomiesViewModelDelegate {
    
    private let titleLabel: UILabel = UILabel()
    private let contentView: UIView = UIView()
    private let buttonNext: UIButton = UIButton()
    
    private let viewModel: BasePostingDetailsViewModel
    
    let disposeBag = DisposeBag()
    
    
    // MARK: - LifeCycle
    
    init(viewModel: BasePostingDetailsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        titleLabel.text = viewModel.title
        buttonNext.setTitle("Next", for: .normal)
        
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarHidden(true)
        setupNavigationBar()
    }
    
    // MARK: - UI
    
    private func setupUI() {
        view.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        titleLabel.font = UIFont.headline
        titleLabel.textColor = UIColor.white
        
        buttonNext.setStyle(.postingFlow)
        buttonNext.isEnabled = false
    }
    
    private func setupNavigationBar() {
        setNavBarBackgroundStyle(.transparent(substyle: .dark))
        let closeButton = UIBarButtonItem(image: UIImage(named: "ic_post_close") , style: UIBarButtonItemStyle.plain,
                                          target: self, action: #selector(BasePostingDetailsViewController.closeButtonPressed))
        self.navigationItem.leftBarButtonItem = closeButton
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        buttonNext.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        titleLabel.layout(with: view).fillHorizontal(by: 20)
        titleLabel.layout(with: view).top(by: 60)
        
        view.addSubview(contentView)
        
        contentView.layout(with: titleLabel).below()
        contentView.layout(with: view).fillHorizontal()
        
        view.addSubview(buttonNext)
        buttonNext.layout(with: contentView).below()
        buttonNext.layout().height(55)
        buttonNext.layout(with: view).right(by: -15).bottom(by: -15)
    }
    
    
    // MARK: - UIActions
    
    func closeButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}
