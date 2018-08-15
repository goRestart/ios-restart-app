
struct LGFeedMedia: Decodable {
    
    /*
     {
          "thumbnail": {
            "type": "video",
            "url": "https://img.letgo.com/images/dd/a2/af/07/dd92.jpeg?impolicy=img_200",
            "width": 200,
            "height": 300
          },
          "items": [
            {
              "image": {
                "id": "dd92",
                "url": "https://img.letgo.com/images/dd/a2/af/07/dd92.jpeg"
              },
              "type": "image"
            },
            {
              "image": {
                "id": "foo",
                "url": "https://img.letgo.com/images/dd/a2/af/07/foo.jpeg"
              },
              "video": {
                "id": "bar",
                "url": "https://img.letgo.com/images/dd/a2/af/07/bar.mpg"
              },
              "video_thumb": {
                "id": "buzz",
                "url": "https://img.letgo.com/images/dd/a2/af/07/buzz.gif"
              },
              "type": "video"
            }
          ]
     }
     */
    
    let thumbnail: LGFeedMediaThumbnail?
    let items: [LGFeedMediaItem]
}

struct LGFeedMediaThumbnail: Decodable {
    let type: MediaType
    let url: URL
    let width: Float
    let height: Float
}

extension LGFeedMediaThumbnail {
    
    static func toFile(thumb: LGFeedMediaThumbnail?) -> LGFile? {
        guard let thumb = thumb else { return nil }
        return LGFile(id: nil, url: thumb.url)
    }
    
    static func toLGSize(thumb: LGFeedMediaThumbnail?) -> LGSize? {
        guard let thumb = thumb else { return nil }
        return LGSize(width: thumb.width, height: thumb.height)
    }
}

