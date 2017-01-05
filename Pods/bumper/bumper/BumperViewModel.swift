//
//  BumperViewModel.swift
//  Pods
//
//  Created by Eli Kohen on 21/09/16.
//
//

import Foundation

protocol BumperViewModelDelegate: class {
    func featuresUpdated()
    func showFeature(_ feature: Int, itemsSelection items: [String])
}

struct BumperViewData {
    let key: String
    let description: String
    let value: String
    let options: [String]
}

class BumperViewModel {

    weak var delegate: BumperViewModelDelegate?

    private(set) var enabled: Bool
    private var viewData: [BumperViewData]

    private let bumper: Bumper

    convenience init() {
        self.init(bumper: Bumper.sharedInstance)
    }

    init(bumper: Bumper) {
        self.bumper = bumper
        self.viewData = bumper.bumperViewData
        self.enabled = bumper.enabled
    }

    var featuresCount: Int {
        return viewData.count
    }

    func featureName(at index: Int) -> String {
        return viewData[index].description
    }

    func featureValue(at index: Int) -> String {
        return viewData[index].value
    }

    func didSelectFeature(at index: Int) {
        delegate?.showFeature(index, itemsSelection: viewData[index].options)
    }

    func updateFeature(at index: Int,with item: String) {
        let data = viewData[index]
        bumper.setValue(for: data.key, value: item)
        viewData = bumper.bumperViewData
        delegate?.featuresUpdated()
    }

    func setEnabled(_ enabled: Bool) {
        bumper.enabled = enabled
        self.enabled = enabled
    }
}
