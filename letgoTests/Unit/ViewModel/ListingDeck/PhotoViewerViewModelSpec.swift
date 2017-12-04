//
//  PhotoViewerViewModelSpec.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble

final class PhotoViewerViewModelSpec: QuickSpec {

    override func spec() {
        var sut: PhotoViewerViewModel!
        var imageDownloader: ImageDownloaderType!
        var urls: [URL] = []

        describe("A listing") {
            afterEach {
                urls.removeAll()
            }

            context("that has no images") {
                beforeEach {
                    imageDownloader = MockImageDownloader()
                    urls.removeAll()
                    sut = PhotoViewerViewModel(imageDownloader: imageDownloader, urls: urls)
                }

                it("the photoviewer has no image") {
                    expect(sut.urlsAtIndex(0)).to(beNil())
                }
                it("the photoviewer has no random image") {
                    expect(sut.urlsAtIndex(Int.makeRandom())).to(beNil())
                }
            }

            context("that has images") {
                beforeEach {
                    imageDownloader = MockImageDownloader()
                    urls = Array.makeRandom()
                    sut = PhotoViewerViewModel(imageDownloader: imageDownloader, urls: urls)
                }

                it("the photoviewer shows the proper image for a given index") {
                    for (index, url) in urls.enumerated() {
                        expect(sut.urlsAtIndex(index)).to(be(url))
                    }
                }
            }
        }
    }
}
