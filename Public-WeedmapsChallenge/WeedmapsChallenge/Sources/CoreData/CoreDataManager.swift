//
//  File.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/7/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import CoreData
import Foundation

class CoreDataManager: NSObject {
  static let shared = CoreDataManager()

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "CoreModel")
    container.loadPersistentStores(completionHandler: { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
        })
    return container
  }()

  func saveContext() {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }

  func creatOrUpdateFavorite(_ business: Business,
                             context: NSManagedObjectContext) {
    var favorite: Favorite!

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
    let predicateID = NSPredicate(format: "name == %@",
                                  business.name ?? "")
    fetchRequest.predicate = predicateID

    do {
      let results = try context.fetch(fetchRequest)
      if results.count > 0 {
        favorite = results.first as? Favorite
        favorite.visits = favorite.visits + 1
      } else {
        favorite = Favorite(context: context)
        favorite.name = business.name
        favorite.imageURL = business.image_url
        favorite.detailsURL = business.url
        favorite.visits = 1
      }
    } catch {
      print(error.localizedDescription)
    }
    saveContext()
  }
  
  func creatOrUpdateSearchTerm(_ searchTermString: String,
                             context: NSManagedObjectContext) {
    var searchTerm: SearchTerm!

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SearchTerm")
    let predicateID = NSPredicate(format: "searchString == %@", searchTerm)
    fetchRequest.predicate = predicateID

    do {
      let results = try context.fetch(fetchRequest)
      if results.count > 0 {
        searchTerm = results.first as? SearchTerm
      } else {
        searchTerm = SearchTerm(context: context)
        searchTerm.searchString = searchTermString
      }
    } catch {
      print(error.localizedDescription)
    }
    saveContext()
  }
  
}
