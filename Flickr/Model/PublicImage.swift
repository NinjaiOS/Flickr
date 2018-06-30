//
//  PublicImage.swift
//  Flickr
//
//  Created by Gent on 6/22/18.
//  Copyright © 2018 Gent. All rights reserved.
//

import UIKit

class PublicImage {

    // MARK: - Properties
    
    let title: String
    let imageAddress: String
    
    var flickrImage: UIImage?
    var metaData: [String:Any]?
    
    // MARK: - Init
    
    init(title: String, imageAdress: String) {
        self.title = title
        self.imageAddress = imageAdress
    }
    
    // MARK: - Methods
    
    func loadLargeImage(_ completion: @escaping (_ flickrPhoto: PublicImage, _ error: NSError?) -> Void) {
        
        guard let url = URL(string: imageAddress) else {
            DispatchQueue.main.async {
                completion(self, nil)
            }
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(self, error as NSError?)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(self, nil)
                }
                return
            }
            
            let returnedImage = UIImage(data: data)
            self.flickrImage = returnedImage
            
            DispatchQueue.main.async {
                completion(self, nil)
            }
        }).resume()
    }

}
