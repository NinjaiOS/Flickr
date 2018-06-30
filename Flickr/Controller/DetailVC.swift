//
//  DetailVC.swift
//  Flickr
//
//  Created by Gent on 6/22/18.
//  Copyright © 2018 Gent. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var metaDataTextView: UITextView!
    
    // MARK: - Properties
    
    var selectedImage: UIImage?
    var imageTitle: String?
    var metaDataText: [String:Any]?
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = selectedImage, let imageTitle = imageTitle, let metaData = metaDataText {
            metaDataTextView.text = String(describing: metaData)
            imgView.image = image
            title = imageTitle
        }
    }
}
