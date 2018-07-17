//
//  BumperViewModel.swift
//  Pods
//
//  Created by Eli Kohen on 21/09/16.
//
//

import Foundation
import RxSwift

protocol BumperViewModelDelegate: class {
    func featuresUpdated()
    func showFeature(_ feature: Int, title: String, itemsSelection items: [String])
}

struct BumperViewData {
    let key: String
    let description: String
    let value: String
    let options: [String]
}

final class BumperViewModel {

    weak var delegate: BumperViewModelDelegate?

    private(set) var enabled: Bool
    private var viewData: [BumperViewData] {
        didSet {
            rx_filtered.value = viewData
            filter(with: lastFilter ?? "")
        }
    }
    var lastFilter: String? = nil
    var rx_filtered: Variable<[BumperViewData]>

    private let bumper: Bumper

    convenience init() {
        self.init(bumper: Bumper.sharedInstance)
    }

    init(bumper: Bumper) {
        self.bumper = bumper
        self.viewData = bumper.bumperViewData
        self.rx_filtered = Variable(bumper.bumperViewData)
        self.enabled = bumper.enabled
    }

    var featuresCount: Int {
        return rx_filtered.value.count
    }

    func featureName(at index: Int) -> String {
        return rx_filtered.value[index].description
    }

    func featureValue(at index: Int) -> String {
        return rx_filtered.value[index].value
    }

    func filter(with filter: String) {
        lastFilter = filter
        if filter.count > 0 {
            rx_filtered.value = viewData.filter { $0.description.lowercased().contains(filter.lowercased()) }
        } else {
            rx_filtered.value = viewData
        }
    }

    func makeExportableURL() -> URL? {
        let array = viewData
            .enumerated()
            .map { return ($1.key, featureName(at: $0), $1.value, $1.options) }
            .reduce([[:]]) { (values: [[String:Any]], next) in
                var array = values
                array.append([
                    "key": next.0,
                    "description": next.1,
                    "value": next.2,
                    "options": next.3
                ])
                return array
        }.dropFirst()
        return makePList(fromArray: Array(array))
    }

    private func makePList(fromArray array: [[String: Any]]) -> URL? {
        let fileManager = FileManager.default
        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = directory.appending("/bumper.plist")

        if (fileManager.fileExists(atPath: path)) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch _ {
                return nil
            }
        }
        let plistContent = NSArray(array: array)
        let success = plistContent.write(toFile: path, atomically: true)
        if success {
            return URL(fileURLWithPath: path)
        } else {
            return nil
        }
    }

    func didSelectFeature(at index: Int) {
        delegate?.showFeature(index, title: featureName(at: index), itemsSelection: rx_filtered.value[index].options)
    }

    func updateFeature(at index: Int,with item: String) {
        let data = rx_filtered.value[index]
        bumper.setValue(for: data.key, value: item)
        viewData = bumper.bumperViewData
        delegate?.featuresUpdated()
    }

    func setEnabled(_ enabled: Bool) {
        bumper.enabled = enabled
        self.enabled = enabled
    }
}
