//
//  ItemCell.swift
//  Flickr
//
//  Created by Gent on 6/22/18.
//  Copyright © 2018 Gent. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgTitle: UILabel!
    
    // MARK: - Methods
    
    func showImage(_ image: Any) {
        if let image = image as? FlickrImage {
            imgView.image = image.thumbnail
            imgTitle.text = image.title
        }
        if let image = image as? PublicImage {
            imgView.image = image.flickrImage
            imgTitle.text = image.title
        }
    }
}
