//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {
  
  @IBOutlet private var favoritesTable: UITableView!
  var viewModel: FavoritesViewModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpTableView()
    setUpViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel?.loadFavorites()
  }
  
  func setUpViewModel() {
    viewModel = FavoritesViewModel()
    viewModel?.delegate = self
  }
  
  func setUpTableView() {
    favoritesTable.register(UINib(nibName: "FavoriteCell", bundle: nil), forCellReuseIdentifier: "FavoriteCell")

  }
  
}

extension FavoritesViewController: WebNavigationDelegate {
  
  func navigateToWebKit(_ urlString: String) {
    let storyBoard = UIStoryboard(name: "HomeDetail", bundle: .main)
    guard
      let webKitController = storyBoard.instantiateInitialViewController() as?
      HomeDetailViewController
    else { return }
    webKitController.viewModel = HomeDetailViewModel(detailURLString: urlString)
    navigationController?.pushViewController(webKitController, animated: true)
  }
  
  func navigateToSafari(_ urlString: String) {
    guard
      let businessDetailURL = URL(string: urlString)
    else { return }
    if UIApplication.shared.canOpenURL(businessDetailURL) {
      UIApplication.shared.open(businessDetailURL)
    }
  }
  
  func updateView() {
    favoritesTable.reloadData()
  }
  
  
}

extension FavoritesViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel?.favorites.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoriteCell else {
      return UITableViewCell()
    }
    cell.favorite = viewModel?.favorites[indexPath.row]
    cell.updateCell()
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
}

extension FavoritesViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let alert = UIAlertController(title: K.businessDetailAlertTitle, message: K.businessDetailAlertDetail, preferredStyle: .actionSheet)
    
    alert.addAction(UIAlertAction(title: K.businessDetailsAlertWKActionTitle, style: .default, handler: { [weak self] (_) in
      self?.viewModel?.favoriteIndexPathSelected(for: indexPath, navigationType: .webkit)
    }))

    alert.addAction(UIAlertAction(title: K.businessDetailsAlertSafariActionTitle, style: .default, handler: { [weak self] (_) in
      self?.viewModel?.favoriteIndexPathSelected(for: indexPath, navigationType: .safari)
    }))

    alert.addAction(UIAlertAction(title: K.businessDetailsAlertCancelTitle, style: .cancel, handler: { (_) in
        
    }))
    alert.modalPresentationStyle = .fullScreen
    self.present(alert, animated: true, completion:nil)
  }
}
