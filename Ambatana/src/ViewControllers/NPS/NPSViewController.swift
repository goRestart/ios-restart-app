//
//  NPSViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 26/8/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


class NPSViewController: BaseViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var notLikelyLabel: UILabel!
    @IBOutlet weak var extremelyLikelyLabel: UILabel!
    @IBOutlet weak var notLikelyImage: UIImageView!
    @IBOutlet weak var extremelyLikelyImage: UIImageView!
    @IBOutlet var npsButtons: [UIButton]!
    @IBOutlet weak var closeButton: UIButton!
    
    var viewModel: NPSViewModel
    
    init(viewModel: NPSViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "NPSViewController")
        modalPresentationStyle = .OverCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarHidden(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        setStatusBarHidden(false)
    }
    
    func setupUI() {
        npsButtons.forEach {
            $0.layer.cornerRadius = $0.height/2
            $0.layer.borderColor = UIColor.primaryColor.CGColor
            $0.layer.borderWidth = 1.0
            $0.clipsToBounds = true
            $0.setTitle(String($0.tag), forState: .Normal)
            $0.setTitle("\($0.tag)", forState: .Selected)
            $0.setTitleColor(UIColor.primaryColor, forState: .Normal)
            $0.setTitleColor(UIColor.whiteColor(), forState: .Selected)
            $0.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
            $0.setBackgroundImage(UIColor.whiteColor().imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
            $0.setBackgroundImage(UIColor.primaryColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Highlighted)
            $0.titleLabel?.font = UIFont.systemBoldFont(size: 19)
        }
        
        titleLabel.text = LGLocalizedString.npsSurveyTitle
        subtitleLabel.text = LGLocalizedString.npsSurveySubtitle
        notLikelyLabel.text = LGLocalizedString.npsSurveyVeryBad
        extremelyLikelyLabel.text = LGLocalizedString.npsSurveyVeryGood
        notLikelyImage.image = UIImage(named: "nps_bad")
        extremelyLikelyImage.image = UIImage(named: "nps_good")
        
        subtitleLabel.textColor = UIColor.grayDark
        notLikelyLabel.textColor = UIColor.grayDark
        extremelyLikelyLabel.textColor = UIColor.grayDark
        
        closeButton.setImage(UIImage(named: "navbar_close")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        closeButton.tintColor = UIColor.primaryColor
    }
    
    @IBAction func selectScore(sender: AnyObject) {
        guard let score = sender.tag else { return }
        viewModel.vmDidFinishSurvey(score)
        close(sender)
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}