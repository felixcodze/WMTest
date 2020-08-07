//
//  BaseService.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/5/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import CoreLocation
import Foundation
import Alamofire

protocol BaseBusinessService {
  func cancelSearch()
  func searchBusinesses(for searchString: String,
                       userCoordinate: CLLocationCoordinate2D,
                       offset: Int,
                       completion: @escaping (Swift.Result<BusinessData, AFError>) -> Void)
  
}
