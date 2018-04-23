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

struct LGMediaThumbnail: MediaThumbnail, Decodable {
    var file: File
    let type: MediaType
    let size: LGSize?

    init(file: File, type: MediaType, size: LGSize) {
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

struct LGMediaOutputs: MediaOutputs, Decodable {
    let image: URL?
    let imageThumbnail: URL?
    let video: URL?
    let videoThumbnail: URL?

    init(image: URL?, imageThumbnail: URL?, video: URL?, videoThumbnail: URL?) {
        self.image = image
        self.imageThumbnail = imageThumbnail
        self.video = video
        self.videoThumbnail = videoThumbnail
    }

    init(from decoder: Decoder) throws {
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

struct LGMedia: Media, Decodable {
    var objectId: String?
    let type: MediaType
    let snapshotId: String
    let outputs: MediaOutputs

    init(type: MediaType, snapshotId: String, outputs: MediaOutputs) {
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
