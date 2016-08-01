//
//  BannerCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 5/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class BannerCellDrawer: BaseCollectionCellDrawer<BannerCell>, GridCellDrawer {
    func draw(model: BannerData, inCell cell: BannerCell) {
        cell.imageView.image = UIImage(named: "sample_tb") //model.style.image
        cell.colorView.backgroundColor = model.style.backColor
        cell.title.text = model.title
        cell.videoURL = NSURL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")!
        cell.stopVideo()
    }
}
