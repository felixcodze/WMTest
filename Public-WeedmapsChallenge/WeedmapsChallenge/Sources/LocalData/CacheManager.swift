//
//  CacheManager.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/9/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import UIKit

class CacheManager: NSObject {

  static let shared = CacheManager()
  
  var imageCache = NSCache<NSString, UIImage>()
  
  public func storeImageToCache(image: UIImage, urlString: String) {
    imageCache.setObject(image, forKey: urlString as NSString)
  }
  
  public func getImageFromCache(urlString: String) -> UIImage? {
    return imageCache.object(forKey: urlString as NSString)
  }
  
}
