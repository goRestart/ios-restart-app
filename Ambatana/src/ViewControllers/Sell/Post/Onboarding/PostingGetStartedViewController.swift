//
//  PostingGetStartedViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 20/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import RxSwift

class PostingGetStartedViewController: BaseViewController {

    private let viewModel: PostingGetStartedViewModel

    private let avatarView: UIImageView = UIImageView()
    private let textContainerView: UIView = UIView()
    private let welcomeLabel: UILabel = UILabel()
    private let infoLabel: UILabel = UILabel()
    private let getStartedButton: UIButton = UIButton(type: .custom)
    private let discardLabel: UILabel = UILabel()

    let disposeBag = DisposeBag()

    // MARK: - Lifecycle
    
    init(viewModel: PostingGetStartedViewModel) {
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
        setupRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarView.setRoundedCorners()
        getStartedButton.setStyle(.primary(fontSize: .big))
    }

    
    // MARK: - UI
    
    private func setupUI() {

        avatarView.layer.borderWidth = 5
        avatarView.layer.borderColor = UIColor.white.cgColor

        welcomeLabel.font = UIFont.postingFlowSelectableItem
        welcomeLabel.textColor = UIColor.grayText
        welcomeLabel.text = viewModel.welcomeText
        welcomeLabel.numberOfLines = 0

        infoLabel.font = UIFont.postingFlowBody
        infoLabel.textColor = UIColor.blackText
        infoLabel.text = viewModel.infoText
        infoLabel.numberOfLines = 0

        getStartedButton.setTitle(viewModel.buttonText, for: .normal)
        getStartedButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)

        discardLabel.font = UIFont.smallBodyFont
        discardLabel.textColor = UIColor.grayLight
        discardLabel.text = viewModel.discardText
        discardLabel.numberOfLines = 0
    }
    
    private func setupConstraints() {

        let textSubviews = [welcomeLabel, infoLabel]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: textSubviews)
        textContainerView.addSubviews(textSubviews)

        welcomeLabel.layout(with: textContainerView)
            .left()
            .right()
            .top()
        welcomeLabel.layout(with: infoLabel).above(by: -20)

        infoLabel.layout(with: textContainerView)
            .left()
            .right()
            .bottom()

        let subviews = [avatarView, textContainerView, getStartedButton, discardLabel]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        view.addSubviews(subviews)

        avatarView.layout().width(100).height(100)
        avatarView.layout(with: view).left(by: 30)
        avatarView.layout(with: textContainerView).above(by: -30)

        textContainerView.layout(with: view)
            .centerX()
            .centerY()
            .left(by: 30)
            .right(by: -30)

        getStartedButton.layout().height(50)
        getStartedButton.layout(with: view)
            .centerX()
            .left(by: 30)
            .right(by: -30)
        getStartedButton.layout(with: discardLabel).above(by: -30)

        discardLabel.layout(with: view)
            .centerX()
            .left(by: 30)
            .right(by: -30)
            .bottom(by: -30)
    }

    private func setupRx() {
        viewModel.userAvatarImage.asObservable().bind { [weak self] image in
                self?.avatarView.image = image
            }.disposed(by: disposeBag)
    }


    @objc private func nextAction() {
        viewModel.nextAction()
    }
    
}
