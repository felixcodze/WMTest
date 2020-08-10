//
//  ClassExtensions.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/8/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import UIKit

extension Date {
  func formattedDate(format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: self)
  }
}

extension UIImageView {
  func loadImageWithURL(_ url: URL) -> URLSessionDownloadTask? {
    
    let imageURLString = url.absoluteString
    
    if let cachedImage = CacheManager.shared.getImageFromCache(urlString: imageURLString) {
      image = cachedImage
      return nil
    } else {
      let session = URLSession.shared
      
      let downloadTask = session.downloadTask(with: url, completionHandler: { [weak self] url, _, error in
        
        if error == nil, let url = url,
          let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
          CacheManager.shared.storeImageToCache(image: image, urlString: imageURLString)
          DispatchQueue.main.async {
            if let strongSelf = self {
              strongSelf.image = image
            }
          }
        }
      })
      downloadTask.resume()
      return downloadTask
    }
  }
}
