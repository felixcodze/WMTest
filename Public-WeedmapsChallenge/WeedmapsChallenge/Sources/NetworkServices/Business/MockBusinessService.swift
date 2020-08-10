//
//  MockBusinessService.swift
//  WeedmapsChallengeTests
//
//  Created by Felix Ortiz on 8/5/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import CoreLocation
import Foundation
import Alamofire

@testable import WeedmapsChallenge

class MockBusinessService: BaseBusinessService {
  
  static let stubData = BusinessData(total: 0,
                                     businesses: [
                                       Business(name: "", rating: 0, price: "5", phone: "", id: "1", alias: "", is_closed: false, categories: [], reviewCount: 0, url: "", coordinates: Coordinate(latitude: 0, longitude: 0), image_url: "", location: Location(address1: "", address2: "", address3: "", city: "", state: "", zip_code: "", country: ""), distance: 0, transactions: []),
                                       Business(name: "", rating: 0, price: "5", phone: "", id: "1", alias: "", is_closed: false, categories: [], reviewCount: 0, url: "", coordinates: Coordinate(latitude: 0, longitude: 0), image_url: "", location: Location(address1: "", address2: "", address3: "", city: "", state: "", zip_code: "", country: ""), distance: 0, transactions: [])
                                     ],
                                     region: Region(center: Coordinate(latitude: 0, longitude: 0)))

  func cancelSearch() {
    
  }
  
  func searchBusinesses(for searchString: String,
                        userCoordinate: CLLocationCoordinate2D,
                        offset: Int,
                        completion: @escaping (Swift.Result<BusinessData, Error>) -> Void) {
    completion(.success(MockBusinessService.stubData))
  }
}
