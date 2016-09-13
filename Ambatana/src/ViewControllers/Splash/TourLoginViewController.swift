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

    private var lines: [CALayer] = []

    private let signUpViewModel: SignUpViewModel
    private let tourLoginViewModel: TourLoginViewModel
    let completion: (() -> ())?
    
    
    // MARK: - Lifecycle
    
    init(signUpViewModel: SignUpViewModel, tourLoginViewModel: TourLoginViewModel, completion: (() -> ())?) {
        self.signUpViewModel = signUpViewModel
        self.tourLoginViewModel = tourLoginViewModel
        self.completion = completion
        super.init(viewModel: signUpViewModel, nibName: "TourLoginViewController", statusBarStyle: .LightContent,
                   navBarBackgroundStyle: .Transparent(substyle: .Dark))

        self.signUpViewModel.delegate = self
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve

        let closeButton = UIBarButtonItem(image: UIImage(named: "ic_close"), style: .Plain, target: self,
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

    override func viewDidFirstAppear(animated: Bool) {
        setupKenBurns()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupLines()
    }


    // MARK: - IBActions
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        openNextStep()
    }

    @IBAction func facebookButtonPressed(sender: AnyObject) {
        signUpViewModel.logInWithFacebook()
    }

    @IBAction func googleButtonPressed(sender: AnyObject) {
        signUpViewModel.logInWithGoogle()
    }

    @IBAction func emailButtonPressed(sender: AnyObject) {
        let vm = SignUpLogInViewModel(appearance: .Dark, source: .Install, action: .Signup)
        let vc = SignUpLogInViewController(viewModel: vm)
        vc.afterLoginAction = { [weak self] in
            self?.openNextStep()
        }
        let nav = UINavigationController(rootViewController: vc)
        presentViewController(nav, animated: true, completion: nil)
    }
}


// MARK: - UITextViewDelegate

extension TourLoginViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldInteractWithURL url: NSURL, inRange characterRange: NSRange) -> Bool {
        openInternalUrl(url)
        return false
    }
}


// MARK: - SignUpViewModelDelegate

extension TourLoginViewController: SignUpViewModelDelegate {
    func viewModelDidStartLoggingIn(viewModel: SignUpViewModel) {
        showLoadingMessageAlert()
    }

    func viewModeldidFinishLoginIn(viewModel: SignUpViewModel) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.openNextStep()
        }
    }

    func viewModeldidCancelLoginIn(viewModel: SignUpViewModel) {
        dismissLoadingMessageAlert()
    }

    func viewModel(viewModel: SignUpViewModel, didFailLoginIn message: String) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.showAutoFadingOutMessageAlert(message, time: 3)
        }
    }
}


// MARK: - Private UI methods

private extension TourLoginViewController {
    func setupKenBurns() {
        let images: [UIImage] = [
            UIImage(named: "bg_1_new"),
            UIImage(named: "bg_2_new"),
            UIImage(named: "bg_3_new"),
            UIImage(named: "bg_4_new")
            ].flatMap{return $0}
        view.layoutIfNeeded()
        kenBurnsView.animateWithImages(images, transitionDuration: 10, initialDelay: 0, loop: true, isLandscape: true)
    }

    func setupUI() {
        // UI
        kenBurnsView.clipsToBounds = true

        facebookButton.setStyle(.Facebook)
        googleButton.setStyle(.Google)
        orUseEmailLabel.text = LGLocalizedString.tourOrLabel
        orUseEmailLabel.font = UIFont.smallBodyFont
        emailButton.layer.cornerRadius = 10

        footerTextView.textAlignment = .Center
        footerTextView.delegate = self

        // i18n
        claimLabel.text = LGLocalizedString.tourClaimLabel
        facebookButton.setTitle(LGLocalizedString.tourFacebookButton, forState: .Normal)
        googleButton.setTitle(LGLocalizedString.tourGoogleButton, forState: .Normal)
        emailButton.setTitle(LGLocalizedString.tourEmailButton, forState: .Normal)
        footerTextView.attributedText = signUpViewModel.attributedLegalText
    }

    private func adaptConstraintsToiPhone4() {
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
}


// MARK: - Private Navigation methods

private extension TourLoginViewController {
    func openNextStep() {
        switch tourLoginViewModel.nextStep() {
        case .Notifications:
            openNotificationsTour()
        case .Location:
            openLocationTour()
        case .None:
            close(true)
        }
    }

    func openNotificationsTour() {
        PushPermissionsManager.sharedInstance.showPrePermissionsViewFrom(self, type: .Onboarding) { [weak self] in
            self?.close()
        }

        UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.alpha = 0
        }, completion: nil)
    }

    func openLocationTour() {
        let vm = TourLocationViewModel(source: .Install)
        let vc = TourLocationViewController(viewModel: vm)
        vc.completion = { [weak self] in
            self?.close(false)
        }
        presentStep(vc)
    }

    func presentStep(vc: UIViewController) {
        UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.alpha = 0
        }, completion: nil)
        presentViewController(vc, animated: true, completion: nil)
    }

    func close(animated: Bool = false) {
        dismissViewControllerAnimated(animated, completion: completion)
    }
}
