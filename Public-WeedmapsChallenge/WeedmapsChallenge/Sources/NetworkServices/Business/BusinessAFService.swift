//
//  BusinessAFService.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/7/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import CoreLocation
import Foundation
import Alamofire

class BusinessAFService: BaseBusinessService {
  private var jsonDecoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }
  private var searchDataTask: URLSessionDataTask?
  
  func cancelSearch() {
    AF.cancelAllRequests()
  }
  
  func searchBusinesses(for searchString: String,
                          userCoordinate: CLLocationCoordinate2D,
                          offset: Int,
                          completion: @escaping (Swift.Result<BusinessData, Error>) -> Void) {
    AF.request(BusinessRouter.searchBusinesses(searchString: searchString,
                                               coordinate: userCoordinate,
                                               offset: offset))
      .responseDecodable { (response: AFDataResponse<BusinessData>) in
        let error = NSError(domain: "", code: 999, userInfo: ["description": response.error?.localizedDescription ?? ""])
        completion(.failure(error))
      }
  }
  
}
