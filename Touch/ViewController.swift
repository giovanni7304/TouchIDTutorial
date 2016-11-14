/*
*/

import UIKit
import CoreData

class ViewController: UITableViewController {
  var isAuthenticated = false
   var didReturnFromBackground = false
 
    var managedObjectContext: NSManagedObjectContext? = nil
  var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil

  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem
    
    view.alpha = 0
    
  
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.appWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(ViewController.appDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
  }
  
  @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {

    isAuthenticated = true
    view.alpha = 1.0
  }
  
  func appWillResignActive(_ notification : Notification) {

    view.alpha = 0
    isAuthenticated = false
    didReturnFromBackground = true
  }
  
  func appDidBecomeActive(_ notification : Notification) {

    if didReturnFromBackground {
      self.showLoginView()
    }
  }

  
  override func viewDidAppear(_ animated: Bool) {
    
    super.viewDidAppear(false)
    self.showLoginView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func showLoginView() {
    
    if !isAuthenticated {

      self.performSegue(withIdentifier: "loginSegue", sender: self)
    }
  }
    
  @IBAction func logoutAction(_ sender: AnyObject) {

    isAuthenticated = false
    self.performSegue(withIdentifier: "loginSegue", sender: self)
  }
  
}

