//
//  OutgoingMessage.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 6/26/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import Foundation


class OutgoingMessage {
    
    let messageDictionary: NSMutableDictionary
    
    init() {
        messageDictionary = [:]
    }
    
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = [
            "message" : message,
            "senderId" : senderId,
            "senderName" : senderName,
            "date" : dateFormatter().string(from: date),
            "status" : status,
            "type" : type
        ]
        
    }
    
    init(message: String, latitude: NSNumber, longitude: NSNumber, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = [
            "message" : message,
            "latitude" : latitude,
            "longitude" : longitude,
            "senderId" : senderId,
            "senderName" : senderName,
            "date" : dateFormatter().string(from: date),
            "status" : status,
            "type" : type
        ]
    }
    
    init(message: String, pictureData: Data, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        let pic = pictureData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        messageDictionary = [
            "message" : message,
            "picture" : pic,
            "senderId" : senderId,
            "senderName" : senderName,
            "date" : dateFormatter().string(from: date),
            "status" : status,
            "type" : type
        ]
    }
    
    func sendMessage(_ chatRoomID: String)
    {
        let reference = firebase.child("Message").child(chatRoomID).childByAutoId()
        self.messageDictionary["messageId"] = reference.key
        reference.setValue(messageDictionary) { (error, ref) -> Void in
            
            if error != nil {
                print("Error, couldn't send message")
            }
        }
        
        // send push notification to other users
        UpdateRecents(chatRoomID, lastMessage: (messageDictionary["message"] as? String)!)
    }
}
