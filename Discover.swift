//
//  Discover.swift
//  TIK TIK
//
//  Created by Rao Mudassar on 08/05/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.
//

import UIKit

struct ItemVideo {
    
    var video:String! = ""
    var thum:String! = ""
    var liked:String! = "0"
    var like_count:String! = "0"
    var video_comment_count:String! = "0"
    var first_name:String = ""
    var last_name:String! = ""
    var profile_pic:String! = ""
    var sound_name:String! = ""
    var v_id:String! = "0"
    var u_id:String! = "0"
    var description:String! = ""
    var view_count:String! = "0"
    var f_name:String = ""
    var audio_url:String = ""
    var s_id:String! = "0"
    var share:String! = "0"
    var totalView :String = ""
    var hashtagIcon : String = ""
    var is_follow:String! = "0"
    
}

class Discover: NSObject {
    
    
    var name:String! = ""
    var section_Id:String! = ""
    var totalView :String = ""
    var hashtagIcon : String = ""
    var listOfProducts = [ItemVideo]()
    var sectionInd:Int? = 0
    
}

