//
//  ProfileCell.swift
//  TIK TIK
//
//  Created by Rao Mudassar on 14/05/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileCell: UICollectionViewCell {
    
    
    @IBOutlet weak var video_image: SDAnimatedImageView!
    
    @IBOutlet weak var lbl_seen: UILabel!
    
    
}

class DraftCell: UICollectionViewCell {
    
    
    @IBOutlet weak var video_image: SDAnimatedImageView!
    @IBOutlet weak var btnClose: UIButton!
    
    
}

class CreateVideoTableViewCell: UICollectionViewCell {
    
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var btnView: UIButton!


}
