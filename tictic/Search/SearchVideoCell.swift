//
//  SearchVideoCell.swift
//  TIK TIK
//
//  Created by Apple on 11/07/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit

class SearchVideoCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var profile1ImageView: UIImageView!
    @IBOutlet weak var name1Lbl: UILabel!
    @IBOutlet weak var desc1Lbl: UILabel!
    @IBOutlet weak var watch1Btn: UIButton!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
