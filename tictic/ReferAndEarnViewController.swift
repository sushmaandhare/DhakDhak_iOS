//
//  ReferAndEarnViewController.swift
//  TIK TIK
//
//  Created by Mac on 20/04/21.
//  Copyright © 2021 Rao Mudassar. All rights reserved.
//

import UIKit
import Firebase

class ReferAndEarnViewController: UIViewController {
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onTapInvite(_ sender: UIButton) {
       // createDynamicLink()
    }
    
//    func createDynamicLink(){
//        let userid = UserDefaults.standard.string(forKey: "uid") ?? ""
//        guard let link = URL(string: "https://dhakdhak.world/6SuK?user_id=\(userid)") else { return }
//        print(link)
//        let dynamicLinksDomainURIPrefix = "https://dhakdhak.page.link/"
//        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix:dynamicLinksDomainURIPrefix)
//
//        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.destek.dhakdhak1")
//         linkBuilder?.iOSParameters?.appStoreID = "1523972304"
//
//        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.destek.dhakdhak")
//
//        guard let longDynamicLink = linkBuilder?.url else { return }
//        print("The long URL is: \(longDynamicLink)")
//
//        linkBuilder?.shorten { url, warnings, error in
//          if let error = error {
//            print("Oh no! Got an error! \(error)")
//            return
//          }
//          if let warnings = warnings {
//            for warning in warnings {
//              print("Warning: \(warning)")
//            }
//          }
//          guard let url = url else { return }
//          print("I have a short url to share! \(url.absoluteString)")
//
//            let txt = """
//            Refer & Earn
//
//            Money is just a Dhakdhak app download away!Refer Dhakdhak App and make your friends and followers download DhakDhak App to win amazing cash rewards!
//
//            Download DhakDhak to create entertaining short video and win cash rewards. Let your creativity shower some real money!
//            """
//            let objectsToShare = [txt, url] as [Any] //comment!, imageData!, myWebsite!]
//
//            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//
//            //New Excluded Activities Code
//            if #available(iOS 9.0, *) {
//
//                activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print]
//            } else {
//                // Fallback on earlier versions
//                activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print ]
//            }
//
//            self.present(activityVC, animated: true, completion: nil)
//        }
//
//
//
//
//    }
    
    
}
