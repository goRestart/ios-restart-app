//
//  ChatGroupedViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ChatGroupedViewController: BaseViewController, LGViewPagerControllerDataSource, LGViewPagerControllerDelegate {
    // View Model
    var viewModel: ChatGroupedViewModel

    // UI
    var viewPager: LGViewPagerController


    // MARK: - Lifecycle

    convenience init() {
        self.init(viewModel: ChatGroupedViewModel())
    }

    init(viewModel: ChatGroupedViewModel) {
        self.viewModel = viewModel
        self.viewPager = LGViewPagerController()
        super.init(viewModel: viewModel, nibName: nil)

        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    
    // MARK: - LGViewPagerControllerDataSource

    func viewPagerControllerNumberOfTabs(viewPagerController: LGViewPagerController) -> Int {
        return 9
    }

    func viewPagerController(viewPagerController: LGViewPagerController, viewControllerForTabAtIndex index: Int) -> UIViewController {
        return ChatListViewController()
    }

    func viewPagerController(viewPagerController: LGViewPagerController, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString {
        return titleForTabAtIndex(index, selected: false)
    }

    func viewPagerController(viewPagerController: LGViewPagerController, titleForSelectedTabAtIndex index: Int) -> NSAttributedString {
        return titleForTabAtIndex(index, selected: true)
    }


    // MARK: - LGViewPagerControllerDelegate

    func viewPagerController(viewPagerController: LGViewPagerController, willDisplayViewController viewController: UIViewController, atIndex index: Int) {

    }

    func viewPagerController(viewPagerController: LGViewPagerController, didEndDisplayingViewController viewController: UIViewController, atIndex index: Int) {

    }


    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = UIColor.whiteColor()

        viewPager.dataSource = self
        viewPager.delegate = self
        viewPager.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewPager)

        viewPager.reloadData()
    }

    private func setupConstraints() {
        let top = NSLayoutConstraint(item: viewPager, attribute: .Top, relatedBy: .Equal,
            toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)

        let bottom = NSLayoutConstraint(item: viewPager, attribute: .Bottom, relatedBy: .Equal,
            toItem: bottomLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraints([top, bottom])

        let views = ["viewPager": viewPager]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[viewPager]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(hConstraints)
    }

    private func titleForTabAtIndex(index: Int, selected: Bool) -> NSAttributedString {
        let color: UIColor = selected ? StyleHelper.primaryColor : UIColor.blackColor()
        let string = NSMutableAttributedString()
        switch index % 3 {
        case 0:
            string.appendAttributedString(NSAttributedString(string: "BUYING", attributes: [NSForegroundColorAttributeName:color]))
            string.appendAttributedString(NSAttributedString(string: " "))
            string.appendAttributedString(NSAttributedString(string: "(44)", attributes: [NSForegroundColorAttributeName:UIColor.darkGrayColor()]))
        case 1:
            string.appendAttributedString(NSAttributedString(string: "SELLING", attributes: [NSForegroundColorAttributeName:color]))
            string.appendAttributedString(NSAttributedString(string: " "))
            string.appendAttributedString(NSAttributedString(string: "(5)", attributes: [NSForegroundColorAttributeName:UIColor.darkGrayColor()]))
        case 2:
            string.appendAttributedString(NSAttributedString(string: "ARCHIVED", attributes: [NSForegroundColorAttributeName:color]))
            string.appendAttributedString(NSAttributedString(string: " "))
            string.appendAttributedString(NSAttributedString(string: "(11)", attributes: [NSForegroundColorAttributeName:UIColor.darkGrayColor()]))
        default:
            break
        }
        return string
    }
}
