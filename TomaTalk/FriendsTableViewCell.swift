//
//  FriendsTableViewCell.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 7/30/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell{

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
