//
//  Konstants.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/7/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import Foundation
import CoreGraphics

struct K {
  static let businessPageLimit: Int = 15
  static let businessBaseURL = "https://api.yelp.com/v3/businesses/"
  static let businessDetailAlertTitle = "Business Details"
  static let businessDetailAlertDetail = "How would you like to view the details of this business?"
  static let businessDetailsAlertWKActionTitle = "Within the app"
  static let businessDetailsAlertSafariActionTitle = "With Safari"
  static let businessDetailsAlertCancelTitle = "Cancel"
  static let searchHistoryMaxTableHeight: CGFloat = 160
  static let businessCellWidthDivider: CGFloat = 2
  static let businessCellHeight: CGFloat = 200
  static let businessCellBorderSpacing: CGFloat = 20
  static let businessCellSpacing: CGFloat = 20
  static let searchPlaceholder = "Search for a business!"
}
