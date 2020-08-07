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

extension HomeViewController: HomeViewModelDelegate {
  func updateData() {
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
    // IMPLEMENT:
    // 1a) Present the user with a UIAlertController (action sheet style) with options
    // to either display the Business's Yelp page in a WKWebView OR bump the user out to
    // Safari. Both options should display the Business's Yelp page details
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 140, height: 180)
  }
  
}

// MARK: UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // IMPLEMENT:
    return viewModel?.businesses.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // IMPLEMENT:
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
