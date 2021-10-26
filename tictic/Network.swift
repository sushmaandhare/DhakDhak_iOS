//
//  Network.swift
//  TIK TIK
//
//  Created by Apple on 07/08/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import Foundation

public class Reachability {

class func isConnectedToNetwork()->Bool{

    var Status:Bool = false
    let url = NSURL(string: "http://google.com/")
    let request = NSMutableURLRequest(url: url! as URL)
    request.httpMethod = "HEAD"
    request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
    request.timeoutInterval = 10.0

    var response: URLResponse?

    if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
            Status = true
        }
    }

    return Status
  }
}
