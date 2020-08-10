//
//  BaseViewController.swift
//  WeedmapsChallenge
//
//  Created by Felix Ortiz on 8/9/20.
//  Copyright © 2020 Weedmaps, LLC. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
  
  func showError(title: String , message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in

    }
    
    alertController.addAction(OKAction)
    DispatchQueue.main.async { [weak self] in
      self?.present(alertController, animated: true, completion:nil)
    }
    
  }
  
}
