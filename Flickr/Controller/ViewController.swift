//
//  ViewController.swift
//  Flickr
//
//  Created by Gent on 6/22/18.
//  Copyright © 2018 Gent. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let sections = ["Kittens", "Dogs", "Public Feed"]
    let flickrManager = FlickrManager()
    let transparentView = UIView()
    
    var flickrImages = [[Any]]()
    var selectedImage: Any?
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "KI labs"
        populateFeedWithImages()
    }

    // Ugliest part of my code
    // Make a request call for every keyword separately
    func populateFeedWithImages() {
        tableView.reloadData()
        let tempArray = [Any]()
        flickrImages = [tempArray, tempArray, tempArray]
        showActivityIndicator()
        // haven't made much researches but couldn't find a way to make only one API call where...
        // it would have returned specific / separated arrays for each keyword in one API call instead of making a call for each keywork.
        populatePublicFeed()
        for index in 0...1 {
            let term = sections[index]
            searchImages(with: term) { [weak self] (results) in
                if let results = results {
                    self?.flickrImages.insert(results, at: index)
                    self?.tableView.reloadSections([index], with: .none)
                }
            }
        }
    }
    
    func searchImages(with term: String, completion: @escaping (_ result: [FlickrImage]?) -> Void){
        flickrManager.makeARequestForImages(with: term) { [weak self] (results, error) in
            self?.removeActivityIndicator()
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }
            completion(results)
        }
    }
    
    func populatePublicFeed() {
        flickrManager.makeARequestForFlickrPublicFeed { [weak self] (results, error) in
            self?.removeActivityIndicator()
            if let results = results {
                let index = 2
                self?.flickrImages.insert(results, at: index)
                self?.tableView.reloadSections([index], with: .none)
            }
        }
    }
    
    func showActivityIndicator() {
        transparentView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(transparentView)
        
        let x = (self.view.frame.width / 2) - 50
        let y = (self.view.frame.height / 2) - 50
        activityIndicator.frame = CGRect(x: x, y: y, width: 100, height: 100)
        activityIndicator.startAnimating()
        transparentView.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.removeFromSuperview()
            self?.transparentView.removeFromSuperview()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage" {
            let detailVC = segue.destination as! DetailVC
            
            if let selectedImage = selectedImage as? FlickrImage {
                detailVC.imageTitle = selectedImage.title
                detailVC.selectedImage = selectedImage.thumbnail
                detailVC.metaDataText = selectedImage.metaData
            }
            
            if let selectedImage = selectedImage as? PublicImage {
                detailVC.imageTitle = selectedImage.title
                detailVC.selectedImage = selectedImage.flickrImage
                detailVC.metaDataText = selectedImage.metaData
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(155)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as! SectionCell
        cell.sectionDelegate = self
        cell.displayFlickr(images: flickrImages, section: indexPath.section)
        return cell
    }
}

extension ViewController: sectionDelegate {
    func didSelectCellAt(indexPath: IndexPath, itemSelected: Any) {
        selectedImage = itemSelected
        performSegue(withIdentifier: "showImage", sender: nil)
    }
}
