//
//  ChatViewController.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 6/26/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import IDMPhotoBrowser

class ChatViewController: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let userDefaults = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var messages: [JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = []
    
    var avatarImagesDictionary: NSMutableDictionary?
    var avatarDictionary: NSMutableDictionary?
    var showAvatars: Bool = false
    var firstLoad: Bool?
    
    var withUser: BackendlessUser?
    var recent: NSDictionary?
    
    var chatRoomId: String!
    
    var initialLoadComplete: Bool = false
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadUserDefaults()
    }
    
    func loadUserDefaults() {
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(showAvatars, forKey: kAVATARSTATE)
            userDefaults.synchronize()
        }
        
        showAvatars = userDefaults.bool(forKey: kAVATARSTATE)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        ClearRecentCounter(chatRoomId)
        firebase.removeAllObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = backendless?.userService.currentUser.objectId as String!
        self.senderDisplayName = backendless?.userService.currentUser.name as String!
        
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        
        if withUser?.objectId == nil {
            
            getWithUserFromRecent(recent: recent!, result: { (withUser) in
                self.withUser = withUser
                self.title = withUser.name as String?
                self.getAvatars()
            })
        } else {
            self.title = self.withUser?.name as String?
            self.getAvatars()
        }
        //self.title = self.withUser?.name
        //self.getAvatars()
        
        // load firebase messages
        loadMessages()
        
        self.inputToolbar?.contentView?.textView?.placeHolder = "New Message"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: JSQMessages dataSource functions
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[(indexPath as NSIndexPath).row]
        if data.senderId == backendless?.userService.currentUser.objectId as! String {
            cell.textView?.textColor = UIColor.white
        } else { // imcoming message
            cell.textView?.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        let data = messages[indexPath.row]
        
        return data
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        if data.senderId == backendless?.userService.currentUser.objectId as! String {
            return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            
            let message = messages[indexPath.row]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = objects[indexPath.row]
        let status = message["status"] as! String
        if outgoing(item: objects[indexPath.row]) {
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        let avatar = avatarDictionary!.object(forKey: message.senderId) as! JSQMessageAvatarImageDataSource
        
        return avatar
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if outgoing(item: objects[indexPath.row]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    // MARK: JSQMessages Delegate function
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if text != "" {
            sendMessage(text: text, date: date, picture: nil, location: nil)
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let camera = Camera(delegate_:self)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert: UIAlertAction) -> Void in
            
            camera.PresentPhotoCamera(target: self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert: UIAlertAction) -> Void in
            
            camera.PresentPhotoLibrary(target: self, canEdit: true)
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (alert: UIAlertAction) -> Void in
            
            if self.haveAccessToLocation() {
                self.sendMessage(text: nil, date: Date(), picture: nil, location: "Location")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction) -> Void in
            
            print("Cancel")
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    // MARK: Send Message
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?) {
        
        var outgoingMessage = OutgoingMessage()
        
        // if text message
        if let text = text {
            outgoingMessage = OutgoingMessage(message: text, senderId: backendless?.userService.currentUser.objectId as! String, senderName: backendless?.userService.currentUser.name as! String, date: date, status: "Delivered", type: "text")
        }
        
        // send picture message
        if let pic = picture {
            
            let imageData = UIImageJPEGRepresentation(pic, 1.0)
            outgoingMessage = OutgoingMessage(message: "Picture", pictureData: imageData!, senderId: backendless?.userService.currentUser.objectId as! String, senderName: backendless?.userService.currentUser.name as! String, date: date, status: "Delivered", type: "picture")
        }
        
        if let _ = location {
            
            let lat: NSNumber = NSNumber(value: (appDelegate.coordinate?.latitude)! as Double)
            let lng: NSNumber = NSNumber(value: (appDelegate.coordinate?.longitude)! as Double)
            
            outgoingMessage = OutgoingMessage(message: "Location", latitude: lat, longitude: lng, senderId: backendless?.userService.currentUser.objectId as! String, senderName: backendless?.userService.currentUser.name as! String, date: date, status: "Delivered", type: "location")
        }
        
        // play message sent sound
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishReceivingMessage()
        
        ///outgoingMessage!.sendMessage(chatRoomId, item: outgoingMessage!.messageDictionary)
        outgoingMessage.sendMessage(chatRoomId)
        
        self.inputToolbar?.contentView?.textView?.text=""
    }
    
    // MARK: Load Message
    func loadMessages() {
        
        firebase.child("Message").child(chatRoomId).observe(.childAdded, with: {
            snapshot in
            
            if snapshot.exists() {
                let item = (snapshot.value as? NSDictionary)!
                
                if self.initialLoadComplete {
                    
                    let incoming = self.insertMessage(item: item)
                    if incoming {
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    }
                    
                    self.finishReceivingMessage(animated: true)
                    
                } else {
                    // add each `dictionary to loaded array
                    self.loaded.append(item)
                }
            }
        })
        
        firebase.child("Message").child(chatRoomId).observe(.childChanged, with: {
            snapshot in
            
            // updated message
        })
        
        firebase.child("Message").child(chatRoomId).observe(.childRemoved, with: {
            snapshot in
            
            // Deleted message
        })
        
        firebase.child("Message").child(chatRoomId).observeSingleEvent(of: .value, with: {
            snapshot in
            
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            self.initialLoadComplete = true
        })
    }
    
    func insertMessages() {
        for item in loaded {
            // create message
            insertMessage(item: item)
        }
    }
    
    func insertMessage(item: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(dictionary: item)
        
        objects.append(item)
        messages.append(message!)
        
        return incoming(item: item)
    }
    
    func incoming(item: NSDictionary) -> Bool {
        
        //if backendless?.userService.currentUser.objectId == item["senderId"] as! String {
        if backendless?.userService.currentUser.objectId as! String == item["senderId"] as! String {
            return false
        } else {
            return true
        }
    }
    
    func outgoing(item: NSDictionary) -> Bool {
        
        if backendless?.userService.currentUser.objectId as! String == item["senderId"] as! String {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Helper functions
    
    func haveAccessToLocation() -> Bool {
        if let _ = appDelegate.coordinate?.latitude {
            return true
        } else {
            return false
        }
    }
    
    func getAvatars() {
        
        if showAvatars {
            
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
            
            // download avatars
            avatarImageFromBackendlessUser(user: (backendless?.userService.currentUser)!)
            avatarImageFromBackendlessUser(user: withUser!)
            
            // create avatars
            createAvatars(avatars: avatarImagesDictionary)
        }
    }
    
    func getWithUserFromRecent(recent: NSDictionary, result: @escaping (_ withUser: BackendlessUser) -> Void) {
        
        let withUserId = recent["withUserUserId"] as? String
        let whereClause = "objectId = '\(withUserId!)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless?.persistenceService.of(BackendlessUser.ofClass())
        dataStore?.find(dataQuery, response: { (users: BackendlessCollection?) in
            
            let withUser = users?.data.first as! BackendlessUser
            result(withUser)
            
            }) { (fault: Fault?) in
                print("Server report an error : \(fault)")
        }
    }
    
    func createAvatars(avatars: NSMutableDictionary?) {
        
        var currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        
        var withUserAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        
        if let avatar = avatars {
            
            if let currentUserAvatarImage = avatar.object(forKey: backendless?.userService.currentUser.objectId) {
                
                currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: currentUserAvatarImage as! Data), diameter: 70)
                self.collectionView.reloadData()
            }
        }
        
        if let avatar = avatars {
            
            if let withUserAvatarImage = avatar.object(forKey: withUser!.objectId!) {
                
                withUserAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: withUserAvatarImage as! Data), diameter: 70)
                self.collectionView?.reloadData()
            }
        }
        
        avatarDictionary = [backendless?.userService.currentUser.objectId : currentUserAvatar,
                                  withUser!.objectId! : withUserAvatar]
    }
    
    func avatarImageFromBackendlessUser( user: BackendlessUser) {
        
        if let imageLink = user.getProperty("Avatar") as? String {
            
            getImageFromURL(imageLink, result: { (image) in
                
                let imageData = UIImageJPEGRepresentation(image!, 1.0)
                if self.avatarImagesDictionary != nil {
                    
                    self.avatarImagesDictionary!.removeObject(forKey: user.objectId)
                    self.avatarImagesDictionary?.setObject(imageData!, forKey: user.objectId!)
                } else {
                    self.avatarImagesDictionary = [user.objectId! : imageData!]
                }
                self.createAvatars(avatars: self.avatarImagesDictionary)
            })
        }
    }
    
    // MARK: JSQDelegate functions
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let object = objects[indexPath.row]
        if object["type"] as! String == "picture" {
            
            let message = messages[indexPath.row]
            let mediaItem = message.media as! JSQPhotoMediaItem
            let photos = IDMPhoto.photos(withImages: [mediaItem.image])
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.present(browser!, animated: true, completion: nil)
        }
        
        if object["type"] as! String == "location" {
            
            self.performSegue(withIdentifier: "chatToMapSeg", sender: indexPath)
        }
    }
    
    // MARK: UIImagePickerController functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let picture = info[UIImagePickerControllerEditedImage] as! UIImage
        self.sendMessage(text: nil, date: Date(), picture: picture, location: nil)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "chatToMapSeg" {
            
            let indexPath = sender as! IndexPath
            let message = messages[(indexPath as NSIndexPath).row]
            
            let mediaItem = message.media as! JSQLocationMediaItem
            
            let mapView = segue.destination as! MapViewController
            mapView.location = mediaItem.location
        }
    }
}
