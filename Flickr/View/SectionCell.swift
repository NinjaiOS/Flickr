//
//  SectionCell.swift
//  Flickr
//
//  Created by Gent on 6/22/18.
//  Copyright © 2018 Gent. All rights reserved.
//

import UIKit

protocol sectionDelegate: class {
    func didSelectCellAt(indexPath: IndexPath, itemSelected: Any)
}

class SectionCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var feed = [Any]()
    weak var sectionDelegate: sectionDelegate?
    
    // MARK: - Methods
    
    func displayFlickr(images: [[Any]], section: Int) {
        feed = images[section]
        collectionView.reloadData()
    }
}

extension SectionCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feed.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        if !feed.isEmpty {
            cell.showImage(feed[indexPath.item])
        }
        return cell
    }
}

extension SectionCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        sectionDelegate?.didSelectCellAt(indexPath: indexPath, itemSelected: feed[indexPath.item])
    }
}
