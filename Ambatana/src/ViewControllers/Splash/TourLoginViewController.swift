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
    
    let viewModel: TourLoginViewModel

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
    
    let completion: (() -> ())?
    
    
    // MARK: - Lifecycle
    
    init(viewModel: TourLoginViewModel, completion: (() -> ())?) {
        self.viewModel = viewModel
        self.completion = completion
        super.init(viewModel: viewModel, nibName: "TourLoginViewController", statusBarStyle: .LightContent,
                   navBarBackgroundStyle: .Transparent)
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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        for orDividerView in orDividerViews {
            lines.append(orDividerView.addBottomBorderWithWidth(1, color: UIColor.white))
        }
    }

    
    // MARK: - UI
    
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
        footerTextView.attributedText = viewModel.attributedLegalText
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
    
    
    // MARK: - Navigation
    
    func openNextStep() {
        switch viewModel.nextStep() {
        case .Notifications:
            openNotificationsTour()
        case .Location:
            openLocationTour()
        case .None:
            close(true)
        }
    }
    
    func close(animated: Bool = false) {
        dismissViewControllerAnimated(animated, completion: completion)
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
    
    
    // MARK: - IBActions
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.openNextStep()
    }

    @IBAction func facebookButtonPressed(sender: AnyObject) {
    }

    @IBAction func googleButtonPressed(sender: AnyObject) {
    }

    @IBAction func emailButtonPressed(sender: AnyObject) {
    }


//    @IBAction func signUpPressed(sender: AnyObject) {
//        let vm = SignUpLogInViewModel(source: .Install, action: .Signup)
//        let vc = SignUpLogInViewController(viewModel: vm)
//        vc.afterLoginAction = { [weak self] in
//            self?.openNextStep()
//        }
//        let nav = UINavigationController(rootViewController: vc)
//        presentViewController(nav, animated: true, completion: nil)
//    }
//    
//    @IBAction func loginPressed(sender: AnyObject) {
//        let vm = SignUpLogInViewModel(source: .Install, action: .Login)
//        let vc = SignUpLogInViewController(viewModel: vm)
//        vc.afterLoginAction = { [weak self] in
//            self?.openNextStep()
//        }
//        let nav = UINavigationController(rootViewController: vc)
//        presentViewController(nav, animated: true, completion: nil)
//    }
//    
//    @IBAction func skipPressed(sender: AnyObject) {
//        openNextStep()
//    }
}


// MARK: - UITextViewDelegate

extension TourLoginViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldInteractWithURL url: NSURL, inRange characterRange: NSRange) -> Bool {
        openInternalUrl(url)
        return false
    }
}
