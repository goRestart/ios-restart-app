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

    @IBOutlet var cameraCorners: [UIImageView]!

    @IBOutlet var internalMargins: [NSLayoutConstraint]!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var incentivesContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var incentivesContainerTop: NSLayoutConstraint!
    @IBOutlet var incentivesImages: [UIImageView]!
    @IBOutlet var incentivesLabels: [UILabel]!
    @IBOutlet var incentivesValues: [UILabel]!

    private static let reducedMargins: CGFloat = 10


    let completion: (() -> ())?
    private let viewModel: TourPostingViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(viewModel: TourPostingViewModel, completion: (() -> ())?) {
        self.viewModel = viewModel
        self.completion = completion
        super.init(viewModel: viewModel, nibName: "TourPostingViewController", statusBarStyle: .LightContent,
                   navBarBackgroundStyle: .Transparent(substyle: .Dark))
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
        viewModel.delegate = self
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
        if viewModel.showIncentives {
            for i in 0 ..< incentivesImages.count {
                incentivesImages[i].image = viewModel.incentiveImageAt(i)
                incentivesLabels[i].text = viewModel.incentiveLabelAt(i)
                incentivesValues[i].text = viewModel.incentiveValueAt(i)
            }
        } else {
            incentivesContainerHeight.constant = 0
            incentivesContainerTop.constant = 0
        }
        okButton.setStyle(.Primary(fontSize: .Medium))
        okButton.setTitle(viewModel.okButtonText, forState: .Normal)

        for (index, view) in cameraCorners.enumerate() {
            guard index > 0 else { continue }
            view.transform = CGAffineTransformMakeRotation(CGFloat(Double(index) * M_PI_2))
        }

        if viewModel.showIncentives && (DeviceFamily.current == .iPhone4 || DeviceFamily.current == .iPhone5) {
            internalMargins.forEach { $0.constant = TourPostingViewController.reducedMargins }
        }
    }

    private func setupRx() {
        okButton.rx_tap.bindNext { [weak self] in self?.viewModel.okButtonPressed() }.addDisposableTo(disposeBag)
        closeButton.rx_tap.bindNext { [weak self] in self?.viewModel.closeButtonPressed() }.addDisposableTo(disposeBag)
    }
}


// MARK: - TourPostingViewModelDelegate

extension TourPostingViewController: TourPostingViewModelDelegate {
    func vmClose() {
        dismissViewControllerAnimated(true, completion: completion)
    }
}


// MARK: - Accesibility

private extension TourPostingViewController {
    func setAccesibilityIds() {
        okButton.accessibilityId = .TourPostingOkButton
        closeButton.accessibilityId = .TourPostingCloseButton
    }
}
