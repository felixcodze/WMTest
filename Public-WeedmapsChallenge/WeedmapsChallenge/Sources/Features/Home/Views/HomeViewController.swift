//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import CoreLocation
import UIKit

class HomeViewController: BaseViewController {
  // MARK: Properties

  @IBOutlet private var collectionView: UICollectionView!
  @IBOutlet private var searchHistoryTable: UITableView!
  @IBOutlet private var searchHistoryHeightConstraint: NSLayoutConstraint!

  private var searchController = UISearchController(searchResultsController: nil)
  private var searchResults = [Business]()
  private var searchDataTask: URLSessionDataTask?
  private var viewModel: HomeViewModel?
  var searchWorkItem: DispatchWorkItem?

  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpCollectionView()
    setUpHistoryTableView()
    setUpViewModel()
    setUpSearchBar()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    LocationManager.shared.delegate = self
    LocationManager.shared.startService()
  }

  func setUpCollectionView() {
    collectionView.register(UINib(nibName: "BusinessCell",
                                  bundle: nil),
                            forCellWithReuseIdentifier: "BusinessCell")
    collectionView.delegate = self
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillShow),
                                           name: UIResponder.keyboardWillShowNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardDidHide),
                                           name: UIResponder.keyboardDidHideNotification,
                                           object: nil)
  }

  func setUpHistoryTableView() {
    searchHistoryTable.isHidden = true
    searchHistoryTable.register(UINib(nibName: "SearchHistoryCell", bundle: nil), forCellReuseIdentifier: "SearchHistoryCell")
    searchHistoryTable.delegate = self
    searchHistoryTable.dataSource = self
  }

  func setUpViewModel() {
    viewModel = HomeViewModel(service: BusinessService())
    viewModel?.delegate = self
  }

  func setUpSearchBar() {
    navigationController?.navigationBar.topItem?.title = "SEARCH AND ENJOY"
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = K.searchPlaceholder
    navigationItem.searchController = searchController
    searchController.searchBar.delegate = self
  }

  @objc func keyboardWillShow(_ notification: Notification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      let keyboardHeight = keyboardRectangle.height
      DispatchQueue.main.async { [weak self] in
        self?.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
      }
    }
  }

  @objc func keyboardDidHide(_ notification: Notification) {
    DispatchQueue.main.async { [weak self] in
      self?.collectionView.contentInset = .zero
    }
  }

  func searchNow() {}
}

// MARK: VIEW MODEL DELEGATE

extension HomeViewController: HomeViewModelDelegate {
  func showError(error: NSError) {
    if let otherError = error.userInfo["description"] as? String {
      showError(title: "Oh No!", message: otherError)
    } else {
      showError(title: "Oh No!", message: error.localizedDescription)
    }
  }

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

  func updateSearchHistoryTable() {
    DispatchQueue.main.async { [weak self] in
      self?.searchHistoryTable.reloadData()
      let termCount = self?.viewModel?.searchTerms.count ?? 0
      let currentSearch = self?.viewModel?.historySearchString ?? ""
      self?.searchHistoryTable.isHidden = termCount == 0 || currentSearch.isEmpty
      self?.searchHistoryHeightConstraint.constant = min(K.searchHistoryMaxTableHeight,
                                                         CGFloat(termCount * 40))
    }
  }

  func showSelectionAlert(indexPath: IndexPath) {
    let alert = UIAlertController(title: K.businessDetailAlertTitle, message: K.businessDetailAlertDetail, preferredStyle: .actionSheet)

    alert.addAction(UIAlertAction(title: K.businessDetailsAlertWKActionTitle, style: .default, handler: { [weak self] _ in
      self?.viewModel?.businessIndexPathSelected(for: indexPath, navigationType: .webkit)
    }))

    alert.addAction(UIAlertAction(title: K.businessDetailsAlertSafariActionTitle, style: .default, handler: { [weak self] _ in
      self?.viewModel?.businessIndexPathSelected(for: indexPath, navigationType: .safari)
    }))

    alert.addAction(UIAlertAction(title: K.businessDetailsAlertCancelTitle, style: .cancel, handler: { _ in

    }))
    alert.modalPresentationStyle = .fullScreen

    DispatchQueue.main.async { [weak self] in
      self?.present(alert, animated: true, completion: nil)
    }
  }
}

// MARK: UISearchResultsUpdating

extension HomeViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    
    guard
      viewModel?.userLocation != nil
    else {
      LocationManager.shared.startService()
      return
    }
    
    guard let searchText = searchController.searchBar.text,
      searchText.isEmpty == false
    else {
      viewModel?.resetSearch()
      viewModel?.searchForTerm("")
      return
    }

    viewModel?.loadAndDisplaySearchHistory(searchText)

    searchWorkItem?.cancel()

    // Wrap our request in a work item
    let requestWorkItem = DispatchWorkItem { [weak self] in
      self?.viewModel?.searchForTerm(searchText)
    }
    // Save the new work item and execute it after 250 ms
    searchWorkItem = requestWorkItem
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500),
                                  execute: requestWorkItem)
  }
}

extension HomeViewController: UISearchBarDelegate {
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    DispatchQueue.main.async { [weak self] in
      self?.viewModel?.resetSearch()
      self?.searchHistoryTable.isHidden = true
    }
  }

  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    DispatchQueue.main.async { [weak self] in
      self?.searchHistoryTable.isHidden = true
    }
  }
}

// MARK: UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    searchController.dismiss(animated: true, completion: nil)
    showSelectionAlert(indexPath: indexPath)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let paddingSpace = K.businessCellBorderSpacing * (K.businessCellWidthDivider + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / K.businessCellWidthDivider
    return CGSize(width: widthPerItem, height: K.businessCellHeight)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 10,
                        left: K.businessCellBorderSpacing,
                        bottom: 10,
                        right: K.businessCellBorderSpacing)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 20
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 20
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
    cell.business = viewModel?.businesses[indexPath.row]
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

extension HomeViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel?.searchTerms.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryCell", for: indexPath) as? SearchHistoryCell else {
      return UITableViewCell()
    }
    cell.searchTerm = viewModel?.searchTerms[indexPath.row]
    cell.currentTerm = viewModel?.currentSearchString ?? ""
    cell.updateCell()
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40
  }
}

extension HomeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    DispatchQueue.main.async { [weak self] in
      self?.viewModel?.searchFromHistoryIndex(indexPath)
      self?.searchController.isActive = true
      self?.searchController.searchBar.text = self?.viewModel?.searchTerms[indexPath.row].searchString ?? ""
      self?.searchController.dismiss(animated: true, completion: nil)
      self?.searchHistoryTable.isHidden = true
    }
  }
}

extension HomeViewController: LocationManagerDelegate {
  func updateLocation(with location: CLLocation) {
    guard let term = viewModel?.currentSearchString else {
      return
    }
    viewModel?.userLocation = location.coordinate
    viewModel?.searchForTerm(term)
  }

  func locationDidFailWithError(_ error: NSError) {
    showError(error: error)
  }

  func locationSettingsRequested() {
    let alertController = UIAlertController(title: "Oh No!", message: "You need to turn on location settings", preferredStyle: .alert)

    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_: UIAlertAction!) in
      UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }

    let OKAction = UIAlertAction(title: "OK", style: .default) { (_: UIAlertAction!) in
    }

    alertController.addAction(OKAction)
    alertController.addAction(settingsAction)
    
    DispatchQueue.main.async { [weak self] in
      self?.present(alertController, animated: true, completion: nil)
    }
  }
}
