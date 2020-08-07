//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit
import WebKit

class HomeDetailViewController: UIViewController {
  // MARK: Properties

  @IBOutlet private var webView: WKWebView!
  var viewModel: HomeDetailViewModel?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadPage()
  }
  
  func loadPage() {
    guard
      let businessURLString = viewModel?.currentURLString,
      let businessURL = URL(string: businessURLString)
    else { return }
    let businessRequest = URLRequest(url: businessURL)
    webView.load(businessRequest)
  }
  
}
