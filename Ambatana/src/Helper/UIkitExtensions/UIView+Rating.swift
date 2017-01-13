//
//  UIView+Rating.swift
//  LetGo
//
//  Created by Eli Kohen on 19/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension UIView {

    /**
     This method assumes UIView is a container of 5 imageViews with tags from 1 to 5 (indicating each star). It will 
     setup the stars depending on the rating provided.
    */
    func setupRatingContainer(rating: Float) {
        var images = [UIImageView]()
        subviews.forEach {
            guard let image = $0 as? UIImageView else { return }
            images.append(image)
        }
        guard images.count == 5 else { return }

        let full = UIImage(named: "ic_star_avg_full")
        let half = UIImage(named: "ic_star_avg_half")
        let empty = UIImage(named: "ic_star_avg_empty")
        images.forEach { imageView in
            let tag = Float(imageView.tag)
            let diff = tag - rating

            if diff <= 0 {
                imageView.image = full
            } else if diff <= 0.5 {
                imageView.image = half
            } else {
                imageView.image = empty
            }
        }
    }
}
