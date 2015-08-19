//
//  ContactSubjectOptionsViewModel.swift
//  LetGo
//
//  Created by Dídac on 17/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//


public protocol ContactSubjectOptionsViewModelDelegate: class {
    func viewModel(viewModel: ContactSubjectOptionsViewModel, didSelectSubjectAtIndex index: Int)
}

public protocol ContactSubjectSelectionReceiverDelegate: class {
    func viewModel(viewModel: ContactSubjectOptionsViewModel, selectedSubject: ContactSubject)

}

public class ContactSubjectOptionsViewModel: BaseViewModel {
   
    public weak var delegate: ContactSubjectOptionsViewModelDelegate?
    public weak var selectionReceiverDelegate: ContactSubjectSelectionReceiverDelegate?
    
    var subject : ContactSubject?

    public var numberOfSubjects: Int {
        get {
            return ContactSubject.allValues.count
        }
    }

    override init() {
        subject = nil
        super.init()
    }
    
    // MARK: - public methods
    
    public func subjectNameAtIndex(index: Int) -> String {
        return ContactSubject.allValues[index].name
    }
    
    public func selectSubjectAtIndex(index: Int) {
        let selectedSubject = ContactSubject.allValues[index]
        subject = selectedSubject
        selectionReceiverDelegate?.viewModel(self, selectedSubject: selectedSubject)
    }
}
