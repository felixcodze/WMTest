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
  var searchTerm = "pizza"
  var currentOffset: Int = 0
  var isLoading = false
  weak var delegate: HomeViewModelDelegate?
  
  convenience init(service: BaseBusinessService) {
    self.init()
    businessService = service as? BusinessService
  }
  
  func resetSearch() {
    businessService?.cancelSearch()
    currentOffset = 0
    businesses = []
  }
  
  func loadNextPage() {
    if isLoading {
      return
    }
    currentOffset += K.businessPageLimit
    searchForBusiness()
  }
  
  func searchForBusiness() {
    guard !searchTerm.isEmpty else {
      resetSearch()
      delegate?.updateData()
      isLoading = false
      return
    }
    isLoading = true
    businessService?.searchBusinesses(for: searchTerm, userCoordinate: userLocation, offset:currentOffset, completion: { [weak self] result in
      switch result {
      case .success(let businessData):
        self?.businesses += businessData.businesses ?? []
        self?.totalResults = businessData.total ?? businessData.businesses?.count ?? 0
        self?.delegate?.updateData()
        self?.isLoading = false
      case .failure(let error): print("error \(error.localizedDescription)")
      }
      
    })
  }
  
  
  
}
