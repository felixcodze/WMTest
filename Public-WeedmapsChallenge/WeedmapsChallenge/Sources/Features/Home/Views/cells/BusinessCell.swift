//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit


class BusinessCell: UICollectionViewCell {
    // IMPLEMENT
  
  @IBOutlet var nameLabel: UILabel!
  
  var name: String = "NONE"
  
  func updateCell() {
    nameLabel.text = name
  }
  
}
