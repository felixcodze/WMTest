//
//  HomeDetailViewModel.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/7/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import Foundation

protocol HomeDetailViewModelDelegate: BaseViewModelDelegate {
  func updateWebView(urlRequest: URLRequest)
}

class HomeDetailViewModel {
  weak var delegate: HomeDetailViewModelDelegate?
  var currentURLString: String?
  
  convenience init(detailURLString: String) {
    self.init()
    currentURLString = detailURLString
  }
  
  func buildURLRequest(){
    guard
      let businessURLString = currentURLString,
      let businessURL = URL(string: businessURLString)
    else {
      let err = NSError(domain: "wmcc",
                        code: 999,
                        userInfo: ["description":"There was a problem with your web link"])
      delegate?.showError(error: err)
      return
    }
    let businessRequest = URLRequest(url: businessURL)
    delegate?.updateWebView(urlRequest: businessRequest)
  }
  
  
}
