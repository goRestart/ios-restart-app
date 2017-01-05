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

final class TourLoginViewController: BaseViewController, GIDSignInUIDelegate {
    @IBOutlet weak var kenBurnsView: JBKenBurnsView!

    @IBOutlet weak var topLogoImage: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var claimLabel: UILabel!
    @IBOutlet weak var claimLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet var orDividerViews: [UIView]!
    @IBOutlet weak var orUseEmailLabel: UILabel!
    @IBOutlet weak var orUseEmailLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailButtonTopContraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var footerTextView: UITextView!
    @IBOutlet weak var footerTextViewBottomConstraint: NSLayoutConstraint!

    fileprivate var lines: [CALayer] = []

    fileprivate let signUpViewModel: SignUpViewModel
    fileprivate let tourLoginViewModel: TourLoginViewModel
    
    
    // MARK: - Lifecycle

    init(signUpViewModel: SignUpViewModel, tourLoginViewModel: TourLoginViewModel) {
        self.signUpViewModel = signUpViewModel
        self.tourLoginViewModel = tourLoginViewModel
        super.init(viewModel: signUpViewModel, nibName: "TourLoginViewController", statusBarStyle: .lightContent,
                   navBarBackgroundStyle: .transparent(substyle: .dark))

        self.signUpViewModel.delegate = self
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve

        let closeButton = UIBarButtonItem(image: UIImage(named: "ic_close"), style: .plain, target: self,
            action: #selector(TourLoginViewController.closeButtonPressed(_:)))
        navigationItem.leftBarButtonItem = closeButton
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
    }

    override func viewDidFirstAppear(_ animated: Bool) {
        setupKenBurns()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupLines()
    }


    // MARK: - IBActions
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        openNextStep()
    }

    @IBAction func facebookButtonPressed(_ sender: AnyObject) {
        signUpViewModel.connectFBButtonPressed()
    }

    @IBAction func googleButtonPressed(_ sender: AnyObject) {
        signUpViewModel.connectGoogleButtonPressed()
    }

    @IBAction func emailButtonPressed(_ sender: AnyObject) {
        signUpViewModel.signUpButtonPressed()
    }
}


// MARK: - UITextViewDelegate

extension TourLoginViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
        openInternalUrl(url)
        return false
    }
}


// MARK: - SignUpViewModelDelegate

extension TourLoginViewController: SignUpViewModelDelegate {
    func vmOpenSignup(_ viewModel: SignUpLogInViewModel) {
        let vc = SignUpLogInViewController(viewModel: viewModel, appearance: .dark, keyboardFocus: true)
        vc.afterLoginAction = { [weak self] in
            self?.openNextStep()
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }

    func vmFinish(completedLogin completed: Bool) {
        openNextStep()
    }

    func vmFinishAndShowScammerAlert(_ contactUrl: URL, network: EventParameterAccountNetwork, tracker: Tracker) {
        // Nothing to do on onboarding. User will notice next time
        openNextStep()
    }
}


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
        emailButton.setStyle(.darkField)
        orUseEmailLabel.text = LGLocalizedString.tourOrLabel
        orUseEmailLabel.font = UIFont.smallBodyFont
        emailButton.layer.cornerRadius = LGUIKitConstants.textfieldCornerRadius

        footerTextView.textAlignment = .center
        footerTextView.delegate = self

        // i18n
        claimLabel.text = LGLocalizedString.tourClaimLabel
        facebookButton.setTitle(LGLocalizedString.tourFacebookButton, for: UIControlState())
        googleButton.setTitle(LGLocalizedString.tourGoogleButton, for: UIControlState())
        emailButton.setTitle(LGLocalizedString.tourEmailButton, for: UIControlState())
        footerTextView.attributedText = signUpViewModel.attributedLegalText
    }

    func adaptConstraintsToiPhone4() {
        claimLabelTopConstraint.constant = 10
        orUseEmailLabelTopConstraint.constant = 10
        emailButtonTopContraint.constant = 10
        mainViewBottomConstraint.constant = 8
        footerTextViewBottomConstraint.constant = 8
    }

    func setupAccessibilityIds() {
        closeButton.accessibilityId = .TourLoginCloseButton
        facebookButton.accessibilityId = .TourFacebookButton
        googleButton.accessibilityId = .TourGoogleButton
        emailButton.accessibilityId = .TourEmailButton
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


// MARK: - Private Navigation methods

fileprivate extension TourLoginViewController {
    func openNextStep() {
        tourLoginViewModel.nextStep()
    }
}
