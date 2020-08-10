//
//  Copyright © 2018 Weedmaps, LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  // MARK: Properties
  
  var window: UIWindow?
  
  // MARK: Lifecycle
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    initializeStyles()
    return true
  }
  
  func initializeStyles(){
    UINavigationBar.appearance().backgroundColor = UIColor.white
    UIBarButtonItem.appearance().tintColor = UIColor.red
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
    UITabBar.appearance().tintColor = UIColor.red
  }
}
