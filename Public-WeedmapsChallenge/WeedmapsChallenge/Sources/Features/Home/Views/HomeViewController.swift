//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
  // MARK: Properties

  @IBOutlet private var collectionView: UICollectionView!
  @IBOutlet private var searchHistoryTable: UITableView!
  @IBOutlet private var searchHistoryHeightConstraint: NSLayoutConstraint!

  private var searchController = UISearchController(searchResultsController: nil)
  private var searchResults = [Business]()
  private var searchDataTask: URLSessionDataTask?
  private var viewModel: HomeViewModel?
  var searchTask: DispatchWorkItem?

  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpCollectionView()
    setUpHistoryTableView()
    setUpViewModel()
    setUpSearchBar()
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
    let search = UISearchController(searchResultsController: nil)
    search.searchResultsUpdater = self
    search.obscuresBackgroundDuringPresentation = false
    search.searchBar.placeholder = "Search your location"
    navigationItem.searchController = search
    search.searchBar.delegate = self
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
      let currentSearch = self?.viewModel?.currentSearchString ?? ""
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
    guard !(searchController.searchBar.text?.isEmpty ?? false) else {
      viewModel?.resetSearch()
      viewModel?.searchForTerm("")
      return
    }
    viewModel?.searchForTerm(searchController.searchBar.text ?? "")
    viewModel?.loadAndDisplaySearchHistory(searchController.searchBar.text ?? "")
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
      self?.searchHistoryTable.isHidden = true
      
      UIApplication.shared.sendAction(#selector(self?.resignFirstResponder), to:nil, from:nil, for:nil)
    }
  }
}
