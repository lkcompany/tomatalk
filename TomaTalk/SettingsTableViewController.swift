//
//  SettingsTableViewController.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 7/7/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SettingsTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var privacyCell: UITableViewCell!
    @IBOutlet weak var termsCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var avatarSwitch: UISwitch!
    
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var avatarCell: UITableViewCell!
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var avatarSwitchStatus = true
    let userDefaults = UserDefaults.standard
    var firstLoad: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableHeaderView = HeaderView
        imageUser.layer.cornerRadius = imageUser.frame.size.width / 2
        imageUser.layer.masksToBounds = true
        
        loadUserDefaults()
        updateUI()
    }
    
    func loadUserDefaults() {
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(avatarSwitchStatus, forKey: kAVATARSTATE)
            userDefaults.synchronize()
        }
        
        avatarSwitchStatus = userDefaults.bool(forKey: kAVATARSTATE)
    }
    
    // MARK: UpdateUI
    
    func updateUI() {
        
        userNameLabel.text = backendless?.userService.currentUser.name as String?
        avatarSwitch.setOn(avatarSwitchStatus, animated: false)
        
        if let imageLink = backendless?.userService.currentUser.getProperty("Avatar") as? String {
            
            getImageFromURL(imageLink, result: { (image) -> Void in
                
                self.imageUser.image = image
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBACtions
    
    @IBAction func didClickAvatarImage(_ sender: AnyObject) {
        changePhoto()
    }
    
    // MARK: Change photo
    
    func changePhoto() {
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert: UIAlertAction!) -> Void in
            camera.PresentPhotoCamera(target: self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert: UIAlertAction!) -> Void in
            camera.PresentPhotoLibrary(target: self, canEdit: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) -> Void in
            
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func ChangedAvatarSwitchValue(_ switchState: UISwitch) {
        
        if switchState.isOn {
            avatarSwitchStatus = true
        } else {
            avatarSwitchStatus = false
        }
        
        saveUserDefaults()
    }
    
    // MARK: UIImagePickerControllerDelegate functions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        
        uploadAvatar(image) { (imageLink) in
            
            let properties = ["Avatar" : imageLink!]
            backendless?.userService.currentUser!.updateProperties(properties)
            backendless?.userService.update(backendless?.userService.currentUser, response: { (updatedUser: BackendlessUser?) -> Void in
                
                print("Updated current user \(updatedUser)")
                }, error: { (fault: Fault?) -> Void in
                
            })
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UserDefaults
    
    func saveUserDefaults() {
        
        userDefaults.set(avatarSwitchStatus, forKey: kAVATARSTATE)
        userDefaults.synchronize()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 3
        }
        if section == 1 {
            return 1
        }
        return 0
    }
    
    
    // MARK: Tableview delegate functions

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 {
            return privacyCell
        }
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 1 {
            return termsCell
        }
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 2 {
            return avatarCell
        }
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            return logoutCell
        }

        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        } else {
            return 25.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            
            showLogoutView()
        }
    }
    
    // MARK: Helper functions
    
    func showLogoutView() {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (alert: UIAlertAction!) in
            
            self.logout()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
            print("Cancel")
        }
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func logout() {
        
        backendless?.userService.logout()
        
        if FBSDKAccessToken.current() != nil {
            
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
        
        let loginView = storyboard!.instantiateViewController(withIdentifier: "LoginView")
        self.present(loginView, animated: true, completion: nil)
        
    }
}
