//
//  LoginViewController.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 6/18/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var email: String?
    var password: String?
    
    let backendless = Backendless.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBarButtonItemPressed(_ sender: UIBarButtonItem) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            self.email = emailTextField.text
            self.password = passwordTextField.text
            
            // login user
            loginUser(email!, password: password!)
            
        } else {
            // show an error to user
            ProgressHUD.showError("All fields are required.")
        }
    }
    
    func loginUser(_ email: String, password: String) {
        
        backendless?.userService.login(email, password: password, response: { (user: BackendlessUser?) -> Void in
            
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            
            // segue to recents view
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! UITabBarController
            
            vc.selectedIndex = 0
            
            self.present(vc, animated: true, completion: nil)
            
            }) { (fault: Fault?) -> Void in
                print("Couldn't login user\(fault)")
        }
    }

}
