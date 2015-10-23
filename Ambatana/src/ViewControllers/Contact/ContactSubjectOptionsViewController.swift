//
//  ContactSubjectOptionsViewController.swift
//  LetGo
//
//  Created by Dídac on 17/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class ContactSubjectOptionsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ContactSubjectOptionsViewModelDelegate {
        
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel : ContactSubjectOptionsViewModel!
    
    var selectedRow : Int? // in case there's a subject already selected

    // MARK: - Lifecycle
    
    init(viewModel: ContactSubjectOptionsViewModel, selectedRow: Int?) {
        super.init(viewModel: viewModel, nibName: "ContactSubjectOptionsViewController")
        
        self.viewModel = viewModel
        self.viewModel.delegate = self
        self.selectedRow = selectedRow
    }
    
    convenience init() {
        let convenienceViewModel = ContactSubjectOptionsViewModel()
        self.init(viewModel: convenienceViewModel, selectedRow: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        let cellNib = UINib(nibName: "SubjectCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "subjectCell")

        tableView.delegate = self
        tableView.dataSource = self
        
        setLetGoNavigationBarStyle(NSLocalizedString("contact_subject_options_title", comment: ""))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let actualSelectedRow = selectedRow {
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: actualSelectedRow, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: ContactSubjectOptionsViewModelDelegate methods
    
    func viewModel(viewModel: ContactSubjectOptionsViewModel, didSelectSubjectAtIndex index: Int) {
        
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
        
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return viewModel.numberOfSubjects
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("subjectCell", forIndexPath: indexPath) as! SubjectCell

        cell.nameLabel.text = viewModel.subjectNameAtIndex(indexPath.row)
        if indexPath.row == 0 {
            cell.addTopBorderWithWidth(1, color: StyleHelper.lineColor)
        }
        cell.addBottomBorderWithWidth(1, color: StyleHelper.lineColor)
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        viewModel.selectSubjectAtIndex(indexPath.row)
    }
    
}
