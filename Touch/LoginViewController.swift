/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import CoreData
import LocalAuthentication

class LoginViewController: UIViewController {
  
  var managedObjectContext: NSManagedObjectContext? = nil
  let MyKeychainWrapper = KeychainWrapper()
  let createloginButtonTag = 0
  let loginButtonTag = 1
  var context = LAContext()
    
    
    
    @IBOutlet weak var loginButton: UIButton!
    
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var createInfoLabel: UILabel!  

    @IBOutlet weak var touchIDButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // 1.
    let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
    
    // 2.
    if hasLogin {
        loginButton.setTitle("Login", for: UIControlState.normal)
        loginButton.tag = loginButtonTag
        createInfoLabel.isHidden = true
    } else {
        loginButton.setTitle("Create", for: UIControlState.normal)
        loginButton.tag = createloginButtonTag
        createInfoLabel.isHidden = false
    }
    
    // 3.
    if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
        usernameTextField.text = storedUsername as String
    }
    touchIDButton.isHidden = true
    
    if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) {
        touchIDButton.isHidden = false
    }
  }
  
    // MARK: - Action for checking username/password
    @IBAction func touchIDLoginAction(_ sender: Any) {
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error:nil) {
            
            // 2.
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Logging in with Touch ID",
                                   reply: { (success : Bool, error : NSError? ) -> Void in
                                    
                                    // 3.
                                    dispatch_async(dispatch_get_main_queue(), {
                                        if success {
                                            self.performSegueWithIdentifier("dismissLogin", sender: self)
                                        }
                                        
                                        if error != nil {
                                            
                                            var message : NSString
                                            var showAlert : Bool
                                            
                                            // 4.
                                            switch(error!.code) {
                                            case LAError.AuthenticationFailed.rawValue:
                                                message = "There was a problem verifying your identity."
                                                showAlert = true
                                                break;
                                            case LAError.UserCancel.rawValue:
                                                message = "You pressed cancel."
                                                showAlert = true
                                                break;
                                            case LAError.UserFallback.rawValue:
                                                message = "You pressed password."
                                                showAlert = true
                                                break;
                                            default:
                                                showAlert = true
                                                message = "Touch ID may not be configured"
                                                break;
                                            }
                                            
                                            let alertView = UIAlertController(title: "Error",
                                                                              message: message as String, preferredStyle:.Alert)
                                            let okAction = UIAlertAction(title: "Darn!", style: .Default, handler: nil)
                                            alertView.addAction(okAction)
                                            if showAlert {
                                                self.presentViewController(alertView, animated: true, completion: nil)
                                            }
                                            
                                        }
                                    })
                                    
            })
        } else {
            // 5.
            let alertView = UIAlertController(title: "Error",
                                              message: "Touch ID not available" as String, preferredStyle:.Alert)
            let okAction = UIAlertAction(title: "Darn!", style: .Default, handler: nil)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    @IBAction func loginPressed(_ sender: Any) {
        if( usernameTextField.text == "" || passwordTextField.text == "" )
        {    let alertView = UIAlertController(title: "Login Problem.", message: "Wrong username or password." as String, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Foiled Again", style: .default, handler: nil)
            alertView.addAction(okAction)
            self.present(alertView, animated: true, completion: nil)
            return
        }
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if (sender as AnyObject).tag == createloginButtonTag {
            print("at createLoginButtonTag")
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if hasLoginKey == false {
                print("at has login key")
                UserDefaults.standard.setValue(self.usernameTextField.text, forKey: "username")
            }
            
            // 5.
            print("at 5")
            MyKeychainWrapper.mySetObject(passwordTextField.text, forKey:kSecValueData)
            MyKeychainWrapper.writeToKeychain()
            UserDefaults.standard.set(true, forKey: "hasLoginKey")
            UserDefaults.standard.synchronize()
            loginButton.tag = loginButtonTag
            
            print("at perform segue")
            performSegue(withIdentifier: "dismissLogin", sender: self)
        } else if (sender as AnyObject).tag == loginButtonTag {
            // 6.
            if checkLogin(username: usernameTextField.text!, password: passwordTextField.text!) {
                performSegue(withIdentifier: "dismissLogin", sender: self)
            } else {
                // 7.
                let alertView = UIAlertController(title: "Login Problem",
                                                  message: "Wrong username or password." as String, preferredStyle:.alert)
                let okAction = UIAlertAction(title: "Foiled Again!", style: .default, handler: nil)
                alertView.addAction(okAction)
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func loginAction(_ sender: AnyObject) {
        if( usernameTextField.text == "" || passwordTextField.text == "" )
        {    let alertView = UIAlertController(title: "Login Problem.", message: "Wrong username or password." as String, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Foiled Again", style: .default, handler: nil)
            alertView.addAction(okAction)
            self.present(alertView, animated: true, completion: nil)
            return
        }

        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if sender.tag == createloginButtonTag {
            
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if hasLoginKey == false {
                UserDefaults.standard.setValue(self.usernameTextField.text, forKey: "username")
            }
            
            // 5.
            MyKeychainWrapper.mySetObject(passwordTextField.text, forKey:kSecValueData)
            MyKeychainWrapper.writeToKeychain()
            UserDefaults.standard.set(true, forKey: "hasLoginKey")
            UserDefaults.standard.synchronize()
            loginButton.tag = loginButtonTag
            
            performSegue(withIdentifier: "dismissLogin", sender: self)
        } else if sender.tag == loginButtonTag {
            // 6.
            if checkLogin(username: usernameTextField.text!, password: passwordTextField.text!) {
                performSegue(withIdentifier: "dismissLogin", sender: self)
            } else {
                // 7.
                let alertView = UIAlertController(title: "Login Problem",
                                                  message: "Wrong username or password." as String, preferredStyle:.alert)
                let okAction = UIAlertAction(title: "Foiled Again!", style: .default, handler: nil)
                alertView.addAction(okAction)
                self.present(alertView, animated: true, completion: nil)
            }
        }

    }
    
    func checkLogin(username: String, password: String ) -> Bool {
        if password == MyKeychainWrapper.myObject(forKey: "v_Data") as? String &&
            username == UserDefaults.standard.value(forKey: "username") as? String {
            return true
        } else {
            return false
        }
    }
  
}
