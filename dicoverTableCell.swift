//
//  dicoverTableCell.swift
//  TIK TIK
//
//  Created by Rao Mudassar on 08/05/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.
//

import UIKit
import SDWebImage

class dicoverTableCell: UITableViewCell {
    
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var viewAll_Btn: UIButton!
    @IBOutlet weak var dis_label: UILabel!
    @IBOutlet weak var lblVideoCount: UILabel!
    
    @IBOutlet weak var hashtag_Img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class DiscoverAllVideoCell: UICollectionViewCell {
    
    
    @IBOutlet weak var video_image: SDAnimatedImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var view_Count_Lbl: UILabel!


    
    
}
