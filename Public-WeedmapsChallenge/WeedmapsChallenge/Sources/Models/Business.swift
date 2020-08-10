//
//  Business.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/5/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import Foundation

struct BusinessData: Decodable {
  let total: Int?
  let businesses: [Business]?
  let region: Region?
}

struct Business: Decodable {
  let name: String?
  let rating: Float?
  let price: String?
  let phone: String?
  let id: String?
  let alias: String?
  let isClosed: Bool?
  let categories: [Category]?
  let reviewCount: Int?
  let url: String?
  let coordinates: Coordinate?
  let imageUrl: String?
  let location: Location?
  let distance: Float?
  let transactions: [String]?
}

struct Region: Decodable {
  let center: Coordinate?
}

struct Coordinate: Decodable {
  let latitude: Double?
  let longitude: Double?
}

struct Category: Decodable {
  let alias: String?
  let title: String?
}

struct Location: Decodable {
  let address1: String?
  let address2: String?
  let address3: String?
  let city: String?
  let state: String?
  let zipCode: String?
  let country: String?
}
