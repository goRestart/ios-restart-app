struct LGFeedMediaItem {
    let image: LGFeedMediaOutput
    let video: LGFeedMediaOutput?
    let videoThumb: LGFeedMediaOutput?
}

extension LGFeedMediaItem {
    var type: MediaType {
        return isVideo ? .video : .image
    }
    
    var isVideo: Bool {
        return video != nil
    }
}

extension LGFeedMediaItem: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case image, video, videoThumb = "video_thumb", type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        image = try container.decode(LGFeedMediaOutput.self, forKey: .image)
        video = try container.decodeIfPresent(LGFeedMediaOutput.self, forKey: .video)
        videoThumb = try container.decodeIfPresent(LGFeedMediaOutput.self, forKey: .videoThumb)
    }
}

extension LGFeedMediaItem {
    
    static func toFile(mediaItem: LGFeedMediaItem) -> LGFile? {
        guard case .image = mediaItem.type else { return nil }
        return LGFile(id: mediaItem.image.id, url: mediaItem.image.url)
    }
    
    static func toMedia(mediaItem: LGFeedMediaItem, imageThumbnail: URL?) -> LGMedia {
        let outputs = LGMediaOutputs(image: mediaItem.image.url,
                                     imageThumbnail: imageThumbnail,
                                     video: mediaItem.video?.url,
                                     videoThumbnail: mediaItem.videoThumb?.url)

        return LGMedia(objectId: mediaItem.video?.id ?? mediaItem.image.id,
                       type: mediaItem.type,
                       snapshotId: mediaItem.videoThumb?.id ?? mediaItem.image.id,
                       outputs: outputs)
    }
}

struct LGFeedMediaOutput: Decodable {
    let id: String
    let url: URL
}
