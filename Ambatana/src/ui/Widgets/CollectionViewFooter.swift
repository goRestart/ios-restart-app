//
//  CollectionViewFooter.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

enum CollectionViewFooterStatus {
    case loading, error, lastPage
}

class CollectionViewFooter: UICollectionReusableView, ReusableCell {

    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        return activityIndicator
    }()

    let retryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.buttonColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return button
    }()

    var retryButtonBlock: (() -> Void)?
    var status: CollectionViewFooterStatus {
        didSet {
            updateActivityIndicatorWithState()
            updateButtonWithState()
        }
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        self.status = .lastPage
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor.grayBackground

        addSubviewsForAutoLayout([activityIndicator, retryButton])
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            retryButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            retryButton.topAnchor.constraint(equalTo: topAnchor),
            retryButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            retryButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @IBAction func retryButtonPressed(_ sender: UIButton) {
        retryButtonBlock?()
    }

    private func updateActivityIndicatorWithState() {
        switch status {
        case .loading:
            activityIndicator.startAnimating()
        case .error, .lastPage:
            activityIndicator.stopAnimating()
        }
    }

    private func updateButtonWithState() {
        retryButton.isHidden = (status == .loading || status == .lastPage)
        retryButton.setTitle(LGLocalizedString.commonErrorListRetryButton, for: .normal)
    }
}

private extension UIColor {
    static let buttonColor = UIColor(red: 74, green: 74, blue: 74)
}
