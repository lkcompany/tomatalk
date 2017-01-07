//
//  WelcomeViewController.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 6/18/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    let backendless = Backendless.sharedInstance()
    
    override func viewWillAppear(_ animated: Bool) {
        backendless?.userService.setStayLoggedIn(true)
        
        if backendless?.userService.currentUser != nil {
            DispatchQueue.main.async{
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! UITabBarController
                vc.selectedIndex = 0
                
                self.present(vc, animated: true, completion: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fbLoginButton.readPermissions = ["public_profile", "email"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    

}
