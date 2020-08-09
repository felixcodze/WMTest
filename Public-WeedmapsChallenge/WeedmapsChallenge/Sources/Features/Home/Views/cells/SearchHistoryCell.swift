//
//  SearchHistoryCell.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/8/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import UIKit

class SearchHistoryCell: UITableViewCell {
  
  @IBOutlet private var searchTermLabel: UILabel!
  @IBOutlet private var searchDateLabel: UILabel!
  @IBOutlet private var resultCountLabel: UILabel!
  
  var searchTerm: SearchTerm!
  var currentTerm: String = ""
  
  func updateCell() {
    searchDateLabel.text = searchTerm.searchDate?.formattedDate(format: "dd/mm/yy") ?? ""
    resultCountLabel.text = "\(searchTerm.resultCount) results"
    highlightSearchText()
  }
  
  func highlightSearchText() {
    guard let searchString = searchTerm.searchString else {
      return
    }
    let searchNSString =  searchString as NSString
    let searchTermRange = searchNSString.range(of: currentTerm, options: .caseInsensitive)
   
    if searchTermRange.location != NSNotFound {
      let searchAttributedString = NSMutableAttributedString(string: searchString)
      searchAttributedString.setAttributes([.font: UIFont.boldSystemFont(ofSize: 14)], range: searchTermRange)
      searchTermLabel.attributedText = searchAttributedString
    } else {
      searchTermLabel.text = searchString
    }
    
  }
}
