//
//  PromoteBumpView.swift
//  LetGo
//
//  Created by Dídac on 10/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

class PromoteBumpViewController: BaseViewController {

    private var alertView: UIView = UIView()
    private var titleLabel: UILabel = UILabel()
    private var iconView: UIImageView = UIImageView()
    private var sellFasterButton: UIButton = UIButton(type: .custom)
    private var laterButton: UIButton = UIButton(type: .system)

    private weak var viewModel: PromoteBumpViewModel?

    // MARK: - Lifecycle

    required init(viewModel: PromoteBumpViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    // MARK: - Private methods

    private func setupUI() {

//        alpha = 0
//        UIView.animate(withDuration: 0.4, animations: { () -> Void in
//            self.view.alpha = 1
//        })

        alertView.layer.cornerRadius = LGUIKitConstants.alertCornerRadius
        alertView.backgroundColor = UIColor.white

        sellFasterButton.setTitle(viewModel?.sellFasterText, for: .normal)
        sellFasterButton.setStyle(.primary(fontSize: .medium))
        sellFasterButton.addTarget(self, action: #selector(sellFaster), for: .touchUpInside)

        laterButton.setTitle(viewModel?.laterText, for: .normal)
//        laterButton.
        laterButton.addTarget(self, action: #selector(laterPressed), for: .touchUpInside)
    }

//    func setupWithFrame(frame: CGRect) {
//        self.frame = frame
//        setupConstraints()
//    }

    private func setupConstraints() {

        alertView.translatesAutoresizingMaskIntoConstraints = false
        sellFasterButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(alertView)

        alertView.layout().width(200).height(200)
        alertView.layout(with: view).center()

        alertView.addSubview(sellFasterButton)

        sellFasterButton.layout().width(160).height(50)
        sellFasterButton.layout(with: alertView).center()
    }


    // MARK: - Actions

    dynamic func sellFaster() {
        // open product detail & bump
        viewModel?.sellFaster()
//        UIView.animate(withDuration: 0.4, animations: { () -> Void in
//            self.alpha = 0
//        }, completion: { (completed) -> Void in
//            // open product detail & bump
//            self.removeFromSuperview()
//        })
    }

    dynamic func laterPressed() {
        viewModel?.later()
    }
}
