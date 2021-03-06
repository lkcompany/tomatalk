//
//  RecentTableViewCell.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 6/20/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindData(_ recent: NSDictionary) {
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.layer.masksToBounds = true
        
        self.avatarImageView.image = UIImage(named: "avatarPlaceholder")
        
        let withUserId = (recent.object(forKey: "withUserUserId") as? String)!
        
        // get the backendless user and download avatar
        let whereClause = "objectId = '\(withUserId)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless?.persistenceService.of(BackendlessUser.ofClass())
        dataStore?.find(dataQuery, response: { (users: BackendlessCollection?) -> Void in
            
            let withUser = users?.data.first as! BackendlessUser
            if let avatarURL = withUser.getProperty("Avatar") as? String {
                
                getImageFromURL(avatarURL, result: { (image) in
                    
                    self.avatarImageView.image = image
                })
            }
            
            
            }) { (fault: Fault?) -> Void in
                print("error, couldn't get user avatar: \(fault)")
        }
        
        nameLabel.text = recent["withUserUserName"] as? String
        lastMessageLabel.text = recent["lastMessage"] as? String
        counterLabel.text = ""
        
        if (recent["counter"] as? Int)! != 0 {
            counterLabel.text = "\(recent["counter"]!) New"
        }
        
        let date = dateFormatter().date(from: (recent["date"] as? String)!)
        let seconds = Date().timeIntervalSince(date!)
        dateLabel.text = TimeElipsed(seconds)
    }
    
    func TimeElipsed(_ seconds: TimeInterval) -> String {
        let elapsed: String?
        
        if (seconds < 60) {
            elapsed = "Just Now"
        } else if (seconds < 24 * 60 * 60) {
            let minutes = Int(seconds / 60)
            
            var minText = "min"
            if minutes > 1 {
                minText = "mins"
            }
            elapsed = "\(minutes) \(minText)"
        } else if (seconds < 20 * 60 * 60) {
            let hours = Int(seconds / (60 * 60))
            var hourText = "hour"
            if hours > 1 {
                hourText = "hours"
            }
            elapsed = "\(hours) \(hourText)"
        } else {
            let days = Int(seconds / (24 * 60 * 60))
            var dayText = "day"
            if days > 1 {
                dayText = "days"
            }
            elapsed = "\(days) \(dayText)"
        }
        return elapsed!
    }
    
    
    
    
    
    
    

}
