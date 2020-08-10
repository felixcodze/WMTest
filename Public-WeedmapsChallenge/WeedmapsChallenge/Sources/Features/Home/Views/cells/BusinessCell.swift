//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit


class BusinessCell: UICollectionViewCell {
    // IMPLEMENT
  @IBOutlet private var businessImageView: UIImageView!
  @IBOutlet private var nameLabel: UILabel!
  @IBOutlet private var starsCollection: [UIImageView]!
  
  var business: Business?
  var imageLoadTask: URLSessionDownloadTask?
  
  override func prepareForReuse() {
    super.prepareForReuse()
    businessImageView.image = nil
    imageLoadTask?.cancel()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.setUpView()
    self.resetStars()
  }
  
  func setUpView() {
    self.layer.cornerRadius = 25.0
    self.layer.masksToBounds = true
  }
  
  func resetStars() {
    for star in starsCollection {
      star.isHidden = true
    }
  }
  func updateCell() {
    guard
      let imageURLString = business?.image_url,
      let imageURL = URL(string: imageURLString),
      let name = business?.name,
      let rating = business?.rating
    else { return }
    imageLoadTask = businessImageView.loadImageWithURL(imageURL)
    nameLabel.text = name
    for i in 0...Int(rating) - 1 {
      starsCollection[i].isHidden = false
    }
  }
  
}
