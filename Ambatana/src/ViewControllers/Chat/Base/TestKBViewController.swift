//
//  TestKBViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 30/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class TestKBViewController: KeyboardViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var centerLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    private let disposeBag = DisposeBag()

    init(){
        super.init(viewModel: nil, nibName: "TestKBViewController")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mainResponder = textField

        let bottom = NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: keyboardView, attribute: .Top, multiplier: 1, constant: 0)
        view.addConstraint(bottom)

        keyboardChanges.bindNext { [weak self] kbChange in
            self?.centerLabel.text = kbChange.description
        }.addDisposableTo(disposeBag)
    }

    @IBAction func resignTextFieldBtn(sender: AnyObject) {
        textField.resignFirstResponder()
    }
}
