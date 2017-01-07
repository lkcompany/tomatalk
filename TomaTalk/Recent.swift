//
//  Recent.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 6/24/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import Foundation
import FirebaseDatabase

// ------ constants ----------------
public let kAVATARSTATE = "avatarState"
public let kFIRSTRUN = "firstRun"
//---------------------------------

let backendless = Backendless.sharedInstance()
let firebase = FIRDatabase.database().reference()


// MARK: Create ChatRoom
func startChat(_ user1: BackendlessUser, user2: BackendlessUser) -> String {
    
    // user 1 is current usser
    let userId1: String = user1.objectId as String
    let userId2: String = user2.objectId as String
    
    var chatRoomId: String = ""
    let value = userId1.compare(userId2).rawValue
    if value < 0 {
        chatRoomId = userId1 + userId2
    } else {
        chatRoomId = userId2 + userId2
    }
    
    let members = [userId1, userId2]
    // create recent
    CreateRecent(userId1, chatRoomID: chatRoomId, members: members, withUserUserName: user2.name! as String, withUserUserId: userId2)
    CreateRecent(userId2, chatRoomID: chatRoomId, members: members, withUserUserName: user1.name! as String, withUserUserId: userId1)
    
    return chatRoomId
}

// MARK: Create Recent

func CreateRecent(_ userId: String, chatRoomID: String, members: [String], withUserUserName: String, withUserUserId: String) {
    
    // we query our recents where chatroomID is = to our chatroomID
    firebase.child("Recent").queryOrdered(byChild: "chatRoomID").queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value, with: { snapshot in
    
        var create = true
        
        //var count = snapshot.value!.allValues.count
        
        // check if we have a result
        if snapshot.exists() {
            for recent in (snapshot.value! as AnyObject).allValues {
                // if we already have recent with passed userId (we check for each user), don't create one
                let items = recent as! [String:AnyObject]
                if items["userId"] as! String == userId {
                    create = false
                }
            }
        }
        
        if create {
            CreateRecentItem(userId, chatRoomID: chatRoomID, members: members, withUserUserName: withUserUserName, withUserUserId: withUserUserId)
        }
    })
}

func CreateRecentItem(_ userId: String, chatRoomID: String, members: [String], withUserUserName: String, withUserUserId: String) {
    
    let reference = firebase.child("Recent").childByAutoId() // generate autoid done by firebase
    
    let recentId = reference.key
    let date = dateFormatter().string(from: Date())
    
    let recent = ["recentId" : recentId, "userId" : userId, "chatRoomID" : chatRoomID, "members" : members
        , "withUserUserName" : withUserUserName, "lastMessage" : "", "counter" : 0, "date" : date, "withUserUserId" : withUserUserId] as [String : Any]
    
    // save to firebase
    reference.setValue(recent) { (error, reference) -> Void in
        if error != nil {
            print("error creating recent \(error)")
        }
    }
}

// MARK: Update Recent
func UpdateRecents(_ chatRoomID: String, lastMessage: String) {
    
    firebase.child("Recent").queryOrdered(byChild: "chatRoomID").queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value, with: {
        snapshot in
        
        if snapshot.exists() {
            for recent in (snapshot.value! as AnyObject).allValues {
                UpdateRecentItem(recent as! NSDictionary, lastMessage: lastMessage)
            }
        }
    })
}

func UpdateRecentItem(_ recent: NSDictionary, lastMessage: String) {
    
    let date = dateFormatter().string(from: Date())
    var counter = recent["counter"] as! Int
    
    if recent["userId"] as? String != backendless?.userService.currentUser.objectId as! String {
        counter += 1
    }
    
    //firebase.childByAppendingPath(recent["recentId"] as? String)
    
    let values = ["lastMessage" : lastMessage, "counter" : counter, "date" : date] as [String : Any]
    firebase.child("Recent").child(recent["recentId"] as! String).updateChildValues(values as [AnyHashable: Any], withCompletionBlock: {
        (error, ref) -> Void in
        if error != nil {
            print("Error couldn't update recent item")
        }
    })
}

// MARK: Restart Recent Chat
func RestartRecentChat(_ recent: NSDictionary) {
    
    for userId in recent["members"] as! [String] {
        
        if (userId != backendless?.userService.currentUser.objectId as! String) {
            
            CreateRecent(userId, chatRoomID: (recent["chatRoomID"] as? String)!, members: recent["members"] as! [String], withUserUserName: backendless?.userService.currentUser.name as! String, withUserUserId: backendless?.userService.currentUser.objectId as! String)
        }
    }
}

// MARK: Delete Recent functions
func DeleteRecentItem(_ recent: NSDictionary) {
    firebase.child("Recent").child((recent["recentId"] as? String)!).removeValue { (error, ref) -> Void in
        if error != nil {
            print("Error deleting recent item: \(error)")
        }
    }
}

// MARK: Clear recent counter function

func ClearRecentCounter(_ chatRoomID: String) {
    
    firebase.child("Recent").queryOrdered(byChild: "chatRoomID").queryEqual(toValue: chatRoomID).observeSingleEvent(of: .value, with: {
        snapshot in
        
        if snapshot.exists() {
            
            for recent in (snapshot.value! as AnyObject).allValues {
            
                //let item = recent as! [String:AnyObject]
                /*if ((recent as AnyObject).object(forKey: "userId") as? String)! == backendless?.userService.currentUser.objectId {
                    ClearRecentCounterItem(recent as! NSDictionary)
                }*/
                
                let item = (recent as AnyObject).object(forKey: "userId") as? String
                
                if (item! == backendless?.userService.currentUser.objectId as! String) {
                    ClearRecentCounterItem(recent as! NSDictionary)
                }
            }
        }
        
    })
}

func ClearRecentCounterItem(_ recent: NSDictionary) {
    
    firebase.child("Recent").child(recent["recentId"] as! String).updateChildValues(["counter" : 0]) {
        (error, ref) in
        
        if error != nil {
            print("Error couldn't update recents counter: \(error?.localizedDescription)")
        }
    }
}

// MARK: Helper functions

private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}
