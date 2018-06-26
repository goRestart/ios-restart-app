//
//  LGMedia.swift
//  LGCoreKit
//
//  Created by Álvaro Murillo del Puerto on 21/4/18.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

public enum MediaType: String, Decodable {
    case image
    case video

    public static let allValues: [MediaType] = [.image, .video]
}

public func ==(lhs: MediaThumbnail, rhs: MediaThumbnail) -> Bool {
    return lhs.file == rhs.file && lhs.type == rhs.type && lhs.size == rhs.size
}

public protocol MediaThumbnail {
    var file: File { get }
    var type: MediaType { get }
    var size: LGSize? { get }
}

public struct LGMediaThumbnail: MediaThumbnail, Decodable {
    public var file: File
    public let type: MediaType
    public let size: LGSize?

    public init(file: File, type: MediaType, size: LGSize) {
        self.file = file
        self.type = type
        self.size = size
    }

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)

        let thumbnailUrl = try keyedContainer.decodeIfPresent(String.self, forKey: .url)
        file = LGFile(id: nil, urlString: thumbnailUrl)

        type = try keyedContainer.decode(MediaType.self, forKey: .type)

        if let thumbnailWidth = try keyedContainer.decodeIfPresent(Float.self, forKey: .width),
            let thumbnailHeight = try keyedContainer.decodeIfPresent(Float.self, forKey: .height) {
            size = LGSize(width: thumbnailWidth, height: thumbnailHeight)
        } else {
            size = nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case url = "url"
        case type = "media_type"
        case width = "width"
        case height = "height"
    }
}

public func ==(lhs: MediaOutputs, rhs: MediaOutputs) -> Bool {
    return lhs.image == rhs.image && lhs.imageThumbnail == rhs.imageThumbnail &&
        lhs.video == rhs.video && lhs.videoThumbnail == rhs.videoThumbnail
}

public protocol MediaOutputs {
    var image: URL? { get }
    var imageThumbnail: URL? { get }
    var video: URL? { get }
    var videoThumbnail: URL? { get }
}

public struct LGMediaOutputs: MediaOutputs, Decodable {
    public let image: URL?
    public let imageThumbnail: URL?
    public let video: URL?
    public let videoThumbnail: URL?

    public init(image: URL? = nil, imageThumbnail: URL? = nil, video: URL? = nil, videoThumbnail: URL? = nil) {
        self.image = image
        self.imageThumbnail = imageThumbnail
        self.video = video
        self.videoThumbnail = videoThumbnail
    }

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)

        image = try keyedContainer.decodeIfPresent(URL.self, forKey: .image)
        imageThumbnail = try keyedContainer.decodeIfPresent(URL.self, forKey: .imageThumbnail)
        video = try keyedContainer.decodeIfPresent(URL.self, forKey: .video)
        videoThumbnail = try keyedContainer.decodeIfPresent(URL.self, forKey: .videoThumbnail)
    }

    enum CodingKeys: String, CodingKey {
        case image = "image"
        case imageThumbnail = "image_thumb"
        case video = "video"
        case videoThumbnail = "video_thumb"
    }
}

public func ==(lhs: Media, rhs: Media) -> Bool {
    return lhs.objectId == rhs.objectId && lhs.snapshotId == rhs.snapshotId && lhs.outputs == rhs.outputs
}

public protocol Media: BaseModel {
    var type: MediaType { get }
    var snapshotId: String { get }
    var outputs: MediaOutputs { get }
}

public struct LGMedia: Media, Decodable {
    public var objectId: String?
    public let type: MediaType
    public let snapshotId: String
    public let outputs: MediaOutputs

    public init(objectId: String?,
                type: MediaType,
                snapshotId: String,
                outputs: MediaOutputs) {
        
        self.objectId = objectId
        self.type = type
        self.snapshotId = snapshotId
        self.outputs = outputs
    }

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)

        objectId = try keyedContainer.decodeIfPresent(String.self, forKey: .objectId)
        snapshotId = try keyedContainer.decode(String.self, forKey: .snapshotId)
        type = try keyedContainer.decode(MediaType.self, forKey: .type)
        outputs = try keyedContainer.decode(LGMediaOutputs.self, forKey: .outputs)
    }

    enum CodingKeys: String, CodingKey {
        case objectId = "id"
        case type = "media_type"
        case snapshotId = "snapshot_id"
        case outputs = "outputs"
    }
}

//  To be removed after backend is fixed
extension LGMedia {
    static func mediaFrom(images: [File]) -> [LGMedia] {
        return images.map {
            let mediaOutput = LGMediaOutputs(image: $0.fileURL, imageThumbnail: $0.fileURL)
            return LGMedia(objectId: $0.objectId,
                           type: .image,
                           snapshotId: "",
                           outputs: mediaOutput)
        }
    }
}
