//
//  ListingPostedDescriptiveViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 20/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

class ListingPostedDescriptiveViewController: BaseViewController {
    
    private let tempNextButton = UIButton()
    
    private let viewModel: ListingPostedDescriptiveViewModel
    
    
    // MARK: - Lifecycle
    
    init(viewModel: ListingPostedDescriptiveViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        tempNextButton.setTitleColor(.black, for: .normal)
        tempNextButton.setTitle("Next", for: .normal)
        tempNextButton.addTarget(self, action: #selector(closePosting), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        view.addSubview(tempNextButton)
        tempNextButton.translatesAutoresizingMaskIntoConstraints = false
        
        tempNextButton.layout(with: view).fill()
    }
    
    @objc private func closePosting() {
        viewModel.closePosting()
    }
    
}
