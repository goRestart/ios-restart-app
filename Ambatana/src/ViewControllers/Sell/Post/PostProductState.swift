//
//  File.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

enum PostProductState: Equatable {
    case imageSelection
    case uploadingImage
    case errorUpload(message: String)
    case detailsSelection
    case categorySelection
    case carDetailsSelection(includePrice: Bool)
    
    static func initialState(featureFlags: FeatureFlaggeable) -> PostProductState {
        guard featureFlags.carsVerticalEnabled else { return .imageSelection }
        return featureFlags.carsCategoryAfterPicture ? .imageSelection : .categorySelection
    }
    
    func nextState(featureFlags: FeatureFlaggeable) -> PostProductState? {
        switch self {
        case .imageSelection, .errorUpload:
            return .uploadingImage
        case .uploadingImage:
            if featureFlags.carsVerticalEnabled {
                return featureFlags.carsCategoryAfterPicture ? .detailsSelection : .carDetailsSelection(includePrice: true)
            } else {
                return .detailsSelection
            }
        case .detailsSelection:
            if featureFlags.carsVerticalEnabled {
                return featureFlags.carsCategoryAfterPicture ? .categorySelection : nil
            } else {
                return nil
            }
        case .categorySelection:
            guard featureFlags.carsVerticalEnabled else { return nil }
            return featureFlags.carsCategoryAfterPicture ? .carDetailsSelection(includePrice: false) : .imageSelection
        case .carDetailsSelection:
            return nil
        }
    }
    
    func isLastState(featureFlags: FeatureFlaggeable) -> Bool {
        switch self {
        case .imageSelection, .uploadingImage, .errorUpload, .categorySelection:
            return false
        case .detailsSelection:
            return !featureFlags.carsVerticalEnabled
        case .carDetailsSelection:
            return true
        }
    }
}

func ==(lhs: PostProductState, rhs: PostProductState) -> Bool {
    switch (lhs, rhs) {
    case (.imageSelection, .imageSelection), (.uploadingImage, .uploadingImage), (.detailsSelection, .detailsSelection),
         (.categorySelection, .categorySelection):
        return true
    case (let .errorUpload(lMessage), let .errorUpload(rMessage)):
        return lMessage == rMessage
    case (let .carDetailsSelection(lIncludePrice), let .carDetailsSelection(rIncludePrice)):
        return lIncludePrice == rIncludePrice
    default:
        return false
    }
}
