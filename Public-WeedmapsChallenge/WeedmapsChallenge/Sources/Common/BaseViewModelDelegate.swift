//
//  BaseViewModelDelegate.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/8/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import Foundation

protocol BaseViewModelDelegatge: class {
  func updateView()
}

protocol WebNavigationDelegate: BaseViewModelDelegatge {
  func navigateToWebKit(_ urlString: String)
  func navigateToSafari(_ urlString: String)
}
