//
//  UserNameTableViewCell.swift
//  TIK TIK
//
//  Created by Apple on 14/10/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit

class UserNameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var username_TextFeild: UITextField!
    @IBOutlet weak var username_Lbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        username_TextFeild.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 10)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
