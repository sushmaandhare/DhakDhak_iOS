//
//  Sound.swift
//  TIK TIK
//
//  Created by Rao Mudassar on 02/05/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.
//

import UIKit

struct Itemlist {
    
    var audio_path:String! = ""
    var thum:String! = ""
    var sound_name:String! = ""
    var description:String! = ""
    var uid:String! = ""
    var fav:String! = ""
   
}
class Sound: NSObject {
    
 
    var name:String! = ""
   
    var listOfProducts = [Itemlist]()
    
    
}


struct SearchSound {
    
      var audio_path:String! = ""
    var mpthree:String! = ""
     var thum:String! = ""
     var sound_name:String! = ""
     var description:String! = ""
     var created:String! = ""
     var fav:String! = ""
     var id:String! = ""
     var section:String! = ""
 
   
}
