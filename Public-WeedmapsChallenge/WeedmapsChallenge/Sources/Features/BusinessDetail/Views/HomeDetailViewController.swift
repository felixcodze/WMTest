//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit
import WebKit

class HomeDetailViewController: BaseViewController {
  // MARK: Properties

  @IBOutlet private var webView: WKWebView!
  @IBOutlet private var loadingView: UIActivityIndicatorView!
  var viewModel: HomeDetailViewModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpNavigation()
    setUpViewModel()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel?.buildURLRequest()
  }
  
  func setUpNavigation() {
    webView.navigationDelegate = self
  }
  
  func setUpViewModel() {
    viewModel?.delegate = self
  }
  
}

extension HomeDetailViewController: HomeDetailViewModelDelegate {
  
  func updateWebView(urlRequest: URLRequest) {
    webView.load(urlRequest)
  }
  
  func updateView() {}
  
  func showError(error: NSError) {
    loadingView.stopAnimating()
    showError(title: "Oh No!", message: error.userInfo["description"] as! String)
  }
  
  
}

extension HomeDetailViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    loadingView.startAnimating()
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    loadingView.stopAnimating()
  }
}
