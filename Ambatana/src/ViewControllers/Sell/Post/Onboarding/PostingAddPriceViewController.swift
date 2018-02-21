//
//  PostingAddPriceViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 19/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

class PostingAddPriceViewController: BaseViewController {
    
    private let tempNextButton = UIButton()
    
    private let viewModel: PostingAddPriceViewModel
    
    
    // MARK: - Lifecycle
    
    init(viewModel: PostingAddPriceViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        setupConstraints()
        setupRx()
        //viewModel.createListingAfterUploadingImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //setStatusBarHidden(true)
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        tempNextButton.setTitleColor(.black, for: .normal)
        tempNextButton.setTitle("Next", for: .normal)
        tempNextButton.addTarget(self, action: #selector(openListingPosted), for: .touchUpInside)
        
        viewModel.makePriceView(view: view)
    }
    
    private func setupConstraints() {
        view.addSubview(tempNextButton)
        tempNextButton.translatesAutoresizingMaskIntoConstraints = false
        
        tempNextButton.layout(with: view).fill()
    }
    
    private func setupRx() {
    }
    
    @objc private func openListingPosted() {
        viewModel.openListingPosted()
    }
    
}
