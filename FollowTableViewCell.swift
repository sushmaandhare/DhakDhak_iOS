//
//  FollowTableViewCell.swift
//  TIK TIK
//
//  Created by Rao Mudassar on 30/06/2020.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit

class FollowTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var follow_img: UIImageView!
    
    @IBOutlet weak var follow_view: UIView!
    
    @IBOutlet weak var folow_name: UILabel!
    
    @IBOutlet weak var folow_username: UILabel!
    
    @IBOutlet weak var btn_follow: UIButton!
    
    @IBOutlet weak var foolow_btn_view: UIView!
    @IBOutlet weak var imgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
//        self.btn_follow.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


class NotificationTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var videoImg: UIImageView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var user_img: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var userImgView: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var playImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

