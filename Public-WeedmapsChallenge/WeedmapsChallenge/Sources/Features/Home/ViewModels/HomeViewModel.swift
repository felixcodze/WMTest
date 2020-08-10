//
//  HomeViewModel.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/5/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import CoreData
import CoreLocation
import Foundation

enum BusinessDetailNavigationType {
  case safari
  case webkit
}

protocol HomeViewModelDelegate: WebNavigationDelegate {
  func updateSearchHistoryTable()
}

class HomeViewModel {
  var businessService: BusinessService?
  var userLocation = CLLocationCoordinate2D(latitude: 34.323, longitude: -118.000)
  var totalResults: Int = 0
  var businesses: [Business] = []
  var currentSearchString = ""
  var currentOffset: Int = 0
  var isLoading = false
  var managedContext: NSManagedObjectContext!
  var delegate: HomeViewModelDelegate?
  var searchTerms: [SearchTerm] = []
  
  convenience init(service: BaseBusinessService) {
    self.init()
    businessService = service as? BusinessService
    managedContext = CoreDataManager.shared.persistentContainer.viewContext
  }
  
  func resetSearch() {
    businessService?.cancelSearch()
    searchTerms = []
    currentOffset = 0
    businesses = []
    delegate?.updateView()
    delegate?.updateSearchHistoryTable()
  }
  
  func loadNextPage() {
    if isLoading {
      return
    }
    currentOffset += K.businessPageLimit
    searchForTerm(currentSearchString)
  }
  
  func searchForTerm(_ term: String) {
    guard !term.isEmpty else {
      resetSearch()
      delegate?.updateView()
      isLoading = false
      return
    }
    
    currentSearchString = term
    isLoading = true
    businessService?.searchBusinesses(for: term,
                                      userCoordinate: userLocation,
                                      offset: currentOffset,
                                      completion: { [weak self] result in
                                        guard let self = self else { return }
                                        switch result {
                                        case .success(let businessData):
                                          self.businesses += businessData.businesses ?? []
                                          self.totalResults = businessData.total ?? businessData.businesses?.count ?? 0
                                          self.delegate?.updateView()
                                          self.isLoading = false
                                          if self.currentOffset == 0 {
                                            self.saveSearchTerm(term, resultCount: self.totalResults)
                                          }
                                        case .failure(let error):
                                          self.delegate?.showError(error: error as NSError)
                                        }
                                        
    })
  }
  
  func businessIndexPathSelected(for businessIndexPath: IndexPath,
                                 navigationType: BusinessDetailNavigationType) {
    let business = businesses[businessIndexPath.row]
    
    CoreDataManager.shared.creatOrUpdateFavorite(business, context: managedContext)
    guard let businessURL = business.url else { return }
    switch navigationType {
    case .safari: delegate?.navigateToSafari(businessURL)
    case .webkit: delegate?.navigateToWebKit(businessURL)
    }
  }
  
  func searchFromHistoryIndex(_ indexPath: IndexPath) {
    let searchTerm = searchTerms[indexPath.row]
    
    guard let searchString = searchTerm.searchString else {
      return
    }
    resetSearch()
    searchForTerm(searchString)
  }
  
  func saveSearchTerm(_ searchTerm: String, resultCount: Int) {
    CoreDataManager.shared.creatOrUpdateSearchTerm(searchTerm, resultCount: resultCount, context: managedContext)
  }
  
  func loadAndDisplaySearchHistory(_ term: String) {
    let fetchRequest = NSFetchRequest<SearchTerm>(entityName: "SearchTerm")
    let sort = NSSortDescriptor(key: "searchString", ascending: true)
    let predicate = NSPredicate(format:"SELF.searchString CONTAINS %@", term)
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = [sort]
    do {
      searchTerms = try managedContext.fetch(fetchRequest)
      delegate?.updateSearchHistoryTable()
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }
}
