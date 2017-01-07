//
//  RegisterViewController.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 6/18/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var newUser: BackendlessUser?
    var email: String?
    var userName: String?
    var password: String?
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newUser = BackendlessUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        if emailTextField.text != "" && userNameTextField.text != "" && passwordTextField.text != "" {
            
            ProgressHUD.show("Registering...")
            email = emailTextField.text
            userName = userNameTextField.text
            password = passwordTextField.text
            
            register(self.email!, userName: self.userName!, password: self.password!, avatarImage: self.avatarImage)
        } else {
            // warning to user
            ProgressHUD.showError("All fields are required.")
        }
    }
    
    @IBAction func uploadPhotoButtonPressed(_ sender: AnyObject) {
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhto = UIAlertAction(title: "Take Phto", style: .default) { (alert: UIAlertAction!) in
            camera.PresentPhotoCamera(target: self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert: UIAlertAction!) in
            camera.PresentPhotoLibrary(target: self, canEdit: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) in
            print("Cancled")
        }
        
        optionMenu.addAction(takePhto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
    
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // MARK: UIImagepickercontroller delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.avatarImage = info[UIImagePickerControllerEditedImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Backendless user registration
    func register(_ email: String, userName: String, password: String, avatarImage: UIImage?) {
        
        if avatarImage == nil {
            newUser!.setProperty("Avatar", object: "")
        } else {
            uploadAvatar(avatarImage!, result: { (imageLink) in
                
                let properties = ["Avatar" : imageLink!]
                backendless?.userService.currentUser.updateProperties(properties)
                backendless?.userService.update(backendless?.userService.currentUser, response: { (updatedUser: BackendlessUser?) in
                    
                    print("Updated current user avatar")
                    }, error: { (fault: Fault?) in
                        print("Error couldn't set avatar image \(fault!)")
                })
            })
        }
        
        newUser!.email = email as NSString!
        newUser!.name = userName as NSString!
        newUser!.password = password as NSString!
        
        backendless?.userService.registering(newUser, response: { (registeredUser: BackendlessUser?) -> Void in
            
            ProgressHUD.dismiss()
            
            // login new user
            self.loginUser(email, userName: userName, password: password)
            self.userNameTextField.text = ""
            self.passwordTextField.text = ""
            self.emailTextField.text = ""
            
            }) { (fault: Fault?) -> Void in
                print("Server reported an error, couldn't register new user: \(fault)")
        }
    }
    
    func loginUser(_ email: String, userName: String, password: String) {
        
        backendless?.userService.login(email, password: password, response: { (user: BackendlessUser?) -> Void in
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as! UITabBarController
            
            vc.selectedIndex = 0

            self.present(vc, animated: true, completion: nil)
            
            }) { (fault: Fault?) -> Void in
                print("Server reported an error: \(fault)")
        }
        
    }

}
