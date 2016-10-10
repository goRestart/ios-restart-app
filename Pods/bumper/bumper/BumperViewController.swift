//
//  BumperViewController.swift
//  Pods
//
//  Created by Eli Kohen on 21/09/16.
//  Copyright © 2016 Letgo. All rights reserved.
//

import UIKit

public class BumperViewController: UIViewController {

    private let tableView = UITableView()
    private let enableBumperContainer = UIView()
    private let enableBumperSwitch = UISwitch()

    private let viewModel: BumperViewModel

    public convenience init() {
        self.init(viewModel: BumperViewModel())
    }

    init(viewModel: BumperViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        initTableView()
        initSwitch()
    }
}


// MARK: - UI

private extension BumperViewController {
    private func setupUI() {
        if let viewControllers = navigationController?.viewControllers where viewControllers.count == 1 {
            let leftItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: #selector(dismiss))
            navigationItem.leftBarButtonItem = leftItem
        }
        title = "Bumper"
        view.backgroundColor = UIColor.whiteColor()
        setupEnableHeader()
        setupTableView()
    }

    private func setupEnableHeader() {
        enableBumperContainer.translatesAutoresizingMaskIntoConstraints = false
        enableBumperContainer.backgroundColor = UIColor.lightGrayColor()
        view.addSubview(enableBumperContainer)

        let enableLabel = UILabel()
        enableLabel.text = "Bumper Enabled:"
        enableLabel.translatesAutoresizingMaskIntoConstraints = false
        enableBumperContainer.addSubview(enableLabel)

        enableBumperSwitch.translatesAutoresizingMaskIntoConstraints = false
        enableBumperContainer.addSubview(enableBumperSwitch)

        var views = [String: AnyObject]()
        views["container"] = enableBumperContainer
        views["label"] = enableLabel
        views["switch"] = enableBumperSwitch

        var metrics = [String: AnyObject]()
        metrics["viewsMargin"] = CGFloat(10)

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[container]|",
            options: [], metrics: nil, views: views))
        enableBumperContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-viewsMargin-[label]-[switch]-viewsMargin-|",
            options:  .AlignAllCenterY, metrics: metrics, views: views))
        enableBumperContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label]|",
            options: [], metrics: nil, views: views))
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        var views = [String: AnyObject]()
        views["topLayoutGuide"] = topLayoutGuide
        views["container"] = enableBumperContainer
        views["table"] = tableView

        var metrics = [String: AnyObject]()
        metrics["containerH"] = CGFloat(40)

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide]-0-[container(containerH)]-0-[table]|",
            options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[table]|",
            options: [], metrics: metrics, views: views))
    }

    private func initSwitch() {
        enableBumperSwitch.onTintColor = UIColor.darkGrayColor()
        enableBumperSwitch.setOn(viewModel.enabled, animated: false)
        enableBumperSwitch.addTarget(self, action: #selector(switchValueChanged), forControlEvents: .ValueChanged)
    }

    private dynamic func switchValueChanged() {
        viewModel.setEnabled(enableBumperSwitch.on)
    }

    private dynamic func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: TableView

extension BumperViewController: UITableViewDelegate, UITableViewDataSource {
    private static let cellReuseIdentifier = "bumperCell"

    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.featuresCount
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCellWithIdentifier(BumperViewController.cellReuseIdentifier) {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: BumperViewController.cellReuseIdentifier)
        }
        cell.textLabel?.text = viewModel.featureNameAtIndex(indexPath.row)
        cell.detailTextLabel?.text = viewModel.featureValueAtIndex(indexPath.row)
        return cell
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        viewModel.featureSelectedAtIndex(indexPath.row)
    }
}


// MARK: - BumperViewModelDelegate

extension BumperViewController: BumperViewModelDelegate {
    func featuresUpdated() {
        tableView.reloadData()
    }

    func showFeature(feature: Int, itemsSelection items: [String]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        for item in items {
            let action = UIAlertAction(title: item, style: .Default) { [weak self] _ in
                self?.viewModel.selectedFeature(feature, item: item)
            }
            alert.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}
