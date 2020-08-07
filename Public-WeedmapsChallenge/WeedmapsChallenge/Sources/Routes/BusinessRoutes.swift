//
//  BusinessRoutes.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/6/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import Alamofire
import CoreLocation

enum BusinessRouter: URLRequestConvertible {
  case searchBusinesses(searchString: String, coordinate: CLLocationCoordinate2D, page: Int)

  // MARK: - HTTPMethod

  private var method: HTTPMethod {
    switch self {
    case .searchBusinesses:
      return .get
    }
  }
  
  private var apiKey: String {
    return "kqrbDfgf20keg3HUYv7FuUyg4Ia34Oj35RtknL92eqtpT39UNbencKNKvXuKEvRvHgTO8UCOlr6lAXSKMKqYdATGQ2b8Q4CVvIwtUu6VFSl2ciOeYkmgxgl9C8orX3Yx"
  }

  // MARK: - Path

  private var path: String {
    switch self {
    case .searchBusinesses:
      return "search"
    }
  }

  // MARK: - Parameters

  private var parameters: Parameters? {
    switch self {
    case .searchBusinesses(let searchString, let coordinate, let page):
      return ["term": searchString,
              "latitude": coordinate.latitude,
              "longitude": coordinate.longitude,
              "page": page,
              "limit": 15]
    }
  }

  func asURLRequest() throws -> URLRequest {
    guard
      let url = URL(string: "https://api.yelp.com/v3/businesses/")
    else {
      return URLRequest(url: URL(string: "")!)
    }
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    urlRequest.httpMethod = method.rawValue
    urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    if let parameters = parameters {
        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
    }

    return urlRequest
  }
}
