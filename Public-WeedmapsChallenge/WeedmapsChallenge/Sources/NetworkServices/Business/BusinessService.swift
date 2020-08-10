//
//  BusinessService.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/5/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import CoreLocation
import Foundation

class BusinessService: BaseBusinessService {
  private var searchDataTask: URLSessionDataTask?
  
  private var jsonDecoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }
  
  func cancelSearch() {
    searchDataTask?.cancel()
  }
  
  func searchBusinesses(for searchString: String,
                        userCoordinate: CLLocationCoordinate2D,
                        offset: Int,
                        completion: @escaping (Swift.Result<BusinessData, Error>) -> Void) {
      let searchRequest = BusinessRouter.searchBusinesses(searchString: searchString,
                                                  coordinate: userCoordinate,
                                                  offset: offset).urlRequest!
    
    searchDataTask = URLSession.shared.dataTask(with: searchRequest) { [weak self] data, response, error in
      if let responseError = error {
        completion(.failure(responseError))
        return
      }
      
      if let data = data {
        do {
          if let businessData = try self?.jsonDecoder.decode(BusinessData.self, from: data){ 
            completion(.success(businessData))
          }
        }catch {
          
        }
      }
      
    }
    searchDataTask?.resume()
  }
}
