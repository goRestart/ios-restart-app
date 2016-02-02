//
//  ChatGroupedViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ChatGroupedViewController: BaseViewController, LGViewPagerDataSource, LGViewPagerDelegate {
    // View Model
    var viewModel: ChatGroupedViewModel

    // UI
    var viewPager: LGViewPager


    // MARK: - Lifecycle

    convenience init() {
        self.init(viewModel: ChatGroupedViewModel())
    }

    init(viewModel: ChatGroupedViewModel) {
        self.viewModel = viewModel
        self.viewPager = LGViewPager()
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

    
    // MARK: - LGViewPagerDataSource

    func viewPagerNumberOfTabs(viewPager: LGViewPager) -> Int {
        return 9
    }

    func viewPager(viewPager: LGViewPager, viewControllerForTabAtIndex index: Int) -> UIViewController {
        return ChatListViewController()
    }

    func viewPager(viewPager: LGViewPager, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString {
        return titleForTabAtIndex(index, selected: false)
    }

    func viewPager(viewPager: LGViewPager, titleForSelectedTabAtIndex index: Int) -> NSAttributedString {
        return titleForTabAtIndex(index, selected: true)
    }


    // MARK: - LGViewPagerDelegate

    func viewPager(viewPager: LGViewPager, willDisplayViewController viewController: UIViewController, atIndex index: Int) {

    }

    func viewPager(viewPager: LGViewPager, didEndDisplayingViewController viewController: UIViewController, atIndex index: Int) {

    }


    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = UIColor.whiteColor()

        viewPager.dataSource = self
        viewPager.delegate = self
        viewPager.indicatorSelectedColor = StyleHelper.primaryColor
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

        var titleAttributes = [String : AnyObject]()
        titleAttributes[NSForegroundColorAttributeName] = color
        var countAttributes = [String : AnyObject]()
        countAttributes[NSForegroundColorAttributeName] = UIColor.darkGrayColor()

        let string = NSMutableAttributedString()
        switch index % 3 {
        case 0:
            string.appendAttributedString(NSAttributedString(string: "BUYING", attributes: titleAttributes))
            string.appendAttributedString(NSAttributedString(string: " "))
            string.appendAttributedString(NSAttributedString(string: "(44)", attributes: countAttributes))
        case 1:
            string.appendAttributedString(NSAttributedString(string: "SELLING", attributes: titleAttributes))
            string.appendAttributedString(NSAttributedString(string: " "))
            string.appendAttributedString(NSAttributedString(string: "(5)", attributes: countAttributes))
        case 2:
            string.appendAttributedString(NSAttributedString(string: "ARCHIVED", attributes: titleAttributes))
            string.appendAttributedString(NSAttributedString(string: " "))
            string.appendAttributedString(NSAttributedString(string: "(11)", attributes: countAttributes))
        default:
            break
        }
        return string
    }
}
