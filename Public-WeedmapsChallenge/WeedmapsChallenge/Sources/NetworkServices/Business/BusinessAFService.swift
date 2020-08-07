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
  let jsonDecoder = JSONDecoder()
  private var searchDataTask: URLSessionDataTask?
  
  func cancelSearch() {
    AF.cancelAllRequests()
  }
  
  func searchBusinesses(for searchString: String,
                          userCoordinate: CLLocationCoordinate2D,
                          offset: Int,
                          completion: @escaping (Swift.Result<BusinessData, AFError>) -> Void) {
    AF.request(BusinessRouter.searchBusinesses(searchString: searchString,
                                               coordinate: userCoordinate,
                                               offset: offset))
      .responseDecodable { (response: AFDataResponse<BusinessData>) in
        completion(response.result)
      }
  }
  
}
