//
//  TourPostingViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 13/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TourPostingViewController: BaseViewController {

    @IBOutlet weak var photoContainer: UIView!
    @IBOutlet var cameraCorners: [UIImageView]!

    @IBOutlet var internalMargins: [NSLayoutConstraint]!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    private let viewModel: TourPostingViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(viewModel: TourPostingViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "TourPostingViewController", statusBarStyle: .LightContent,
                   navBarBackgroundStyle: .Transparent(substyle: .Dark))
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setAccesibilityIds()
        setupRx()
    }


    // MARK: - Private

    private func setupUI() {
        titleLabel.text = viewModel.titleText
        subtitleLabel.text = viewModel.subtitleText
        
        okButton.setStyle(.Primary(fontSize: .Medium))
        okButton.setTitle(viewModel.okButtonText, forState: .Normal)

        let tap = UITapGestureRecognizer(target: self, action: #selector(cameraContainerPressed))
        photoContainer.addGestureRecognizer(tap)

        for (index, view) in cameraCorners.enumerate() {
            guard index > 0 else { continue }
            view.transform = CGAffineTransformMakeRotation(CGFloat(Double(index) * M_PI_2))
        }
    }

    private func setupRx() {
        okButton.rx_tap.bindNext { [weak self] in self?.viewModel.okButtonPressed() }.addDisposableTo(disposeBag)
        closeButton.rx_tap.bindNext { [weak self] in self?.viewModel.closeButtonPressed() }.addDisposableTo(disposeBag)
    }

    dynamic private func cameraContainerPressed() {
        viewModel.cameraButtonPressed()
    }
}


// MARK: - Accesibility

private extension TourPostingViewController {
    func setAccesibilityIds() {
        okButton.accessibilityId = .TourPostingOkButton
        closeButton.accessibilityId = .TourPostingCloseButton
    }
}
