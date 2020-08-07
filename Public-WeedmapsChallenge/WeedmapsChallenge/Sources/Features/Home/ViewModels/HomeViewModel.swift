//
//  HomeViewModel.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/5/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import Foundation
import CoreLocation

protocol HomeViewModelDelegate: class {
  func updateData()
}

class HomeViewModel {
  
  var businessService: BusinessService?
  var userLocation = CLLocationCoordinate2D(latitude: 34.323, longitude: -118.000)
  var totalResults: Int = 0
  var businesses: [Business] = []
  var searchTerm: String = "pizza"
  var currentPage: Int = 1
  weak var delegate: HomeViewModelDelegate?
  
  convenience init(service: BaseBusinessService) {
    self.init()
    businessService = service as? BusinessService
  }
  
  func resetSearch() {
    currentPage = 1
    businesses = []
  }
  
  func searchForBusiness() {
    guard !searchTerm.isEmpty else {
      resetSearch()
      delegate?.updateData()
      return
    }
    businessService?.searchBusinesses(for: searchTerm, userCoordinate: userLocation, page:currentPage, completion: { [weak self] result in
      switch result {
      case .success(let businessData):
        self?.businesses += businessData.businesses ?? []
        self?.totalResults = businessData.total ?? businessData.businesses?.count ?? 0
        self?.delegate?.updateData()
      case .failure(let error): print("error \(error.localizedDescription)")
      }
      
    })
  }
  
}
