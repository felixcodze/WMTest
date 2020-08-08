//
//  FavoritesViewModel.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/6/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import CoreData
import Foundation

class FavoritesViewModel {
  var managedContext: NSManagedObjectContext!
  var favorites: [Favorite] = []
  var delegate: WebNavigationDelegate?

  init(){
    managedContext = CoreDataManager.shared.persistentContainer.viewContext
  }

  
  func loadFavorites() {
    let fetchRequest = NSFetchRequest<Favorite>(entityName: "Favorite")
    let sort = NSSortDescriptor(key: "visits", ascending: false)
    fetchRequest.sortDescriptors = [sort]
    do {
      favorites = try managedContext.fetch(fetchRequest)
      delegate?.updateView()
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }
  
  func favoriteIndexPathSelected(for businessIndexPath: IndexPath, navigationType: BusinessDetailNavigationType) {
    
    let favorite = favorites[businessIndexPath.row]

    guard let detailsURL = favorite.detailsURL else { return }
    switch navigationType {
    case .safari : delegate?.navigateToSafari(detailsURL)
    case .webkit : delegate?.navigateToWebKit(detailsURL)
    }
  }
}
