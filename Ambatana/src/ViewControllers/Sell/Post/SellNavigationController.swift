//
//  SellNavigationController.swift
//  LetGo
//
//  Created by Juan Iglesias on 03/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import UIKit
import RxSwift


class SellNavigationController: UINavigationController {
    
    static let progressViewHeight: CGFloat = 5
    
    fileprivate let disposeBag: DisposeBag
    
    let progressView = UIView()
    let backgroundProgressView = UIView()
    let numberOfSteps = Variable<CGFloat>(0)
    let categorySelected = Variable<PostCategory?>(nil)
    let currentStep = Variable<CGFloat>(0)
    var shouldModifyProgress: Bool = false
    
    var progressVarFilled: CGFloat {
        guard numberOfSteps.value > 0 else { return 0 }
        return (UIScreen.main.bounds.width/numberOfSteps.value)*currentStep.value
    }
    
    override init(rootViewController: UIViewController) {
        self.disposeBag = DisposeBag()
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.disposeBag = DisposeBag()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isNavigationBarHidden = true
        setupRx()
        setupUI()
    }
    
    func updateBackground(image: UIImage?) {
        guard let image = image else { return }
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        self.view.sendSubview(toBack:blurEffectView)
        
        let background = UIImageView()
        background.image = image
        background.frame = view.bounds
        view.addSubview(background)
        self.view.sendSubview(toBack:background)
    }
    
    func updating(category: PostCategory?) {
        categorySelected.value = category
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        if shouldModifyProgress {
            currentStep.value = currentStep.value + 1
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.progressView.frame = CGRect(x: 0, y: 0, width: strongSelf.progressVarFilled, height: SellNavigationController.progressViewHeight)
                strongSelf.progressView.layoutIfNeeded()
            }
        }
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if shouldModifyProgress {
            currentStep.value = currentStep.value - 1
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.progressView.frame = CGRect(x: 0, y: 0, width: strongSelf.progressVarFilled, height: SellNavigationController.progressViewHeight)
                strongSelf.progressView.layoutIfNeeded()
            }
        }
        return super.popViewController(animated: animated)
    }
    
    
    func setupRx() {
        currentStep.asObservable().map { $0 == 0 }.bindTo(progressView.rx.isHidden).addDisposableTo(disposeBag)
        currentStep.asObservable().map { $0 == 0 }.bindTo(backgroundProgressView.rx.isHidden).addDisposableTo(disposeBag)
        categorySelected.asObservable().map { $0?.numberOfSteps }.bindNext { [weak self] number in
                self?.numberOfSteps.value = number ?? 0
            }.addDisposableTo(disposeBag)
    }
    
    func setupUI() {
        progressView.backgroundColor = UIColor.white
        backgroundProgressView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        progressView.frame = CGRect(x: 0, y: 0, width: progressVarFilled, height: SellNavigationController.progressViewHeight)
        view.addSubview(progressView)
        
        backgroundProgressView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: SellNavigationController.progressViewHeight)
        view.addSubview(backgroundProgressView)
        view.sendSubview(toBack: backgroundProgressView)
    }
}



