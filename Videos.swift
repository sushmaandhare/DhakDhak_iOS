//
//  Videos.swift
//  TIK TIK
//
//  Created by Rao Mudassar on 14/05/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.
//

import UIKit

struct Videos {
    
    var thum:String! = ""
    var first_name:String! = ""
    var last_name:String! = ""
    var profile_pic:String! = ""
    var v_id:String! = "0"
    var view:String! = "0"
    var u_id:String! = ""
    var approve_status:String! = "0"
    var video:String! = ""
    
    init(thum: String!,first_name: String!, last_name: String!, profile_pic: String!, v_id: String!, view: String!,u_id: String!, approve_status: String!, video: String!) {
       
        self.thum = thum
        self.first_name = first_name
        self.last_name = last_name
        self.profile_pic = profile_pic
        self.v_id = v_id
        self.view = view
        self.u_id = u_id
        self.approve_status = approve_status
        self.video = video
    }

}
