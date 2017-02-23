//
//  MultiPageRequester.swift
//  LetGo
//
//  Created by Eli Kohen on 23/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import Result

class MultiPageRequester<T> {

    private var pageRequestBlock: (_ page: Int,_ completion: ((Result<[T], RepositoryError>) -> ())?) -> Void

    private var finalCompletionBlock: ((Result<[T], RepositoryError>) -> ())?
    private var pagesResults = [Int : [T]]()

    private var requesting = false
    private var errored = false

    init(pageRequestBlock: @escaping (Int, ((Result<[T], RepositoryError>) -> ())?) -> Void) {
        self.pageRequestBlock = pageRequestBlock
    }

    @discardableResult
    func request(pages: [Int], completion: ((Result<[T], RepositoryError>) -> ())?) -> Bool {
        guard !requesting else { return false }
        requesting = true
        errored = false
        finalCompletionBlock = completion
        pagesResults.removeAll()

        for page in pages {
            pageRequestBlock(page) { [weak self] result in
                guard let strongSelf = self, !strongSelf.errored else { return }
                if let value = result.value {
                    strongSelf.pagesResults[page] = value
                    strongSelf.groupResultAndFinishIfNeeded(pages: pages)
                } else {
                    strongSelf.errored = true
                    strongSelf.requesting = false
                    strongSelf.finalCompletionBlock?(result)
                }
            }
        }
        return true
    }

    private func groupResultAndFinishIfNeeded(pages: [Int]) {
        guard pagesResults.count == pages.count else { return }
        var groupedResults = [T]()
        for page in pages {
            if let results = pagesResults[page] {
                groupedResults.append(contentsOf: results)
            }
        }
        requesting = false
        finalCompletionBlock?(Result<[T], RepositoryError>(groupedResults))
    }
}
