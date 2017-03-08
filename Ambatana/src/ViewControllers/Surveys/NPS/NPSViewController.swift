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
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setAccessibilityIds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarHidden(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setStatusBarHidden(false)
    }
    
    func setupUI() {
        npsButtons.forEach {
            $0.rounded = true
            $0.layer.borderColor = UIColor.primaryColor.cgColor
            $0.layer.borderWidth = 1.0
            $0.clipsToBounds = true
            $0.setTitle(String($0.tag), for: .normal)
            $0.setTitleColor(UIColor.primaryColor, for: .normal)
            $0.setTitleColor(UIColor.white, for: .highlighted)
            $0.setBackgroundImage(UIColor.white.imageWithSize(CGSize(width: 1, height: 1)), for: .normal)
            $0.setBackgroundImage(UIColor.primaryColor.imageWithSize(CGSize(width: 1, height: 1)), for: .highlighted)
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
        
        closeButton.setImage(UIImage(named: "navbar_close")?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = UIColor.primaryColor
    }
    
    @IBAction func selectScore(_ sender: AnyObject) {
        guard let score = sender.tag else { return }
        viewModel.vmDidFinishSurvey(score)
        close(sender)
    }
    
    @IBAction func close(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}

extension NPSViewController {
    func setAccessibilityIds() {
        closeButton.accessibilityId = .npsCloseButton
        for button in npsButtons {
            switch button.tag {
            case 1:
                button.accessibilityId = .npsScore1
            case 2:
                button.accessibilityId = .npsScore2
            case 3:
                button.accessibilityId = .npsScore3
            case 4:
                button.accessibilityId = .npsScore4
            case 5:
                button.accessibilityId = .npsScore5
            case 6:
                button.accessibilityId = .npsScore6
            case 7:
                button.accessibilityId = .npsScore7
            case 8:
                button.accessibilityId = .npsScore8
            case 9:
                button.accessibilityId = .npsScore9
            case 10:
                button.accessibilityId = .npsScore10
            default:
                break
            }
        }
    }
}
