//
//  ChooseUserViewController.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 6/26/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import UIKit

protocol ChooseUserDelegate {
    func createChatRoom(_ withUser: BackendlessUser)
}

class ChooseUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var delegate: ChooseUserDelegate!
    var users: [BackendlessUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableviewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let user = users[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = user.name as String?
        
        return cell
    }
    
    // MARK: UITableviewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[(indexPath as NSIndexPath).row]
        delegate.createChatRoom(user)
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK: IBActions
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Load Backendless Users
    func loadUsers() {
        
        let whereClause = "objectId != '\(backendless?.userService.currentUser.objectId)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless?.persistenceService.of(BackendlessUser.ofClass())
//        dataStore.find(dataQuery, response: { (users: BackendlessCollection!) -> Void in
//            
//            self.users = users.data as! [BackendlessUser]
//            self.tableView.reloadData()
//            
//                
//            }) { (fault: Fault!) -> Void in
//                print("Error, couldn't retrive users: \(fault)")
//        }
        
        dataStore?.find(dataQuery, response: { (users:BackendlessCollection?) in
            self.users = users?.data as! [BackendlessUser]
            self.tableView.reloadData()
        }) { (error: Fault?) in
            print("Error, couldn't retrive users: \(error)")
        }
    }
}
