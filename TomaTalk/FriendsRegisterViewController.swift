//
//  FriendsRegisterViewController.swift
//  TomaTalk
//
//  Created by 이영호 on 2017. 1. 22..
//  Copyright © 2017년 skywalk. All rights reserved.
//

import Foundation

class FriendRegisterViewController : UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    var friend: BackendlessUser?
    var email: String?
    
    override func viewWillDisappear(_ animated: Bool) {
        firebase.removeAllObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        friend = BackendlessUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        if emailTextField.text != "" {
            
            ProgressHUD.show("Registering...")
            email = emailTextField.text
            
            register(self.email!)
        } else {
            // warning to user
            ProgressHUD.showError("All fields are required.")
        }
    }
    
    // MARK: Firebase friend registration
    func register(_ email: String) {
        
        friend!.email = email as NSString!
        
        let whereClause = "email = '\(email)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless?.persistenceService.of(BackendlessUser.ofClass())
        dataStore?.find(dataQuery, response: { (users:BackendlessCollection?) in
            let users = users?.data as! [BackendlessUser]
            let friendObjectId : String = users.first?.objectId as! String
            let friendName : String = users.first?.name as! String
            
            let userObjectId = backendless?.userService.currentUser.objectId as! String
            
            
            let reference = firebase.child("Friends").child(userObjectId).child(friendObjectId)
            
            let friendDictionary : NSMutableDictionary = [
                "name" : friendName
                , "objectId" : friendObjectId
            ]
            
            reference.setValue(friendDictionary) { (error, ref) -> Void in
                if error != nil {
                    print("Error, couldn't regist friend")
                }
            }
            
        }) { (error: Fault?) in
            print("Couldn't find user\(error)")
        }

        ProgressHUD.dismiss()
        
    }
}
