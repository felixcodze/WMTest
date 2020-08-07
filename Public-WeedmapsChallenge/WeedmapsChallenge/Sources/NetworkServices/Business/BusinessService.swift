//
//  BusinessService.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/5/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import Alamofire
import CoreLocation
import Foundation

import Alamofire

class BusinessService: BaseBusinessService {
  let jsonDecoder = JSONDecoder()
  
  func searchBusinesses(for searchString: String, userCoordinate: CLLocationCoordinate2D, page: Int, completion: @escaping (Swift.Result<BusinessData, AFError>) -> Void) {
    AF.request(BusinessRouter.searchBusinesses(searchString: searchString,
                                               coordinate: userCoordinate,
                                               page: page))
      .responseDecodable { (response: AFDataResponse<BusinessData>) in
        completion(response.result)
      }
  }
}
