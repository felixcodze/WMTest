//
//  ClassExtensions.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/8/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import Foundation

extension Date {
  
  func formattedDate(format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: self)
  }
  
}
