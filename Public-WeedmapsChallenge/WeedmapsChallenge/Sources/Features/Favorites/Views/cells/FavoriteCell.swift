//
//  FavoriteCell.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/8/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import UIKit

class FavoriteCell: UITableViewCell {
  
  @IBOutlet private var businessImageView: UIImageView!
  @IBOutlet private var nameLabel: UILabel!
  @IBOutlet private var visitsLabel: UILabel!
  
  var favorite: Favorite!
  var imageLoadTask: URLSessionDownloadTask?
  
  override func prepareForReuse() {
    super.prepareForReuse()
    businessImageView.image = nil
    imageLoadTask?.cancel()
  }
  
  func updateCell() {
    nameLabel.text = favorite.name
    visitsLabel.text = "Visits: \(favorite.visits)"
    guard let urlString = favorite.imageURL,
      let imageURL = URL(string: urlString)
      else { return }
    imageLoadTask = businessImageView.loadImageWithURL(imageURL)
  }
}
