//
//  HomeDetailViewModel.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/7/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import Foundation

protocol HomeDetailViewModelDelegate: class {
  func updateWebView(url: String)
}

class HomeDetailViewModel {
  weak var delegate: HomeViewModelDelegate?
  var currentURLString: String?
  
  convenience init(detailURLString: String) {
    self.init()
    currentURLString = detailURLString
  }
  
  
  
}
