//
//  BumperViewController.swift
//  Pods
//
//  Created by Eli Kohen on 21/09/16.
//  Copyright © 2016 Letgo. All rights reserved.
//

import UIKit
import RxSwift

public final class BumperViewController: UIViewController {
    private static let cellReuseIdentifier = "bumperCell"

    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let enableBumperContainer = UIView()
    private let enableBumperSwitch = UISwitch()

    private let viewModel: BumperViewModel
    private let disposeBag = DisposeBag()

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
        attachKeyboardViewControllerTo(self)

        setupUI()
        initTableView()
        initSwitch()
    }
}


// MARK: - UI

fileprivate extension BumperViewController {
    func setupUI() {
        if let viewControllers = navigationController?.viewControllers, viewControllers.count == 1 {
            let leftItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(dismissViewController))
            navigationItem.leftBarButtonItem = leftItem
        }
        title = "Bumper"
        view.backgroundColor = UIColor.white
        setupEnableHeader()
        setupTableView()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:.action,
                                                            target: self,
                                                            action: #selector(share))

        searchBar.delegate = self
        setupRx()
    }

    private func setupRx() {
        let search = searchBar.rx.text.orEmpty
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()

        search.bind { self.viewModel.filter(with: $0) }.disposed(by: disposeBag)

        viewModel.rx_filtered.asDriver().drive(onNext: { (_) in
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }

    func setupEnableHeader() {
        enableBumperContainer.translatesAutoresizingMaskIntoConstraints = false
        enableBumperContainer.backgroundColor = UIColor.lightGray
        view.addSubview(enableBumperContainer)

        let enableLabel = UILabel()
        enableLabel.text = "Bumper Enabled:"
        enableLabel.translatesAutoresizingMaskIntoConstraints = false
        enableBumperContainer.addSubview(enableLabel)

        enableBumperSwitch.translatesAutoresizingMaskIntoConstraints = false
        enableBumperContainer.addSubview(enableBumperSwitch)

        var views = [String: Any]()
        views["container"] = enableBumperContainer
        views["label"] = enableLabel
        views["switch"] = enableBumperSwitch

        var metrics = [String: Any]()
        metrics["viewsMargin"] = CGFloat(10)

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[container]|",
            options: [], metrics: nil, views: views))
        enableBumperContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-viewsMargin-[label]-[switch]-viewsMargin-|",
            options:  .alignAllCenterY, metrics: metrics, views: views))
        enableBumperContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|",
            options: [], metrics: nil, views: views))
    }

    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(searchBar)

        var views = [String: Any]()
        views["topLayoutGuide"] = topLayoutGuide
        views["container"] = enableBumperContainer
        views["table"] = tableView
        views["search"] = searchBar

        var metrics = [String: Any]()
        metrics["containerH"] = CGFloat(40)

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-0-[container(containerH)]-0-[search]-[table]|",
            options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table]|",
            options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[search]|",
                                                           options: [], metrics: metrics, views: views))
    }

    func initSwitch() {
        enableBumperSwitch.onTintColor = UIColor.darkGray
        enableBumperSwitch.setOn(viewModel.enabled, animated: false)
        enableBumperSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }

    @objc func switchValueChanged() {
        viewModel.setEnabled(enableBumperSwitch.isOn)
    }

    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func share() {
        guard let fileURL = viewModel.makeExportableURL() else { return }

        let objectsToShare = [fileURL]
        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}


// MARK: TableView

extension BumperViewController: UITableViewDelegate, UITableViewDataSource {

    fileprivate func initTableView() {
        tableView.register(BumperCell.self, forCellReuseIdentifier: BumperViewController.cellReuseIdentifier)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.featuresCount
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BumperViewController.cellReuseIdentifier) as? BumperCell else { return UITableViewCell() }

        cell.setupWith(title: viewModel.featureName(at: indexPath.row), value: viewModel.featureValue(at: indexPath.row))
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectFeature(at: indexPath.row)
    }
}

// MARK: - UISearchBarDelegate

extension BumperViewController: UISearchBarDelegate {
    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool { return true }
}

// MARK: - BumperViewModelDelegate

extension BumperViewController: BumperViewModelDelegate {
    func featuresUpdated() {
        tableView.reloadData()
    }

    func showFeature(_ feature: Int, title: String, itemsSelection items: [String]) {
        let style: UIAlertControllerStyle = UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet
        let alert = UIAlertController(title: title, message: nil, preferredStyle: style)
        for item in items {
            let action = UIAlertAction(title: item, style: .default) { [weak self] _ in
                self?.viewModel.updateFeature(at: feature, with: item)
            }
            alert.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension BumperViewController: KeyboardDelegate {
    func update(withKeyboard keyboard: KeyboardData) {
        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: CGFloat(keyboard.maxYCoordinate), right: 0)
        tableView.layoutIfNeeded()
    }
}
