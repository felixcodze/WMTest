//
//  BusinessService.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/5/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import CoreLocation
import Foundation
import Alamofire

class BusinessService: BaseBusinessService {
  let jsonDecoder = JSONDecoder()
  private var searchDataTask: URLSessionDataTask?
  
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
