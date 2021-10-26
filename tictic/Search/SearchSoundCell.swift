//
//  SearchSoundCell.swift
//  TIK TIK
//
//  Created by Apple on 11/07/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit

class SearchSoundCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var favouriteBtn: UIButton!
    
    @IBOutlet weak var descLbl: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
