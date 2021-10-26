//
//  Home.swift
//  TIK TIK
//
//  Created by Rao Mudassar on 30/04/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.
//

import UIKit

class Home: NSObject {
    
    var share_count:String! = "0"
    var like_count:String! = "0"
    var view_count:String! = "0"
    var video_comment_count:String! = "0"
    var sound_name:String! = ""
    var thum:String! = ""
    var first_name:String! = ""
    var last_name:String! = ""
    var profile_pic:String! = ""
    var video_url:String! = ""
    var v_id:String! = ""
    var u_id:String! = ""
    var like:String! = "0"
    var desc:String! = ""
     var f_name:String! = ""
    var verified:Int? = 0
    var allow_comment:String! = "false"
   var allow_duet:String! = "0"
    var isFollow = 0
    
    init(like_count: String!, video_comment_count: String!, sound_name: String!,thum: String!, first_name: String!, last_name: String!,profile_pic: String!, video_url: String!, v_id: String!, u_id: String!, like: String!, desc: String!,f_name: String!, view_count: String!,verified: Int?, allow_comment: String!,allow_duet: String!,isFollow: Int, share_count: String!) {
        
        self.share_count = share_count
        self.like_count = like_count
        self.video_comment_count = video_comment_count
        self.sound_name = sound_name
        self.thum = thum
        self.first_name = first_name
        self.last_name = last_name
        self.profile_pic = profile_pic
        self.video_url = video_url
        self.v_id = v_id
        self.u_id = u_id
        self.like = like
        self.desc = desc
        self.f_name = f_name
        self.view_count = view_count
        self.verified = verified
        self.allow_duet = allow_duet
        self.allow_comment = allow_comment
        self.isFollow = isFollow
    }
}


class SoundObj: NSObject {
    
    
    var sound_id:String? = ""
    var audioUrl:String! = ""
    
    init(sound_id: String!, audioUrl: String!) {
        
        self.sound_id = sound_id
        self.audioUrl = audioUrl
    }
      
}
