//
//  MockBusinessService.swift
//  WeedmapsChallengeTests
//
//  Created by Felix Ortiz on 8/5/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//
@testable import WeedmapsChallenge

import CoreLocation
import Foundation

class MockBusinessService: BaseBusinessService {
  
  private var jsonDecoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }
  private var searchDataTask: URLSessionDataTask?
  
  func cancelSearch() {}
  
  func searchBusinesses(for searchString: String,
                        userCoordinate: CLLocationCoordinate2D,
                        offset: Int,
                        completion: @escaping (Swift.Result<BusinessData, Error>) -> Void) {
    let fileManager = FileManager.default
    let bundle = Bundle(for: MockBusinessService.self)
    
    let data = fileManager.contents(atPath: bundle.path(forResource: "YelpAPIJSONStub", ofType: "json")!)
    if let data = data {
      do {
        let businessData = try self.jsonDecoder.decode(BusinessData.self, from: data)
        completion(.success(businessData))
      } catch {
        let error = NSError(domain: "test", code: 911, userInfo: ["description":"test error"])
        completion(.failure(error))
      }
    } else {
      let error = NSError(domain: "test", code: 911, userInfo: ["description":"NO DATAe error"])
      completion(.failure(error))
    }
  }
}
