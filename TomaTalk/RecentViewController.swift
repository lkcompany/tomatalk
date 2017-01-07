//
//  RecentViewController.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 6/21/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import UIKit

class RecentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChooseUserDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var recents: [NSDictionary] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRecents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentTableViewCell
        
        let recent = recents[(indexPath as NSIndexPath).row]
        
        cell.bindData(recent)
        
        return cell
    }
    
    // MARK: UITableViewDelegate functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recent = recents[(indexPath as NSIndexPath).row]
        
        // create recent for other users
        RestartRecentChat(recent)
        
        performSegue(withIdentifier: "recentToChatSeg", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let recent = recents[(indexPath as NSIndexPath).row]
        
        // remove recent from the array
        recents.remove(at: (indexPath as NSIndexPath).row)
        
        // delete recent from friebase
        DeleteRecentItem(recent)
        
        tableView.reloadData()
    }
    
    // MARK: - IBActions
    @IBAction func startNewChatBarButtonItemPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "recentToChooseUserVC", sender: self)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "recentToChooseUserVC" {
            let vc = segue.destination as! ChooseUserViewController
            vc.delegate = self
        }
        
        if segue.identifier == "recentToChatSeg" {
            let indexPath = sender as! IndexPath
            let chatVC = segue.destination as! ChatViewController
            chatVC.hidesBottomBarWhenPushed = true
            
            let recent = recents[(indexPath as NSIndexPath).row]
            
            // set chatVC recent to our recent.
            chatVC.recent = recent
            chatVC.chatRoomId = recent["chatRoomID"] as! String
            
        }
    }
    
    // MARK: ChooseUserDelegate
    func createChatRoom(_ withUser: BackendlessUser) {
        
        let chatVC = ChatViewController()
        chatVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(chatVC, animated: true)
        // set chatVC recent to our recent.
        chatVC.withUser = withUser
        chatVC.chatRoomId = startChat((backendless?.userService.currentUser)!, user2: withUser)
    }
    
    // MARK: Load Recents from firebase
    func loadRecents() {
        
        firebase.child("Recent").queryOrdered(byChild: "userId").queryEqual(toValue: backendless?.userService.currentUser.objectId).observe(.value, with: { snapshot in
            
            self.recents.removeAll()
            if snapshot.exists() {
                
                let sorted = ((snapshot.value! as AnyObject).allValues as NSArray).sortedArray(using: [NSSortDescriptor(key: "date", ascending: false)])
                
                for recent in sorted {
                    
                    self.recents.append(recent as! NSDictionary)
                    
                    let item = recent as! [String:AnyObject]
                    // add function to have offline access as well, this will download with user recent as well so that we will create it again
                    firebase.child("Recent").queryOrdered(byChild: "chatRoomID").queryEqual(toValue: item["chatRoomID"]).observe(.value, with: {
                        snapshot in
                        
                    })
                }
            }
            
            self.tableView.reloadData()
        })
    }
}
