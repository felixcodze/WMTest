//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

@testable import WeedmapsChallenge
import XCTest
import CoreLocation

class YelpAPIClientTests: XCTestCase {
  private var businessViewModel: HomeViewModel?
  
  override func setUp() {
    super.setUp()
    businessViewModel = HomeViewModel(service: MockBusinessService())
    businessViewModel?.userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    businessViewModel?.delegate = self
  }
  
  override func tearDown() {
    super.tearDown()
    businessViewModel = nil
  }
  
  func testBusinessModelDecodedFromJsonYieldsExpectedResult() {
    businessViewModel?.searchForTerm("test")
  }
  
  func testBusinessModelSearchHistory() {
    businessViewModel?.loadAndDisplaySearchHistory("test")
  }
  
  func testNavigateToWKView() {
    businessViewModel?.searchForTerm("test")
    let indexPath = IndexPath(row: 0, section: 0)
    businessViewModel?.businessIndexPathSelected(for: indexPath, navigationType: .webkit)
  }
  
  func testNavigateToSafari() {
    businessViewModel?.searchForTerm("test")
    let indexPath = IndexPath(row: 0, section: 0)
    businessViewModel?.businessIndexPathSelected(for: indexPath, navigationType: .webkit)
  }
  
}

extension YelpAPIClientTests: HomeViewModelDelegate {
  func updateSearchHistoryTable() {
    XCTAssertTrue(businessViewModel?.historySearchString == "test")
  }
  
  func navigateToWebKit(_ urlString: String) {
    XCTAssertTrue(urlString == "https://www.yelp.com/biz/four-barrel-coffee-san-francisco", "URL INVALID")
  }
  
  func navigateToSafari(_ urlString: String) {
    XCTAssertTrue(urlString == "https://www.yelp.com/biz/four-barrel-coffee-san-francisco", "URL INVALID")
  }
  
  func updateWebView(urlRequest: URLRequest) {
    XCTAssertTrue(1 == 1)
  }
  
  func updateView() {
    guard let viewModel = businessViewModel else {
      XCTFail("VIEW MODEL MUST EXIST")
      return
    }
    XCTAssertTrue(viewModel.businesses.count == 1, "SHOULD BE ONLY 1 BUSINESS IN JSON")
    
    guard let business = businessViewModel?.businesses.first else {
      XCTFail("SHOULD BE 1 VALID BUSINESS")
      return
    }
    
    XCTAssertTrue(business.rating == 4, "RATING INVALID")
    XCTAssertTrue(business.price == "$", "PRICE INVALID")
    XCTAssertTrue(business.phone == "+14152520800", "PRICE INVALID")
    XCTAssertTrue(business.id == "E8RJkjfdcwgtyoPMjQ_Olg", "ID INVALID")
    XCTAssertTrue(business.categories?.first?.title == "Coffee & Tea", "CATEGORY TITLE INVALID")
    XCTAssertTrue(business.categories?.first?.alias == "coffee", "ALIAS INVALID")
    XCTAssertTrue(business.isClosed == false, "IS CLOSED INVALID")
    XCTAssertTrue(business.categories?.count == 1)
    XCTAssertTrue(business.reviewCount == 1738, "REVIEW COUNT INVALID")
    XCTAssertTrue(business.name == "Four Barrel Coffee", "NAME INVALID")
    XCTAssertTrue(business.url == "https://www.yelp.com/biz/four-barrel-coffee-san-francisco", "URL INVALID")
    XCTAssertTrue(business.coordinates?.latitude == 37.7670169511878, "LATITUDE INVALID")
    XCTAssertTrue(business.coordinates?.longitude == -122.42184275, "LONGITUDE INVALID")
    XCTAssertTrue(business.imageUrl == "http://s3-media2.fl.yelpcdn.com/bphoto/MmgtASP3l_t4tPCL1iAsCg/o.jpg", "IMAGEURL INVALID")
    XCTAssertTrue(business.location?.city == "San Francisco", "CITY INVALID")
    XCTAssertTrue(business.location?.country == "US", "COUNTRY INVALID")
    XCTAssertTrue(business.location?.address1 == "375 Valencia St", "ADDRESS1 INVALID")
    XCTAssertTrue(business.location?.address2 == "Apt B", "ADDRESS2 INVALID")
    XCTAssertTrue(business.location?.address3 == "NORTH 5", "ADDRESS3 INVALID")
    XCTAssertTrue(business.location?.state == "CA", "STATE INVALID")
    XCTAssertTrue(business.location?.zipCode == "94103", "ZIPCODE INVALID")
    XCTAssertTrue(business.distance == 1604.23, "DISTANCE INVALID")
    XCTAssertTrue(business.transactions == ["pickup", "delivery"], "TRANSACTIONS INVALID")
    XCTAssertTrue(viewModel.totalResults == 1, "TOTAL RESULTS INVALID")
  }
  
  func showError(error: NSError) {}
}
