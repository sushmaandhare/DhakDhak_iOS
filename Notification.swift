//
//  Notification.swift
//  TIK TIK
//
//  Created by Rao Mudassar on 02/07/2020.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit

class Notifications: NSObject {
    
    var effected_fb_id:String! = ""
    var first_name:String! = ""
    var last_name:String! = ""
    var profile_pic:String! = ""
    var username:String! = ""
    var type:String! = ""
    
    var v_id:String! = ""
    var fb_id:String! = ""
    var Vvalue:String! = ""
    var thum:String! = ""
    
    
    init(effected_fb_id: String!, first_name: String!, last_name: String!,profile_pic: String!, v_id: String!, username: String!,type: String!,fb_id: String!,Vvalue: String!, thum: String!) {
        
        self.effected_fb_id = effected_fb_id
        self.first_name = first_name
        self.last_name = last_name
        self.profile_pic = profile_pic
        self.v_id = v_id
        self.username = username
        self.type = type
        self.fb_id = fb_id
        self.Vvalue = Vvalue
        self.thum = thum
        
    }
}

class BlockList: NSObject {

       var first_name:String! = ""
       var last_name:String! = ""
       var profile_pic:String! = ""
       var fb_id:String! = ""
    
       
       init(first_name: String!, last_name: String!,profile_pic: String!,fb_id: String!) {
           
          
           self.first_name = first_name
           self.last_name = last_name
           self.profile_pic = profile_pic
           self.fb_id = fb_id
           
          
           
       }
}


struct BannerImagesList {
    
    var banner_img:String! = ""
    var banner_url:String! = ""
    var banner_id:String! = "0"
    var type:String! = ""
    var comment:String! = ""
    
    init(banner_img: String!, banner_url: String!,banner_id: String!, type: String!,comment: String!) {
        
        
        self.banner_img = banner_img
        self.banner_url = banner_url
        self.banner_id = banner_id
        self.type = type
        self.comment = comment
        
    }
}
