//
//  ListingPostedDescriptiveViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 20/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

class ListingPostedDescriptiveViewController: BaseViewController {

    private let noTitleContainerView = UIView()
    private let listingImage = UIImageView()
    private let noTitleDoneLabel = UILabel()

    private let titleContainerView = UIView()
    private let titleDoneLabel = UILabel()


    private let saveButton = UIButton(type: .custom)
    private let discardButton = UIButton()

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        saveButton.setStyle(.primary(fontSize: .big))
    }

    
    // MARK: - UI
    
    private func setupUI() {

        view.backgroundColor = UIColor.white

        saveButton.setTitle(viewModel.saveButtonText, for: .normal)
        saveButton.addTarget(self, action: #selector(closePosting), for: .touchUpInside)

        discardButton.setTitle(viewModel.discardButtonText, for: .normal)
        discardButton.titleLabel?.font = UIFont.bigButtonFont
        discardButton.setTitleColor(UIColor.grayText, for: .normal)
    }
    
    private func setupConstraints() {
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(discardButton)
        discardButton.translatesAutoresizingMaskIntoConstraints = false

        saveButton.layout().height(60)
        saveButton.layout(with: view)
            .centerX()
            .left(by: 30)
            .right(by: -30)
        saveButton.layout(with: discardButton).above(by: -30)

        discardButton.layout(with: view)
            .centerX()
            .left(by: 30)
            .right(by: -30)
            .bottom(by: -30)
    }
    
    @objc private func closePosting() {
        viewModel.closePosting()
    }
    
}
