//
//  ReportUsersViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 05/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol ReportUsersViewModelDelegate: class {

}

class ReportUsersViewModel: BaseViewModel {

    weak var delegate: ReportUsersViewModelDelegate?
    
}
