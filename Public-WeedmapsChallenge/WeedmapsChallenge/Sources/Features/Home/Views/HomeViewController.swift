//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
  // MARK: Properties

  @IBOutlet private var collectionView: UICollectionView!

  private var searchController = UISearchController(searchResultsController: nil)
  private var searchResults = [Business]()
  private var searchDataTask: URLSessionDataTask?
  private var viewModel: HomeViewModel?

  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpCollectionView()
    setUpViewModel()
    setUpSearchBar()
  }
  
  func setUpCollectionView() {
    collectionView.register(UINib(nibName: "BusinessCell",
          bundle: nil),
    forCellWithReuseIdentifier: "BusinessCell")
    collectionView.delegate = self
  }
  
  func setUpViewModel() {
    viewModel = HomeViewModel(service: BusinessService())
    viewModel?.delegate = self
    viewModel?.searchForBusiness()
  }
  
  func setUpSearchBar() {
    let search = UISearchController(searchResultsController: nil)
    search.searchResultsUpdater = self
    search.obscuresBackgroundDuringPresentation = false
    search.searchBar.placeholder = "Type something here to search"
    navigationItem.searchController = search
  }
  
}

// MARK: VIEW MODEL DELEGATE

extension HomeViewController: WebNavigationDelegate {
  
  func navigateToWebKit(_ urlString: String) {
    let storyBoard = UIStoryboard(name: "HomeDetail", bundle: .main)
    guard
      let webKitController = storyBoard.instantiateInitialViewController() as?
      HomeDetailViewController
    else { return }
    webKitController.viewModel = HomeDetailViewModel(detailURLString: urlString)
    DispatchQueue.main.async { [weak self] in
      self?.navigationController?.pushViewController(webKitController, animated: true)
    }
    
  }
  
  func navigateToSafari(_ urlString: String) {
    guard
      let businessDetailURL = URL(string: urlString)
    else { return }
    DispatchQueue.main.async {
      if UIApplication.shared.canOpenURL(businessDetailURL) {
        UIApplication.shared.open(businessDetailURL)
      }
    }
  }
  
  func updateView() {
    DispatchQueue.main.async { [weak self] in
      self?.collectionView.reloadData()
    }
    
    for biz in viewModel?.businesses ?? [] {
      print(biz.name ?? "no name")
    }
  }
}


// MARK: UISearchResultsUpdating

extension HomeViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    viewModel?.resetSearch()
    viewModel?.searchTerm = searchController.searchBar.text ?? ""
    viewModel?.searchForBusiness()
  }
}

// MARK: UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let alert = UIAlertController(title: K.businessDetailAlertTitle, message: K.businessDetailAlertDetail, preferredStyle: .actionSheet)
    
    alert.addAction(UIAlertAction(title: K.businessDetailsAlertWKActionTitle, style: .default, handler: { [weak self] (_) in
      self?.viewModel?.businessIndexPathSelected(for: indexPath, navigationType: .webkit)
    }))

    alert.addAction(UIAlertAction(title: K.businessDetailsAlertSafariActionTitle, style: .default, handler: { [weak self] (_) in
      self?.viewModel?.businessIndexPathSelected(for: indexPath, navigationType: .safari)
    }))

    alert.addAction(UIAlertAction(title: K.businessDetailsAlertCancelTitle, style: .cancel, handler: { (_) in
        
    }))
    alert.modalPresentationStyle = .fullScreen
    
    DispatchQueue.main.async { [weak self] in
      self?.present(alert, animated: true, completion:nil)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 140, height: 180)
  }
  
}

// MARK: UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel?.businesses.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCell", for: indexPath) as? BusinessCell else {
      return UICollectionViewCell()
    }
    cell.name = viewModel?.businesses[indexPath.row].name ?? "NO NAME"
    cell.updateCell()
    return cell
  }
  
  
}

extension HomeViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if abs(scrollView.contentOffset.y) >= scrollView.contentSize.height - scrollView.bounds.size.height {
      viewModel?.loadNextPage()
    }
  }
}
