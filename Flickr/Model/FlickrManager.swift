//
//  FlickrManager.swift
//  Flickr
//
//  Created by Gent on 6/22/18.
//  Copyright © 2018 Gent. All rights reserved.
//

import UIKit

class FlickrManager {
    
    // MARK: - Properties
    
    let apiError = NSError(domain: "Search", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
    
    // MARK: - Methods
    
    // returns images that match the search term
    func makeARequestForImages(with searchTerm: String, completion : @escaping (_ results: [FlickrImage]?, _ error : Error?) -> Void){
        
        guard let searchURL = searchURL(searchTerm: searchTerm) else {
            completion(nil, apiError)
            return
        }
        
        URLSession.shared.dataTask(with: searchURL, completionHandler: { [weak self] (data, response, error) in
            // Return error when it fails
            if let _ = error {
                completion(nil, self?.apiError)
                return
            }
            
            guard let _ = response as? HTTPURLResponse, let data = data else {
                completion(nil, self?.apiError)
                return
            }
            // Parse JSON from Flickr API
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                    completion(nil, self?.apiError)
                    return
                }
                
                guard let photo = json["photos"] as? [String:Any], let photos = photo["photo"] as? [[String:Any]] else {
                    completion(nil, self?.apiError)
                    return
                }
                
                var flickrImages = [FlickrImage]()
                
                for photo in photos {
                    
                    guard let farm = photo["farm"] as? Int,
                        let id = photo["id"] as? String,
                        let server = photo["server"] as? String,
                        let secret = photo["secret"] as? String,
                        let title = photo["title"] as? String else { break }
                    
                    let flickrImage = FlickrImage(id: id, farm: farm, server: server, secret: secret, title: title)
                    
                    guard let url = flickrImage.flickrImageURL(), let imageData = try? Data(contentsOf: url as URL) else {
                        break
                    }
                    
                    if let image = UIImage(data: imageData) {
                        flickrImage.metaData = self?.storeMetaData(imageData: imageData)
                        flickrImage.thumbnail = image
                        flickrImages.append(flickrImage)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(flickrImages, nil)
                }
            } catch _ {
                completion(nil, self?.apiError)
                return
            }
            
        }).resume()
    }
    
    // returns images from Flickr public feed
    
    func makeARequestForFlickrPublicFeed(completion : @escaping (_ results: [PublicImage]?, _ error : Error?) -> Void){
        
        guard let url = URL(string: flickrPublicFeedURL) else {
            completion(nil, apiError)
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
            // Return error when it fails
            if let _ = error {
                completion(nil, self?.apiError)
                return
            }
            
            guard let _ = response as? HTTPURLResponse, let data = data else {
                completion(nil, self?.apiError)
                return
            }
            // Parse JSON from Flickr API
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else {
                    completion(nil, self?.apiError)
                    return
                }
                //print("json: \(json)")
                guard let items = json["items"] as? [[String:Any]] else {
                    completion(nil, self?.apiError)
                    return
                }
                
                var flickrImages = [PublicImage]()
                
                for photo in items {
                    
                    guard let title = photo["title"] as? String, let _ = photo["link"] as? String, let media = photo["media"] as? [String: Any], let address = media["m"] as? String else {
                        break
                    }
                    
                    let flickrImage = PublicImage(title: title, imageAdress: address)
                    
                    guard let imgURL = URL(string: address), let imageData = try? Data(contentsOf: imgURL) else {
                        break
                    }
                    
                    if let image = UIImage(data: imageData) {
                        flickrImage.metaData = self?.storeMetaData(imageData: imageData)
                        flickrImage.flickrImage = image
                        flickrImages.append(flickrImage)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(flickrImages, nil)
                }
            } catch _ {
                completion(nil, self?.apiError)
                return
            }
            
        }).resume()
    }
    
    // returns URL with search term
    
    private func searchURL(searchTerm: String) -> URL? {
        guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(flickrAPIKey)&text=\(escapedTerm)&per_page=20&format=json&nojsoncallback=1"
        guard let url = URL(string:URLString) else {
            return nil
        }
        return url
    }
    
    // returns images metadata
    
    private func storeMetaData(imageData: Data) -> [String: Any]? {
        if let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) {
            let metaData = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as! [String: Any]
            return metaData
        }
        return nil
    }

}
