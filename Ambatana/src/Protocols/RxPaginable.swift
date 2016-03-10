//
//  RxPaginable.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift

protocol RxPaginable: Paginable {
    var rx_objectCount: Variable<Int> { get }
}
