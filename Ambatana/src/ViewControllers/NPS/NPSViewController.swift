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
        setAccessibilityIds()
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
            $0.cornerRadius = true
            $0.layer.borderColor = UIColor.primaryColor.CGColor
            $0.layer.borderWidth = 1.0
            $0.clipsToBounds = true
            $0.setTitle(String($0.tag), forState: .Normal)
            $0.setTitleColor(UIColor.primaryColor, forState: .Normal)
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

extension NPSViewController {
    func setAccessibilityIds() {
        closeButton.accessibilityId = .NPSCloseButton
        for button in npsButtons {
            switch button.tag {
            case 1:
                button.accessibilityId = .NPSScore1
            case 2:
                button.accessibilityId = .NPSScore2
            case 3:
                button.accessibilityId = .NPSScore3
            case 4:
                button.accessibilityId = .NPSScore4
            case 5:
                button.accessibilityId = .NPSScore5
            case 6:
                button.accessibilityId = .NPSScore6
            case 7:
                button.accessibilityId = .NPSScore7
            case 8:
                button.accessibilityId = .NPSScore8
            case 9:
                button.accessibilityId = .NPSScore9
            case 10:
                button.accessibilityId = .NPSScore10
            default:
                break
            }
        }
    }
}
