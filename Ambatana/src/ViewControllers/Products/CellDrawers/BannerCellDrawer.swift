//
//  BannerCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 5/7/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import FLAnimatedImage

class BannerCellDrawer: BaseCollectionCellDrawer<BannerCell>, GridCellDrawer {
    func draw(model: BannerData, inCell cell: BannerCell) {
        cell.imageView.image = UIImage(named: "sample_tb") //model.style.image
        cell.colorView.backgroundColor = model.style.backColor
        cell.title.text = model.title
        cell.videoURL = NSURL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")!
        cell.stopVideo()
        
        
        
        
        let gif1 = NSURL(string: "https://i.imgur.com/eCYAdW4.gif")!
        let gif2 = NSURL(string: "http://66.media.tumblr.com/9ec0aeed0ef6f914d0daa05beb641648/tumblr_n9l1pguJm41qhsmqdo1_500.gif")
        let gif3 = NSURL(string: "https://i.imgur.com/eC0ONqV.gif")
        let gif4 = NSURL(string: "http://i.imgur.com/kGm6U4n.gif")
        let gif5 = NSURL(string: "http://65.media.tumblr.com/e74d7c7205c670fbb36910ac5f71bd62/tumblr_nafvhiS6zD1s2vvpeo1_400.gif")
        let gif6 = NSURL(string: "http://67.media.tumblr.com/4d9c5381e30113c22c04ca17a6ed4831/tumblr_mww2qtryCC1sefic9o1_400.gif")
        let gif7 = NSURL(string: "http://i.imgur.com/hDaM9Hw.gif")
        let gif8 = NSURL(string: "http://i1161.photobucket.com/albums/q509/Morgan_Eggers/steve4.gif")
        let gif9 = NSURL(string: "http://www.damnlol.com/pics/215/39469a0bb9e18d8b7ea4a1fb693b527c.gif")
        let gif10 = NSURL(string: "http://67.media.tumblr.com/38b1c6efcb52d4e1116460f880ca4b87/tumblr_naxzftcgIH1ru5h8co1_500.gif")
        
        let array = [gif1, gif2, gif3, gif4, gif5, gif6, gif7, gif8, gif9, gif10]
        let url = array[Int(arc4random_uniform(10))]
        
        onBackgroundThread {
            let data = NSData(contentsOfURL: url!)
            onMainThread {
                cell.animatedImageView?.animatedImage = FLAnimatedImage(animatedGIFData: data)
            }
        }
    }
}
