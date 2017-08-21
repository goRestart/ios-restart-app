//
//  TourLoginViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import JBKenBurnsView
import LGCoreKit
import RxSwift

final class TourLoginViewController: BaseViewController, GIDSignInUIDelegate {
    @IBOutlet weak var kenBurnsView: JBKenBurnsView!

    @IBOutlet weak var topLogoImage: UIImageView!
    @IBOutlet weak var claimLabel: UILabel!
    @IBOutlet weak var claimLabelTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet var orDividerViews: [UIView]!
    @IBOutlet weak var orUseEmailLabel: UILabel!
    @IBOutlet weak var orUseEmailLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailButtonJustText: UIButton!
    @IBOutlet weak var emailButtonTopContraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var footerTextView: UITextView!
    @IBOutlet weak var footerTextViewBottomConstraint: NSLayoutConstraint!

    fileprivate var lines: [CALayer] = []

    fileprivate let viewModel: TourLoginViewModel
    fileprivate let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle

    init(viewModel: TourLoginViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "TourLoginViewController", statusBarStyle: .lightContent,
                   navBarBackgroundStyle: .transparent(substyle: .dark))

        self.viewModel.delegate = self
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAccessibilityIds()

        if DeviceFamily.current == .iPhone4 {
            adaptConstraintsToiPhone4()
        }
        viewModel.refreshTaxonomiesOnboardingCache()
    }

    override func viewDidFirstAppear(_ animated: Bool) {
        setupKenBurns()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupLines()
    }


    // MARK: - IBActions
    
    @IBAction func facebookButtonPressed(_ sender: AnyObject) {
        viewModel.facebookButtonPressed()
    }

    @IBAction func googleButtonPressed(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().uiDelegate = self
        viewModel.googleButtonPressed()
    }

    @IBAction func emailButtonPressed(_ sender: AnyObject) {
        viewModel.emailButtonPressed()
    }
}


// MARK: - UITextViewDelegate

extension TourLoginViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
        viewModel.textUrlPressed(url: url)
        return false
    }
}


// MARK: TourLoginViewModelDelegate 

extension TourLoginViewController: TourLoginViewModelDelegate {}


// MARK: - Private UI methods

fileprivate extension TourLoginViewController {
    func setupKenBurns() {
        let images: [UIImage] = [
            UIImage(named: "bg_1_new"),
            UIImage(named: "bg_2_new"),
            UIImage(named: "bg_3_new"),
            UIImage(named: "bg_4_new")
            ].flatMap{return $0}
        view.layoutIfNeeded()
        kenBurnsView.animate(withImages: images, transitionDuration: 10, initialDelay: 0, loop: true, isLandscape: true)
    }

    func setupUI() {
        if AdminViewController.canOpenAdminPanel() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(openAdminPanel))
            topLogoImage.addGestureRecognizer(tap)
        }

        // UI
        kenBurnsView.clipsToBounds = true
        
        facebookButton.setStyle(.facebook)
        googleButton.setStyle(.google)
        orUseEmailLabel.text = LGLocalizedString.tourOrLabel
        orUseEmailLabel.font = UIFont.smallBodyFont
        
        emailButtonJustText.isHidden = false

        footerTextView.textAlignment = .center
        footerTextView.delegate = self

        // i18n
        claimLabel.text = LGLocalizedString.tourClaimLabel
        facebookButton.setTitle(LGLocalizedString.tourFacebookButton, for: .normal)
        googleButton.setTitle(LGLocalizedString.tourGoogleButton, for: .normal)
        emailButtonJustText.setTitle(LGLocalizedString.tourContinueWEmail, for: .normal)
        footerTextView.attributedText = viewModel.attributedLegalText
    }

    func adaptConstraintsToiPhone4() {
        claimLabelTopConstraint.constant = 10
        orUseEmailLabelTopConstraint.constant = 10
        emailButtonTopContraint.constant = 10
        mainViewBottomConstraint.constant = 8
        footerTextViewBottomConstraint.constant = 8
    }

    func setupAccessibilityIds() {
        facebookButton.accessibilityId = .tourFacebookButton
        googleButton.accessibilityId = .tourGoogleButton
        emailButtonJustText.accessibilityId = .tourEmailButton
    }

    func setupLines() {
        // Redraw the lines
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        orDividerViews.forEach { lines.append($0.addBottomBorderWithWidth(1, color: UIColor.white)) }
    }

    dynamic func openAdminPanel() {
        guard AdminViewController.canOpenAdminPanel() else { return }
        let admin = AdminViewController()
        let nav = UINavigationController(rootViewController: admin)
        present(nav, animated: true, completion: nil)
    }
}
