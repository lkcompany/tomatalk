//
//  FriendsViewController.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 7/30/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    
    var users: [NSDictionary] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadFriends()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let user = users[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = user["name"] as! String?
        
        return cell
    }
    
    func loadFriends() {
        firebase.child("Friends").child(backendless?.userService.currentUser.objectId as! String).queryOrdered(byChild: "objectId").observe(.value, with: { snapshot in
            
            self.users.removeAll()
            if snapshot.exists() {
                
                let sorted = ((snapshot.value! as AnyObject).allValues as NSArray).sortedArray(using: [NSSortDescriptor(key: "name", ascending: false)])
                
                for name in sorted {
                    
                    self.users.append(name as! NSDictionary)
                    
                    let item = name as! [String:AnyObject]
                    // add function to have offline access as well, this will download with user recent as well so that we will create it again
                    firebase.child("Friends").queryOrdered(byChild: "objectId").queryEqual(toValue: item["objectId"]).observe(.value, with: {
                        snapshot in
                        
                    })
                }
            }
            
            self.tableView.reloadData()
        })

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
