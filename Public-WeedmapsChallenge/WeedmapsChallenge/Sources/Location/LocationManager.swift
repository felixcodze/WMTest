//
//  LocationManager.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/9/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

protocol LocationManagerDelegate: class {
  func updateLocation(with location: CLLocation)
  func locationDidFailWithError(_ error: NSError)
  func locationSettingsRequested()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
  
  static let shared = LocationManager()
  
  private var locationManager: CLLocationManager?
  public var lastLocation: CLLocation?
  private var alwaysTrackLocation = false
  weak var delegate: LocationManagerDelegate?
  
  var needToRequestPermissions: Bool {
    CLLocationManager.authorizationStatus() == .notDetermined ||
      CLLocationManager.authorizationStatus() == .denied
  }
  
  override init() {
    super.init()
    
    locationManager = CLLocationManager()
    locationManager?.delegate = self
  }
  
  func startService(alwaysTracking: Bool = false) {
    guard let locationManager = locationManager else { return }
    
    alwaysTrackLocation = alwaysTracking
    
    switch CLLocationManager.authorizationStatus() {
    case .notDetermined:
      locationManager.requestAlwaysAuthorization()
    case .denied:
      delegate?.locationSettingsRequested()
    default:
      locationManager.startUpdatingLocation()
    }
  }
  
  func stopService() {
    guard let locationManager = locationManager else { return }
    
    alwaysTrackLocation = false
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
      locationManager?.requestAlwaysAuthorization()
    case .denied:
      delegate?.locationSettingsRequested()
    default:
      guard let locationManager = locationManager else { return }
      
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.distanceFilter = 100

      locationManager.startUpdatingLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    
    // Stop tracking to avoid battery drain
    if !alwaysTrackLocation { locationManager?.stopUpdatingLocation() }
    
    lastLocation = location
    updateLocation(currentLocation: location)
  }
  
  private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    updateLocationDidFailWithError(error: error)
  }
  
  private func updateLocation(currentLocation: CLLocation) {
    delegate?.updateLocation(with: currentLocation)
  }
  
  private func updateLocationDidFailWithError(error: NSError) {
    delegate?.locationDidFailWithError(error)
  }
  
}
