//
//  IncomingMessage.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 7/2/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessage {
    
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    func createMessage(dictionary: NSDictionary) -> JSQMessage? {
        
        var message: JSQMessage?
        
        let type = dictionary["type"] as? String
        if type == "text" {
            // create text message
            message = createTextMessage(item: dictionary)
        }
        
        if type == "location" {
            // create location message
            message = createLocationMessage(item: dictionary)
        }
        
        if type == "picture" {
            message = createPictureMessage(item: dictionary)
        }
        
        if let mes = message {
            return mes
        }
        
        return nil
    }
    
    func createTextMessage(item: NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        let text = item["message"] as? String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
    
    func createLocationMessage(item: NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        let latitude = item["latitude"] as? Double
        let longitude = item["longitude"] as? Double
        
        let mediaItem = JSQLocationMediaItem(location: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId: userId!)
        
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        mediaItem?.setLocation(location) { () -> Void in
            // update our collectionView
            self.collectionView.reloadData()
            
        }
        
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
    }
    
    func returnOutgoingStatusFromUser(senderId: String) -> Bool {
        
        if senderId == backendless?.userService.currentUser.objectId as! String {
            // outgoing
            return true
        } else {
            return false
        }
    }
    
    func createPictureMessage(item: NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        let date = dateFormatter().date(from: (item["date"] as? String)!)
        let mediaItem = JSQPhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId: userId!)
        
        imageFromData(item) { (image: UIImage?) -> Void in
            
            mediaItem?.image = image
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
    }
    
    func imageFromData(_ item: NSDictionary, result: (_ image: UIImage?) -> Void) {
        
        var image: UIImage?
        let decodedData = Data(base64Encoded: (item["picture"] as? String)!, options:
        NSData.Base64DecodingOptions(rawValue: 0))
        
        image = UIImage(data: decodedData!)
        
        result(image)
    }
}
