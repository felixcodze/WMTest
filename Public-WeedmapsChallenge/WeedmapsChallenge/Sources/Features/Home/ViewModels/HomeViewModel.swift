//
//  HomeViewModel.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/5/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

enum BusinessDetailNavigationType {
  case safari
  case webkit
}

class HomeViewModel {
  
  var businessService: BusinessService?
  var userLocation = CLLocationCoordinate2D(latitude: 34.323, longitude: -118.000)
  var totalResults: Int = 0
  var businesses: [Business] = []
  var searchTerm = "pizza"
  var currentOffset: Int = 0
  var isLoading = false
  var managedContext: NSManagedObjectContext!
  var delegate: WebNavigationDelegate?
  
  convenience init(service: BaseBusinessService) {
    self.init()
    businessService = service as? BusinessService
    managedContext = CoreDataManager.shared.persistentContainer.viewContext
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
      delegate?.updateView()
      isLoading = false
      return
    }
    isLoading = true
    businessService?.searchBusinesses(for: searchTerm, userCoordinate: userLocation, offset:currentOffset, completion: { [weak self] result in
      switch result {
      case .success(let businessData):
        self?.businesses += businessData.businesses ?? []
        self?.totalResults = businessData.total ?? businessData.businesses?.count ?? 0
        self?.delegate?.updateView()
        self?.isLoading = false
      case .failure(let error): print("error \(error.localizedDescription)")
      }
      
    })
  }
  
  func businessIndexPathSelected(for businessIndexPath: IndexPath, navigationType: BusinessDetailNavigationType) {
    
    let business = businesses[businessIndexPath.row]
    
    CoreDataManager.shared.creatOrUpdateFavorite(business, context: managedContext)
    guard let businessURL = business.url else { return }
    switch navigationType {
    case .safari : delegate?.navigateToSafari(businessURL)
    case .webkit : delegate?.navigateToWebKit(businessURL)
    }
  }
  
}
