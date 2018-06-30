//
//  FlickrImage.swift
//  Flickr
//
//  Created by Gent on 6/22/18.
//  Copyright © 2018 Gent. All rights reserved.
//

import UIKit

class FlickrImage {
    
    // MARK: - Properties
    
    var thumbnail: UIImage?
    var metaData: [String: Any]?
    
    let id: String
    let farm: Int
    let server: String
    let secret: String
    let title: String
    
    // MARK: - Init
    
    init(id: String, farm: Int, server: String, secret: String, title: String) {
        self.id = id
        self.farm = farm
        self.server = server
        self.secret = secret
        self.title = title
    }
    
    // MARK: - Methods
    
    func flickrImageURL(_ size: String = "m") -> URL? {
        if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size).jpg") {
            return url
        }
        return nil
    }
    
    func loadLargeImage(_ completion: @escaping (_ flickrPhoto: FlickrImage, _ error: NSError?) -> Void) {
        
        guard let url = flickrImageURL("b") else {
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
            self.thumbnail = returnedImage
            
            DispatchQueue.main.async {
                completion(self, nil)
            }
        }).resume()
    }
    
}
