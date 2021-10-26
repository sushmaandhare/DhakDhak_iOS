//  HomeViewController.swift
//  TIK TIK
//  Created by Rao Mudassar on 24/04/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.

import UIKit
import Alamofire
import VersaPlayer
import AVKit
import DSGradientProgressView
import SDWebImage
import MarqueeLabel
import Photos
import CoreLocation
import FirebaseMessaging
import ActiveLabel
import TinyConstraints
import KILabel
import SwiftResponsiveLabel
import DTGradientButton
import MediaWatermark
import GoogleMobileAds

var discoverFlag = false

extension String
{
    var parseJSONString: AnyObject?
    {
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)

        if let jsonData = data
        {
            // Will return an object or nil if JSON decoding fails
            do
            {
                let message = try JSONSerialization.jsonObject(with: jsonData, options:.mutableContainers)
                if let jsonResult = message as? NSMutableArray
                {
                   // print(jsonResult)

                    return jsonResult //Will return the json array output
                }
                else
                {
                    return nil
                }
            }
            catch let error as NSError
            {
                print("An error occurred: \(error)")
                return nil
            }
        }
        else
        {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}

class HomeViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSourcePrefetching,UIGestureRecognizerDelegate,UITextViewDelegate, GADNativeCustomTemplateAdLoaderDelegate {
    func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [String] {
        return [""]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeCustomTemplateAd: GADNativeCustomTemplateAd) {
        
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
    }
    
    
    var adLoader: GADAdLoader!
    
    @IBOutlet weak var btnExplore: UIButton!
    @IBOutlet weak var empty_view: UIView!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var texe_view: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var out_view: UIView!
    @IBOutlet weak var btn_following: UIButton!
    @IBOutlet weak var btn_foryou: UIButton!
    @IBOutlet weak var txt_comment: UITextField!
    @IBOutlet weak var gradientView: UIView!
    

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var observer:Any?
   // var labelTaps:[UITapGestureRecognizer] = [UITapGestureRecognizer]()

    var offset : Int? = 0
    var index:Int! = 0
    var video_id:String! = "0"
    var video_type:String! = "related"
    var avplayer:AVPlayer?
    var friends_array:NSMutableArray = []
    var comments_array:NSMutableArray = []
    var sound_array:NSMutableArray = []
    private var indexOfCellBeforeDragging = 0
    
    var locationManager = CLLocationManager()
    var currentLoc: CLLocation!
    var totalNotificationCount = 0
    var commentIndex:Int! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.sendFCMId()
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 5

        adLoader = GADAdLoader(adUnitID: "ca-app-pub-3940256099942544/3986624511", rootViewController: self,
                               adTypes: [.nativeCustomTemplate],
            options: [multipleAdsOptions])
        adLoader.delegate = self
        adLoader.load(GADRequest())
        
        Messaging.messaging().subscribe(toTopic: "promotion") { error in
          print("Subscribed to promotion topic")
        }
        self.addTodayLogin()
        locationManager.requestWhenInUseAuthorization()
        
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways) {
            currentLoc = locationManager.location
//            print(currentLoc.coordinate.latitude)
//            print(currentLoc.coordinate.longitude)
            UserDefaults.standard.set("\(currentLoc.coordinate.latitude)", forKey: "Latitude")
            UserDefaults.standard.set("\(currentLoc.coordinate.longitude)", forKey: "Longitude")
        }
        PHPhotoLibrary.requestAuthorization { (status) in
            // No crash
        }
        hideKeyboardWhenTappedAround()
        // self.view.setGradientBackground(colorOne: .darkGray, colorTwo: .lightGray)
        self.collectionview.isPagingEnabled = true
        
        UserDefaults.standard.set("0", forKey: "sid")
        
        if(UserDefaults.standard.string(forKey: "uid") == nil){
            
            UserDefaults.standard.set("", forKey: "uid")
        }
        
        let layout = UICollectionViewFlowLayout()
        // let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionview.showsVerticalScrollIndicator = false
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
        self.collectionview.contentInset = UIEdgeInsets(top:-20, left: 0, bottom:0, right: 0)
        
        self.collectionview.collectionViewLayout = layout
        
        self.tableview.tableFooterView = UIView()
        let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
        self.btnExplore.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
        
        self.btn_following.titleLabel?.font =  UIFont(name: "Poppins-MediumItalic", size: 16.0)
        self.btn_foryou.titleLabel?.font =  UIFont(name: "Poppins-SemiBoldItalic", size: 16.0)
        self.btn_following.setTitleColor(UIColor.gray, for: .normal)
        self.btn_foryou.setTitleColor(UIColor.white, for: .normal)
        self.video_type = "related"
        self.showAllVideos(offset: self.offset)
        
        let bottomRefreshController = UIRefreshControl()
        bottomRefreshController.triggerVerticalOffset = 50
        bottomRefreshController.addTarget(self, action: #selector(self.refreshBottom), for: .valueChanged)
        collectionview.bottomRefreshControl = bottomRefreshController
        collectionview.isPagingEnabled =  true
    }

    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeAd: GADNativeAd) {
      // A native ad has loaded, and can be displayed.
    }

    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        // The adLoader has finished loading ads, and a new request can be sent.
    }

    
    @objc func refreshBottom() {
        print("refresh")
     if totalNotificationCount == friends_array.count{
         self.collectionview.bottomRefreshControl?.endRefreshing()

     }else{
             updateNextSet()
     }
    }
    
        @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }

        @objc func keyboardWillHide(notification: NSNotification) {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    
    @objc func videoDidEnd(notification: NSNotification) {
   
        let visiblePaths = self.collectionview.indexPathsForVisibleItems
        
        for i in visiblePaths  {
            let cell = collectionview.cellForItem(at: i) as? homecollCell
            cell!.player!.seek(to: CMTime.zero)
            cell!.player?.play()
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
      return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        flag = false
        UIApplication.shared.isStatusBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.videoDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        UserDefaults.standard.set("", forKey: "audioUrl")
        UserDefaults.standard.set("", forKey: "soundId")
        UserDefaults.standard.set("", forKey: "sound_name")
        UserDefaults.standard.set(false, forKey: "Upload")
        UserDefaults.standard.set(false, forKey: "DraftSave")
        //dounloadandshare()
    }
    
    func dounloadandshare(videourl:String){
        let urlData = NSData(contentsOf: NSURL(string:videourl)! as URL)
//        let urlData = NSData(contentsOf: NSURL(string:"https://dhakdhak.world/API//tmp/11994180231618821558.mp4")! as URL)
                   if ((urlData) != nil){

                     //  print(urlData)


                    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                       let docDirectory = paths[0]
                       let filePath = "\(docDirectory)/DhakDhak.mov"
                   // print(filePath)
                    urlData?.write(toFile: filePath, atomically: true)
                       // file saved

                       let videoLink = NSURL(fileURLWithPath: filePath)


                       let objectsToShare = [videoLink] //comment!, imageData!, myWebsite!]
                       let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                       let sv = HomeViewController.displaySpinner(onView: self.view)

                       activityVC.setValue("Video", forKey: "subject")

                        HomeViewController.removeSpinner(spinner: sv)
                       //New Excluded Activities Code
                       if #available(iOS 9.0, *) {
                        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print]
                       } else {
                           // Fallback on earlier versions
                        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print ]
                       }


                    self.present(activityVC, animated: true, completion: nil)
                   }
    }
 
    
    override func viewWillDisappear(_ animated: Bool) {
        
        UIApplication.shared.isStatusBarHidden = false
        
        let visiblePaths = self.collectionview.indexPathsForVisibleItems
        for i in visiblePaths  {
            let cell = collectionview.cellForItem(at: i) as? homecollCell
            cell!.player!.pause()
            
            cell!.playBtn.setImage(UIImage(named:"ic_play_icon"), for: .normal)
            cell!.playBtn.isHidden = false
            
            
            
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avplayer?.currentItem)

    }
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.texe_view.frame.origin.y == 0 {
//                self.texe_view.frame.origin.y -= keyboardSize.height
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if self.texe_view.frame.origin.y != 0 {
//            self.texe_view.frame.origin.y = 0
//        }
//    }
    func sendFCMId(){
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.updateFCMId!
        
        let parameter :[String:Any]? = ["fcm_id":"12344567798"]
    print(parameter)
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:[]).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                let json  = value
           
                print(json)
            
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func addTodayLogin(){
        var deviceID = ""
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            deviceID = uuid
        }
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.addTodayLogin!
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid") ?? "","device_id":deviceID, "middle_name": self.appDelegate.middle_name]
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
        ]
  
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                let json  = value
           
              //  print(json)
            
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func getPointsOfferDetails(){
       
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.getPointsOfferDetails!
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid") ?? "", "middle_name": self.appDelegate.middle_name]
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
        ]
  
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                let json  = value
           
               // print(json)
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc: ReferAndEarnViewController = storyboard.instantiateViewController(withIdentifier: "ReferAndEarnViewController") as! ReferAndEarnViewController
                self.navigationController?.pushViewController(vc, animated: true)
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    @IBAction func onTapPoints(_ sender: UIButton) {
        self.getPointsOfferDetails()
    }
    //MARK: Show All Videos Api
    
    func showAllVideos(offset: Int?){
        
        if(UserDefaults.standard.string(forKey:"DeviceToken" ) == nil){
            UserDefaults.standard.set("NULL", forKey:"DeviceToken")
        }
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.showAllVideosNew!
        let sv = HomeViewController.displaySpinner(onView: self.view)
        
    //    let parameter :[String:Any]? = ["fb_id":"117825544243100354284","token":UserDefaults.standard.string(forKey:"DeviceToken")!,"type":self.video_type!, "middle_name": self.appDelegate.middle_name, "latitude" : UserDefaults.standard.value(forKey: "Latitude") ?? "", "longitude" : UserDefaults.standard.value(forKey: "Longitude") ?? "", "offset": String(offset ?? 0)]
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid") ?? "","type":self.video_type!, "offset": offset ?? 0]
       // let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid") ?? "", "fcm_id": UserDefaults.standard.string(forKey:"DeviceToken")!,"type":self.video_type!, "offset": offset ?? 0]
        
        print(parameter)
        print(url)
  //      let parameter :[String:Any]? = ["fb_id": UserDefaults.standard.string(forKey: "uid") ?? "","type":self.video_type!, "middle_name": self.appDelegate.middle_name, "offset": String(offset ?? 0 )]
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
        ]
  
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:[]).validate().responseJSON(completionHandler: {
            
            respones in
            print(respones)
            switch respones.result {
            case .success( let value):
                HomeViewController.removeSpinner(spinner: sv)
                self.collectionview.bottomRefreshControl?.endRefreshing()
                let json  = value
           
                print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    if let count = dic["total_video_count"] as? String{
                        self.totalNotificationCount = Int(count) ?? 0
                        print(self.totalNotificationCount)
                    }
                    
                    let myCountry = (dic["msg"] as? [[String:Any]])!
   //                 print("video count",myCountry.count)
                    for Dict in myCountry {
                    
                        let myRestaurant = Dict as NSDictionary
                        
                        let count = myRestaurant["count"] as! NSDictionary
                        let Username = myRestaurant["user_info"] as! NSDictionary
                        let sound = myRestaurant["sound"] as! NSDictionary
                        let sound_id = sound["id"] as? String
                        let audio_patha = sound["audio_path"] as! NSDictionary
                        let audio_path:String! =   audio_patha["acc"] as? String
                        let obj1 = SoundObj(sound_id: sound_id, audioUrl: audio_path)
                        self.sound_array.add(obj1)
                        
                        let shareCount = count["share"] as? String
                        let like_count = count["like_count"] as? String
                        
                        let video_comment_count = count["video_comment_count"] as? String
                        let view_count = count["view"] as? String
                        
                        let sound_name = sound["sound_name"] as? String
                        let video_url:String! =   myRestaurant["video"] as? String
//                        let video_url = "https://www.radiantmediaplayer.com/media/big-buck-bunny-360p.mp4"
                        
                        let u_id:String! =   myRestaurant["fb_id"] as? String
                        let v_id:String! =   myRestaurant["id"] as? String
                        let thum:String! =   myRestaurant["thum"] as? String
                        let first_name:String! =   Username["username"] as? String
                        let last_name:String! =   Username["last_name"] as? String
                        let profile_pic:String! =   Username["profile_pic"] as? String
                        let like:String! =   myRestaurant["liked"] as? String
                        let isFollow:Int! = Dict["is_follow"] as! Int
                        let desc:String! =   myRestaurant["description"] as? String
                        let f_name:String! =   Username["first_name"] as? String
                        let verification : Int! =   Username["verified"] as? Int
                        let allow_comment:String! =   myRestaurant["allow_comments"] as? String
                        let allow_duet:String! =   myRestaurant["allow_duet"] as? String
                    //    print("is follow",isFollow)
                        let obj = Home(like_count: like_count, video_comment_count: video_comment_count, sound_name: sound_name,thum: thum, first_name: first_name, last_name: last_name,profile_pic: profile_pic, video_url: video_url, v_id: v_id, u_id: u_id, like: like, desc: desc, f_name: f_name, view_count: view_count, verified: verification, allow_comment: allow_comment, allow_duet: allow_duet, isFollow: isFollow, share_count: shareCount)
                     
                        
                        self.friends_array.add(obj)
                        
                        
                    }
                    
                    DispatchQueue.main.async {
                        if self.friends_array.count == 0{
                            if(UserDefaults.standard.string(forKey: "uid") == ""){
                                
                                self.alertModule(title:"", msg: "Please login from profile to comment on video!")
                                
                            }else{
                                self.empty_view.isHidden = false
                                self.collectionview.isHidden = true
                            }
                        }else{
                            self.empty_view.isHidden = true
                            self.collectionview.isHidden = false
                            self.collectionview.delegate = self
                            self.collectionview.dataSource = self
                            self.collectionview.prefetchDataSource = self
                            self.collectionview.reloadData()
                        }
                        
                    }
                    
                    
                }else{
                    
                   
                    
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                HomeViewController.removeSpinner(spinner: sv)
                if Reachability.isConnectedToNetwork() == false{
                    self.alertModule(title:"Network Issue",msg: "No Internet Connection")
                }else{
                  //  self.alertModule(title:"Error",msg:error.localizedDescription)
                }
            }
        })
        
    }
    
    // Collection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.friends_array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:homecollCell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "homecollCell", for: indexPath) as! homecollCell
        //cell.player?.pause()
//        cell.btn_foryou.titleLabel?.font =  UIFont(name: "Poppins-MediumItalic", size: 16.0)
//        cell.btn_following.titleLabel?.font =  UIFont(name: "Poppins-SemiboldItalic", size: 16.0)
        let obj = self.friends_array[indexPath.row] as! Home
        
        let url = URL.init(string: obj.video_url)
        
        let screenSize: CGRect = UIScreen.main.bounds
        //cell.playerItem = AVPlayerItem(url: url!)
        
        if obj.allow_comment == "false"{
            out_view.isHidden = true
            cell.commentView.isHidden = true
        }
        
//        cell.btnRequestVerification.layer.cornerRadius = cell.btnRequestVerification.layer.frame.height / 2
//        cell.btnRequestVerification.clipsToBounds = true
        cell.cdProfileImg.layer.cornerRadius = cell.cdProfileImg.layer.frame.height / 2
        cell.cdProfileImg.clipsToBounds = true
        cell.btnCD.tag = indexPath.item
        cell.btnCD.addTarget(self, action: #selector(HomeViewController.onTapCD(_:)), for:.touchUpInside)
        
        let player = AVPlayer(url: url!)
        
        cell.player = AVPlayer(url: url!)   //AVPlayer(playerItem: cell.playerItem!)
        cell.player?.automaticallyWaitsToMinimizeStalling = false
        
        cell.playerLayer = AVPlayerLayer(player: cell.player!)
        cell.playerLayer!.frame = CGRect(x:0,y:0,width:screenSize.width,height: screenSize.height)
        cell.playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cell.playerView.layer.addSublayer(cell.playerLayer!)
        
        cell.playerView.layer.backgroundColor = UIColor.black.cgColor
        cell.playBtn.tag = indexPath.item
        cell.playBtn.setImage( UIImage(named: "ic_pause_icon"), for: .normal)
        cell.btnshare.tag = indexPath.item
     //   cell.playBtn.addTarget(self, action: #selector(HomeViewController.connected(_:)), for:.touchUpInside)
        
        cell.btn_like.tag = indexPath.item
        cell.btn_like.addTarget(self, action: #selector(HomeViewController.connected2(_:)), for:.touchUpInside)
        
        cell.btn_comments.tag = indexPath.item
        cell.btn_comments.addTarget(self, action: #selector(HomeViewController.connected3(_:)), for:.touchUpInside)
        
        cell.btnshare.addTarget(self, action: #selector(HomeViewController.connected1(_:)), for:.touchUpInside)
        
        cell.btnView.tag = indexPath.item
        cell.btnView.addTarget(self, action: #selector(HomeViewController.onTapViewCount(_:)), for:.touchUpInside)
        
        cell.other_profile.tag = indexPath.item
        cell.other_profile.addTarget(self, action: #selector(HomeViewController.connected4(_:)), for:.touchUpInside)
        
        //  cell.lbldesi.text = obj.desc
        if obj.v_id == "25066"{
            var hashArr : [String] = obj.desc.findMentionText()
            print(hashArr)
            var str = hashArr.joined(separator: " ")
            cell.txtDesc.text = str
        }else{
            cell.txtDesc.text = obj.desc
        }
        
        
        cell.user_name.tag = indexPath.item
        cell.btnUserName.addTarget(self, action: #selector(HomeViewController.connected4(_:)), for:.touchUpInside)
        cell.btnUserName.tag = indexPath.item
        
        // Make sure to add
        //  cell.lbldesi.isUserInteractionEnabled = true
        //  cell.txtDesc.text = "This is an #example test"
        cell.txtDesc.resolveHashTags()
        cell.txtDesc.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        cell.inner_view.addGestureRecognizer(tap)
        
        cell.inner_view.isUserInteractionEnabled = true
        cell.inner_view.tag = indexPath.item
        
        
        if(obj.first_name != nil || obj.last_name != nil){
            
            cell.user_name.text = obj.first_name
        }
        cell.user_name.textDropShadow()
        if(obj.profile_pic != nil){
            cell.user_img.sd_setImage(with: URL(string:obj.profile_pic), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
            cell.cdProfileImg.sd_setImage(with: URL(string:obj.profile_pic), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
        }
        //cell.user_img.layer.masksToBounds = false
        cell.user_img.layer.cornerRadius = cell.user_img.frame.height/2
        cell.user_img.clipsToBounds = true
        cell.user_img.layer.borderColor = UIColor.white.cgColor
        cell.user_img.layer.borderWidth = 1.0
        // cell.other_profile.layer.masksToBounds = false
        //cell.other_profile.layer.cornerRadius = cell.user_img.frame.height/2
        // cell.other_profile.clipsToBounds = true
        
        if(obj.sound_name != nil){
        
            let longString = obj.sound_name
            let longestWord = "Orignal Sound -"

            let longestWordRange = (longString as! NSString).range(of: longestWord)

            let attributedString = NSMutableAttributedString(string: longString!, attributes: [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 12.0)!])

            attributedString.setAttributes([NSAttributedString.Key.font : UIFont(name: "Poppins-Bold", size: 12.0)!, NSAttributedString.Key.foregroundColor : UIColor.white], range: longestWordRange)

            cell.music_name.attributedText = attributedString
    
        }
        cell.lblLikeCount.text = String(obj.like_count)
        cell.lblCommentCount.text = obj.video_comment_count
        cell.lblViewCount.text = obj.view_count
        cell.lblShareCount.text = obj.share_count
        // cell.img.sd_setImage(with: URL(string:self.appDelegate.imgbaseUrl!+obj.thum), placeholderImage: UIImage(named: ""))
        
        if(obj.like == "0"){
            
            cell.btn_like.setBackgroundImage(UIImage(named:"ic_like"), for: .normal)
        }else{
            cell.btn_like.setBackgroundImage(UIImage(named:"ic_like_fill"), for: .normal)
        }
        
     //   print("is follow",obj.isFollow)
        if (obj.isFollow == 1){
          //  print("is follow",obj.isFollow)
            cell.btnVerification.isHidden = true
        }else{
         //   print("is follow",obj.isFollow)
            cell.btnVerification.isHidden = false
        }
        
//        if (obj.verified == 1){
//            print("is follow",obj.isFollow)
//            cell.btnRequestVerification.isHidden = true
//        }else{
//            print("is follow",obj.isFollow)
//            cell.btnRequestVerification.isHidden = false
//        }
        
        cell.btnVerification.tag = indexPath.item
        cell.btnVerification.addTarget(self, action: #selector(HomeViewController.onTapVerification(_:)), for:.touchUpInside)
       
//        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
//
//        longPressedGesture.delegate = self
//        cell.addGestureRecognizer(longPressedGesture)
        
//        cell.animationView.center.y -= (cell.animationView.bounds.height)
//        cell.userView.center.y -= (cell.animationView.bounds.height)
//        cell.stackView.center.x -= (cell.stackView.bounds.width)
       
//        cell.animationView.isHidden = false
//        cell.stackView.isHidden = false
        return cell
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        print("hastag Selected!")
        return true
    }
    
    //MARK: Handle label tap
//     @objc func handleLabelTap(_ sender: UITapGestureRecognizer) {
//
//        if let index = labelTaps.index(of: sender) {
//
//            let tappedLabel:UILabel = labels[index]
//
//            // Now you can do whatever you want
//            print("User tapped label with hash-tag: \(tappedLabel.text)")
//
//        }
//
//    }


    //MARK: Save video api
    
    func saveVideo(id : String){
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.downloadFile!
        let sv = HomeViewController.displaySpinner(onView: self.view)
        let parameter :[String:Any]? = ["video_id":id,"middle_name": self.appDelegate.middle_name]
    //    print(url)
     //   print(parameter!)
        let headers: HTTPHeaders = [
         "api-key":"4444-3333-2222-1111"
        ]
        AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
          respones in
          switch respones.result {
          case .success( let value):
            let json = value
            // self.Follow_Array = []
        //  print(json)
            let dic = json as! NSDictionary
            let code = dic["code"] as! NSString
            if(code == "200"){
                if let myCountry = dic["msg"] as? [[String:Any]]{
                  for Dict in myCountry {
                    if let my_id =  Dict["download_url"] as? String{
                      let url = URL.init(string: my_id)
                      let date = Date()
                      let formatter = DateFormatter()
                      formatter.dateFormat = "dd.MM.yyyy"
                      let result = formatter.string(from: date)
                      DispatchQueue.global(qos: .background).async {
                        if let url = URL(string: my_id), let urlData = NSData(contentsOf: url) {
                          let galleryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                          let filePath = "\(galleryPath)/dhakdhak.mp4"
                          DispatchQueue.main.async {
                            urlData.write(toFile: filePath, atomically: true)
                            PHPhotoLibrary.shared().performChanges({
                              PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:
                                URL(fileURLWithPath: filePath))
                            }) {
                              success, error in
                              if success {
                                DiscoverCategoriesVC.removeSpinner(spinner: sv)
                               // print("Succesfully Saved")
                              } else {
                                DiscoverCategoriesVC.removeSpinner(spinner: sv)
                                self.alertModule(title:"Error", msg: error!.localizedDescription)
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }else{
              self.alertModule(title:"Error", msg:dic["msg"] as! String)
            }
          case .failure(let error):
           // print(error)
            HomeViewController.removeSpinner(spinner: sv)
            self.alertModule(title:"Error",msg:error.localizedDescription)
          }
        })
      }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        let p = gesture.location(in: self.collectionview)
        if let indexPath : NSIndexPath = self.collectionview.indexPathForItem(at:p) as NSIndexPath?{
          //do whatever you need to do
          if (gesture.state == .began) {
            let actionSheet = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title:"Save Video", style: .default, handler: {
                (_:UIAlertAction)in
                let obj = self.friends_array[indexPath.row] as! Home
                self.saveVideo(id: obj.v_id)
            })
            let deleteVideo = UIAlertAction(title:"Delete Video", style: .default) { (UIAlertAction) in
            //  print("Delete Video")
              let obj = self.friends_array[indexPath.row] as! Home
              self.deleteVideo(videoId: obj.v_id!)
            }
            let duetVideo = UIAlertAction(title:"Duet Video", style: .default) { (UIAlertAction) in
                //  print("Delete Video")
                let obj = self.friends_array[indexPath.row] as! Home
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc: DuetVC = storyboard.instantiateViewController(withIdentifier: "DuetVC") as! DuetVC
                vc.duetVideoUrl = obj.video_url
                self.navigationController?.pushViewController(vc, animated: true)
            }
            let cancel = UIAlertAction(title:"Cancel", style: .cancel, handler: {
              (_:UIAlertAction)in
            })
            let obj = self.friends_array[indexPath.row] as! Home
           // actionSheet.addAction(camera)
            if UserDefaults.standard.string(forKey: "uid")! == obj.u_id{
            actionSheet.addAction(deleteVideo)
            }
           // actionSheet.addAction(duetVideo)
          //  actionSheet.addAction(cancel)
            self.present(actionSheet, animated: true, completion: nil)
          }
        }
    }
    
  //MARK:Delete Video
  func deleteVideo(videoId:String){
    let url : String = self.appDelegate.baseUrl! + self.appDelegate.videoDelete!
    let parameter :[String:Any]? = ["id":videoId,"middle_name":self.appDelegate.middle_name]
      let headers: HTTPHeaders = [
        "api-key": "4444-3333-2222-1111"
      ]
      //print(url)
     // print(parameter!)
      AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
        respones in
       // print("response delete ",respones)
        switch respones.result {
        case .success( let value):
          let json = value
          self.friends_array = []
          self.sound_array = []
          //print(json)
          let dic = json as! NSDictionary
          let code = dic["code"] as! NSString
          if(code == "200"){
            let myCountry = (dic["msg"] as? [[String:Any]])!
           // print(myCountry)
          let alert = UIAlertController(title: "", message: "Video Deleted sucessfully", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
            self.showAllVideos(offset: self.offset)
          }))
          self.present(alert, animated: true, completion: nil)
          }else{
          }
        case .failure(let error):
          if Reachability.isConnectedToNetwork() == false{
            self.alertModule(title:"Network Issue",msg: "No Internet Connection")
          }else{
           // self.alertModule(title:"Error",msg:error.localizedDescription)
          }
        }
      })
    }
    
    //MARK:- Update Video Count
    func updateVideoCount(videoId:String){
        let url : String = self.appDelegate.baseUrl! + self.appDelegate.updateVideoView!
        
        let parameter :[String:Any]? = ["id":videoId,"middle_name":self.appDelegate.middle_name, "fb_id": UserDefaults.standard.string(forKey: "uid")!]
          let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
          ]
          //print(url)
         // print(parameter!)
          AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            respones in
        //    print("response ",respones)
            switch respones.result {
            case .success( let value):
              let json = value
           //   print(json)
              let dic = json as! NSDictionary
              let code = dic["code"] as! NSString
              if(code == "200"){
                let myCountry = (dic["msg"] as? [[String:Any]])!
               // print(myCountry)
            
                
              }else{
              }
            case .failure(let error):
              if Reachability.isConnectedToNetwork() == false{
                self.alertModule(title:"Network Issue",msg: "No Internet Connection")
              }else{
               // self.alertModule(title:"Error",msg:error.localizedDescription)
              }
            }
          })
        }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let obj = friends_array[indexPath.item] as! Home
        if let cell = cell as? homecollCell {
            index = indexPath.row
            cell.playBtn.isHidden = true
            cell.player?.rate = 1.0
            cell.img.image = UIImage(named: obj.thum)
            cell.player?.play()
            cell.player!.addObserver(self, forKeyPath:"timeControlStatus", options: [.old, .new], context: nil)
            updateVideoData(ind: indexPath.item)
            
            //        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //            UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveLinear],
            //                           animations: {
            //                            cell.animationView.center.y += (cell.animationView.bounds.height)
            //                            cell.userView.center.y += (cell.animationView.bounds.height)
            //                            cell.stackView.center.x += (cell.stackView.bounds.width)
            //                            cell.animationView.layoutIfNeeded()
            //
            //                           },  completion: {(_ completed: Bool) -> Void in
            //                            cell.animationView.isHidden = true
            //                            cell.stackView.isHidden =  true
            //                           })
            //        }
        }
        
//        if (friends_array.count != 1) && ((friends_array.count - 1) > indexPath.row){
//           // print("frind count",friends_array.count)
//            if indexPath.row == friends_array.count-1{ //numberofitem count
//        updateNextSet()
//      }
//    }
    }

    
    //MARK: Update next offset
    func updateNextSet(){
        self.offset =  self.offset! + 6
        showAllVideos(offset: self.offset)
           //requests another set of data (20 more items) from the server.
    }


    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let visiblePaths = self.collectionview.indexPathsForVisibleItems
        for i in visiblePaths  {
            let cell = collectionview.cellForItem(at: i) as? homecollCell
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {[weak self] in
                    if newStatus == .playing || oldStatus == .paused  {
                        cell?.progressView.signal()
                        cell?.progressView.isHidden = true
                       // cell?.player?.play()
                    } else {
                        
                         cell?.progressView.wait()
                        cell?.progressView.isHidden = false
                       // cell?.player?.pause()
                        
                    }
                })
            }
        }
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? homecollCell {
            let obj = friends_array[indexPath.item] as! Home
            index = indexPath.row
            cell.player!.pause()
            updateVideoCount(videoId: obj.v_id)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        return CGSize(width: screenSize.width, height: screenSize.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]){
        
        for indexPath in indexPaths {
            /*
             Updating upcoming CollectionView's data source. Not assiging any direct value
             */
            
            let tempObj = self.friends_array[indexPath.row] as! Home
            self.friends_array[indexPath.row] = tempObj
           
        }
    }
    
    // indexPaths that previously were considered as candidates for pre-fetching, but were not actually used; may be a subset of the previous call to -collectionView:prefetchItemsAtIndexPaths:
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]){
      
        
        for indexPath in indexPaths {
            self.friends_array.remove(indexPath.row)
        }
    }
    
    //MARK: Scroll view delegates
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.collectionview.visibleCells.forEach { cell in
            if let indexPath = collectionview.indexPathsForVisibleItems.first {
             //   print("current index pTH",indexPath.item)
               
                  let obj = friends_array[indexPath.item] as! Home
                  if let cell = cell as? homecollCell {
                    index = indexPath.row
                    cell.playBtn.isHidden = true
                    cell.player?.rate = 1.0
                    cell.img.image = UIImage(named: obj.thum)
                    cell.player?.pause()
                    cell.player!.addObserver(self, forKeyPath:"timeControlStatus", options: [.old, .new], context: nil)
        
                  }

        //    print("collection brgin scroll")
            }
            // TODO: write logic to stop the video before it begins scrolling
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.collectionview.visibleCells.forEach { cell in
          //  print("collection did end scroll")
            
            if let indexPath = collectionview.indexPathsForVisibleItems.first {
                
                //   print("current index end  pTH",indexPath.row)
                
                let obj = friends_array[indexPath.item] as! Home
                if let cell = cell as? homecollCell {
                    index = indexPath.row
                    //cell.playBtn.isHidden = true
                   // cell.player?.rate = 1.0
                    cell.img.image = UIImage(named: obj.thum)
                   // cell.player?.play()
                   
                    if(cell.playBtn.currentImage == UIImage(named: "ic_play_icon")){
                        
                        
                        cell.playBtn.setImage( UIImage(named: "ic_pause_icon"), for: .normal)
                        cell.playBtn.isHidden = true
                        cell.player?.rate = 1.0
                        cell.player?.play()
                        cell.player!.addObserver(self, forKeyPath:"timeControlStatus", options: [.old, .new], context: nil)
                        
                        
                    }else if(cell.playBtn.currentImage == UIImage(named: "ic_pause_icon")){
                        
                        
                        cell.playBtn.setImage( UIImage(named: "ic_play_icon"), for: .normal)
                        cell.playBtn.isHidden = false
                        cell.player?.pause()
                        
                    }
                }
                
            }
            // TODO: write logic to start the video after it ends scrolling
        }
    }
    
    //MARK: On tap CD
    @objc func onTapCD(_ sender: UIButton) {
        if(UserDefaults.standard.string(forKey: "uid") == ""){
            
            self.alertModule(title:"", msg: "Please login into the app.")
            
        }else{
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: UseSoundVC = storyboard.instantiateViewController(withIdentifier: "UseSoundVC") as! UseSoundVC
            let obj = self.friends_array[sender.tag] as! Home
            let obj1 = self.sound_array[sender.tag] as! SoundObj
            vc.audioTitle = obj.f_name + "" + obj.last_name
            vc.audioString = obj1.audioUrl
            vc.soundName = obj.sound_name
            vc.soundId = obj1.sound_id ?? "null"
            vc.videoImg = obj.thum
            vc.desc = obj.desc
            vc.videoId = obj.v_id
            //        vc.modalPresentationStyle = .fullScreen
            //        self.present(vc, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func connected1(_ sender : UIButton)
    {
        /* //print(sender.tag)
         
         let text1 = "Don't be a miser when it comes to Talent, Spend your talent like a Millionaire!! Hit the share button and share your post with your social handles!! Download from below:"
         
         let objectsToShare:URL = URL(string: "https://bit.ly/dhakdhak")!
         let sharedObjects:[AnyObject] = [text1 as AnyObject,objectsToShare as AnyObject]
         let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
         //  activityViewController.popoverPresentationController?.sourceView = self.view
         
         //  activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail]
         
         self.present(activityViewController, animated: true, completion: {
         self.shareApi(id: obj.v_id)
         })*/
        if(UserDefaults.standard.string(forKey: "uid") == ""){
            
             self.alertModule(title:"", msg: "Please login into the app.")
            
        }else{
        let buttonTag = sender.tag
         //   self.view.showLoading()
           // let outputURL = NSURL.fileURL(withPath: "TempPath")
            let sv = HomeViewController.displaySpinner(onView: self.view)
            let obj = self.friends_array[buttonTag] as! Home
            //saveVideo(id: obj.v_id, isShare : true)
                if let item = MediaItem(url: URL(string: obj.video_url)!) {
                    let logoImage = UIImage(named: "trademark")
                            
                    let firstElement = MediaElement(image: logoImage!)
                    firstElement.frame = CGRect(x: 10, y: 100, width: logoImage!.size.width, height: logoImage!.size.height)
                            
                    let testStr = obj.first_name!
                    let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25) ]
                    let attrStr = NSAttributedString(string: testStr, attributes: attributes)
                            
                    let secondElement = MediaElement(text: attrStr)
                    secondElement.frame = CGRect(x:10, y: 60, width: 300, height: 30)
                            
                    item.add(elements: [firstElement, secondElement])
                            
                    let mediaProcessor = MediaProcessor()
                    mediaProcessor.processElements(item: item) { [weak self] (result, error) in
    //                    self?.videoPlayer.url = result.processedUrl
    //                    self?.videoPlayer.playFromBeginning()
                        DispatchQueue.main.async {
                            
                        let objectsToShare = [result.processedUrl] //comment!, imageData!, myWebsite!]
                        let activityVC = UIActivityViewController(activityItems: objectsToShare as [Any], applicationActivities: nil)
                       

                        activityVC.setValue("Video", forKey: "subject")
                            ////                                        activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                            ////                                            if !completed {
                            ////                                                // User canceled
                            ////                                                return
                            ////                                            }
                            ////                                            var sharetypestr = ""
                            ////                                            // User completed activity
                            ////                                            switch activityType! {  // See UIActivity.ActivityType
                            ////                                            case .postToTwitter:
                            ////                                                 sharetypestr = "11"
                            ////                                            case .airDrop:
                            ////                                                sharetypestr = "11"
                            ////                                            case .mail:
                            ////                                                sharetypestr = "2"
                            ////                                            case .postToFacebook:
                            ////                                                sharetypestr = "5"
                            ////                                            case .message :
                            ////                                                sharetypestr = "4"
                            ////                                            default:
                            ////                                                sharetypestr = "11"
                            ////                                            }
                            ////                                            print(activityType?.rawValue)
                            ////                                            self.shareApi(id: id, type: sharetypestr)
                            ////
                            ////                                        }
                         HomeViewController.removeSpinner(spinner: sv)
                        //New Excluded Activities Code
                        if #available(iOS 9.0, *) {
                         activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print]
                        } else {
                            // Fallback on earlier versions
                         activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print ]
                        }

                        //    self?.view.stopLoading()
                        self?.present(activityVC, animated: true, completion: nil)
                            
                    }
                }
            }
        }
    }
    
    
    func shareApi(id : String, type : String){
    
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.shareVideo
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid") ?? "", "type": type, "video_id" : id, "middle_name": self.appDelegate.middle_name]
        
     //   print(url)
     //   print(parameter!)
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
            
        ]
        
        AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
         //   print(respones)
            
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
                
                HomeViewController.removeSpinner(spinner: sv)
                
             //   print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    print("Share success")
                }else{
                    
                    self.alertModule(title:"Error", msg:dic["msg"] as? String ?? "error occured")
                    
                }
                
                
                
            case .failure(let error):
                print(error)
                HomeViewController.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
    }

    @objc func connected(_ sender : UIButton) {
       // print(sender.tag)
        
        let buttonTag = sender.tag
        
        let indexPath = IndexPath(row: buttonTag, section: 0)
        let cell = collectionview.cellForItem(at: indexPath) as! homecollCell
        if(cell.playBtn.currentImage == UIImage(named: "ic_pause_icon")){
            cell.playBtn.setImage(UIImage(named:"ic_play_icon"), for: .normal)
           // cell.playBtn.setBackgroundImage(UIImage(named:"ic_pause_icon"), for: .normal)
            cell.player?.play()
            cell.playBtn.isHidden = true
            
        }else if(cell.playBtn.currentImage == UIImage(named: "ic_play_icon")){
            
            
            cell.playBtn.setImage( UIImage(named: "ic_pause_icon"), for: .normal)
            cell.playBtn.isHidden = false
            cell.player?.pause()
        
//            UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveEaseIn],
//                           animations: {
//                            cell.userView.center.y -= (cell.animationView.bounds.height)
//                            cell.animationView.center.y -= (cell.animationView.bounds.height)
//                            cell.stackView.center.x -= (cell.stackView.bounds.width)
//                            cell.animationView.layoutIfNeeded()
//                           }, completion: nil)
//            cell.animationView.isHidden = false
//            cell.stackView.isHidden =  false
    }
        
    }
    
    @objc func connected3(_ sender : UIButton) {
        
        
        //print(sender.tag)
        
        self.out_view.alpha = 1
        
        UIView.animate(withDuration: 0.5, animations: {
            //print(self.out_view.frame.origin.y)
            
            
            
            self.out_view.frame = CGRect(x: 0, y:UIScreen.main.bounds.height-340 , width: self.view.frame.width, height: self.view.frame.height)
            
            
            
        },  completion: { (finished: Bool) in
        
        let buttonTag = sender.tag
            self.commentIndex = buttonTag
        let obj = self.friends_array[buttonTag] as! Home
        self.video_id = obj.v_id
        
            self.getComents()
        })
        
        
    }
    
    //MARK: Connected 4 action
    @objc func connected4(_ sender : UIButton) {
        // print(sender.tag)
        
        let buttonTag = sender.tag
        let obj = self.friends_array[buttonTag] as! Home
        
        
        let actionSheet =  UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        let camera1 = UIAlertAction(title: "View Profile", style: .default, handler: {
            (_:UIAlertAction)in
            
            if(obj.u_id != UserDefaults.standard.string(forKey: "uid")!){
                
                StaticData.obj.other_id = obj.u_id
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let yourVC: Profile1ViewController = storyboard.instantiateViewController(withIdentifier: "Profile1ViewController") as! Profile1ViewController
                yourVC.status = "1"
                // self.present(yourVC, animated: true, completion: nil)
                self.navigationController?.pushViewController(yourVC, animated: true)
                //self.present(yourVC , animated: true, completion: nil)
                
            }else{
                self.tabBarController?.selectedIndex = 3
            }
        })
        
        let camera = UIAlertAction(title: "Report "+obj.first_name, style: .default, handler: {
            (_:UIAlertAction)in
            
            let videoId = obj.v_id
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let yourVC: ReportReasonVC = storyboard.instantiateViewController(withIdentifier: "ReportReasonVC") as! ReportReasonVC
            yourVC.videoId = videoId
            self.navigationController?.pushViewController(yourVC, animated: true)
            //   print("videoId",videoId)
           // self.popUpController(videoiD: videoId ?? "0")
            
        })
        
        let deleteVideo = UIAlertAction(title:"Delete Video", style: .default) { (UIAlertAction) in
            //  print("Delete Video")
            
            self.deleteVideo(videoId: obj.v_id!)
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (_:UIAlertAction)in
            
        })
        
        actionSheet.addAction(camera1)
        actionSheet.addAction(camera)
        if UserDefaults.standard.string(forKey: "uid")! == obj.u_id{
            actionSheet.addAction(deleteVideo)
        }
        
        actionSheet.addAction(cancel)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func onTapVerification(_ sender: UIButton) {
       if(UserDefaults.standard.string(forKey: "uid") == ""){
           
           self.alertModule(title:"", msg: "Please login into the app.")
           
       }else{
        let buttonTag = sender.tag
        let obj = self.friends_array[buttonTag] as! Home
        StaticData.obj.other_id = obj.u_id
        UserDefaults.standard.set(StaticData.obj.other_id, forKey: "fb_Id")
        let indexPath = IndexPath(row: buttonTag, section: 0)
        let cell = collectionview.cellForItem(at: indexPath) as! homecollCell
        
        let sv = HomeViewController.displaySpinner(onView: self.view)
        
        self.view.isUserInteractionEnabled = false
        let url : String = appDelegate.baseUrl!+appDelegate.follow_users!
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey:"uid")!,"followed_fb_id":UserDefaults.standard.string(forKey: "fb_Id")!,"status":"1", "middle_name": self.appDelegate.middle_name]
        
      //  print(url)
      //  print(parameter!)
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
            
        ]
        
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                self.view.isUserInteractionEnabled = true
                HomeViewController.removeSpinner(spinner: sv)
                let json  = value
                
                
                //print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    let myCountry = dic["msg"] as? NSArray
                    if let data = myCountry![0] as? NSDictionary{
                   //     print(data)
                        
                        cell.btnVerification.isHidden = true
                        self.alertModule(title: "", msg: "User has been followed successfully.")
                    }
                    
                }else{
                    
                    self.alertModule(title: "Error", msg: dic["msg"] as? String ?? "error occured.")
                    
                }
                
                
                
            case .failure(let error):
                
                self.view.isUserInteractionEnabled = true
                HomeViewController.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
        
        }
        
    }
    
    //MARK: POPUpcontroller
    func popUpController(videoiD:String)
        {
            let alertController = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertController.Style.alert)

            let margin:CGFloat = 8.0
            let rect = CGRect(x: margin, y: margin, width: alertController.view.bounds.size.width - margin * 4.0, height: 100.0)
            let customView = UITextView(frame: rect)
        customView.delegate = self
            customView.text = "Write your report here"
            customView.textColor = UIColor.lightGray
            customView.delegate = self
            customView.backgroundColor = UIColor.clear
            customView.textColor = UIColor.white
            customView.font = UIFont(name: "Helvetica", size: 15)
            //  customView.backgroundColor = UIColor.greenColor()
            alertController.view.addSubview(customView)

            let somethingAction = UIAlertAction(title: "Report", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in
                
              //  print("something")
             //   print(customView.text)
                self.reportUser_API(reportText: customView.text, videoId: videoiD)
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {(alert: UIAlertAction!) in print("cancel")})

            alertController.addAction(somethingAction)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion:{})
        }
    
    
    //MARK:  get Like videos api
    func reportUser_API(reportText:String,videoId:String){
           
           let id = UserDefaults.standard.string(forKey: "fb_Id")
         //  print("id",id)
           
           let url : String = self.appDelegate.baseUrl!+self.appDelegate.reportUser
           
           let  sv = HomeViewController.displaySpinner(onView: self.view)
           let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "fb_Id") ?? "","video_id": videoId,"comment":reportText]

        //   print(url)
        //   print(parameter!)
           
           let headers: HTTPHeaders = [
               "api-key": "4444-3333-2222-1111"
           ]
           
           AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
               
               respones in
          //     print(respones)
               
               switch respones.result {
               case .success( let value):
                
                   
                   let json  = value
                   HomeViewController.removeSpinner(spinner: sv)
                   //print(json)
                   
                   let dic = json as! NSDictionary
                   let code = dic["code"] as! NSString
                   
                   if(code == "200"){
                     
                    //  print("Report User Done")
                      let msg = dic["msg"] as! String
                      self.alertModule(title: "", msg: "\(msg)")
                       
                   }else{
                       
                       self.alertModule(title:"Error", msg:dic["msg"] as? String ?? "error occured")
                   }
               case .failure(let error):
               //    print(error)
                   HomeViewController.removeSpinner(spinner: sv)
                   self.alertModule(title:"Error",msg:error.localizedDescription)
               }
           })
       }
    
    
    //MARK: Texi view delegates method
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write your report here"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
          textView.resignFirstResponder()
          return false
        }
        return true
      }
    
    func showHashTagAlert(tagType:String, payload:String){
        let alertView = UIAlertView()
        alertView.title = "\(tagType) tag detected"
        // get a handle on the payload
        alertView.message = "\(payload)"
        alertView.addButton(withTitle: "Ok")
        //alertView.show()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: HashtagsVC = storyboard.instantiateViewController(withIdentifier: "HashtagsVC1") as! HashtagsVC
        vc.selectedHashtag = payload
        var b = UserDefaults.standard.string(forKey: "uid")!
      //  print(b)
        vc.fbid = b
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Hasgtag detected method
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        // check for our fake URL scheme hash:helloWorld
        switch URL.scheme {
        case "hash" :
            print("hashtagDetectd")
            var hashtag = (URL as NSURL).resourceSpecifier?.removingPercentEncoding!
            if #available(iOS 13.0, *) {
                
            } else {
                // Fallback on earlier versions
            }
            
//            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc: HashtagsVC = storyboard.instantiateViewController(withIdentifier: "HashtagsVC") as! HashtagsVC
//            vc.selectedHashtag = hashtag ?? " "
//            self.navigationController?.pushViewController(vc, animated: true)
            showHashTagAlert(tagType: "hash", payload: ((URL as NSURL).resourceSpecifier?.removingPercentEncoding!)!)
        case "mention" :
            showHashTagAlert(tagType: "mention", payload: ((URL as NSURL).resourceSpecifier?.removingPercentEncoding!)!)
        default:
            print("just a regular url")
        }
        
        return true
    }
     
    @objc func connected2(_ sender : UIButton) {
        //print(sender.tag)
        
        var action:String! = ""
        
        
        if(UserDefaults.standard.string(forKey: "uid") == ""){
                  
            self.alertModule(title:"", msg: "Please login into the app.")
                  
    }else{
        let buttonTag = sender.tag
        let indexPath = IndexPath(row: buttonTag, section: 0)
        let cell = collectionview.cellForItem(at: indexPath) as? homecollCell
        let obj = self.friends_array[buttonTag] as! Home
        
        if(obj.like == "0"){
            
            action = "1"
            
            cell?.btn_like.setBackgroundImage(UIImage(named:"ic_like"), for: .normal)
         
        }else{
            
          
            cell?.btn_like.setBackgroundImage(UIImage(named:"ic_like_fill"), for: .normal)
            action = "0"
        }
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.likeDislikeVideo!
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"video_id":obj.v_id!,"action":action!, "middle_name": self.appDelegate.middle_name]
        
//        print(url)
//        print(parameter!)

        let headers: HTTPHeaders = [
                "api-key": "4444-3333-2222-1111"
            ]
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:nil).validate().responseString(completionHandler: {
                
            respones in

           // print(respones)
                
            let jsondata = respones.data
            //print("jsondata",jsondata)
                
            switch respones.result {
                
            case .success (let value):
                
                let json  = value
        
             //   print(json)
               
             //   let dic = json as! NSDictionary
                
            //    let code = dic["code"] as! NSString
              //  if(code == "200"){
             
                   obj.like = action
                   
                    
                    if(obj.like == "0"){
                    
                        
                        cell?.btn_like.setBackgroundImage(UIImage(named:"ic_like"), for: .normal)
                        
                        if(Int(obj.like_count)! > 0){
                            
                            let str:Int = Int(obj.like_count)! - 1
                            obj.like_count = String(str)
                            
                            cell?.lblLikeCount.text = String(obj.like_count)
                            
                        }
                        
                    }else{
                        
                        let str:Int = Int(obj.like_count)! + 1
                        obj.like_count = String(str)
                        
                       cell?.lblLikeCount.text = String(obj.like_count)
                        cell?.btn_like.setBackgroundImage(UIImage(named:"ic_like_fill"), for: .normal)
                    }
                    
                    
              //  }else{
                    
                    
                    
             //   }
                
            case .failure(let error):
                print("error",error)
            }
        })
        }
        
    }
       
    @objc func onTapViewCount(_ sender : UIButton) {
        
    }
    
    func parseJSON(_ data: Data) -> [String: Any]? {

                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let body = json["data"] as? [String: Any] {
                            return body
                        }
                    } catch {
                        print("Error deserializing JSON: \n\(error)")
                        return nil
                    }
                    return nil
                }//    @objc func connected5(_ sender : UIButton) {

    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        
        let myview = sender.view
        let buttonTag = myview?.tag
        let indexPath = IndexPath(row: buttonTag!, section: 0)
        let cell = collectionview.cellForItem(at: indexPath) as! homecollCell
        
        if(cell.playBtn.currentImage == UIImage(named: "ic_play_icon")){
            
            
            cell.playBtn.setImage( UIImage(named: "ic_pause_icon"), for: .normal)
            cell.playBtn.isHidden = true
            cell.player?.play()
//                UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveLinear],
//                               animations: {
//                                cell.userView.center.y += (cell.animationView.bounds.height)
//                                cell.animationView.center.y += (cell.animationView.bounds.height)
//                                cell.stackView.center.x += (cell.stackView.bounds.width)
//                                cell.animationView.layoutIfNeeded()
//
//                               },  completion: {(_ completed: Bool) -> Void in
//                                cell.animationView.isHidden = true
//                                cell.stackView.isHidden =  true
//                               })

        }else if(cell.playBtn.currentImage == UIImage(named: "ic_pause_icon")){
      
                
                cell.playBtn.setImage( UIImage(named: "ic_play_icon"), for: .normal)
                cell.playBtn.isHidden = false
                cell.player?.pause()
            
//            UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveEaseIn],
//                           animations: {
//                            cell.userView.center.y -= (cell.animationView.bounds.height)
//                            cell.animationView.center.y -= (cell.animationView.bounds.height)
//                            cell.stackView.center.x -= (cell.stackView.bounds.width)
//                            cell.animationView.layoutIfNeeded()
//                           }, completion: nil)
//            cell.animationView.isHidden = false
//            cell.stackView.isHidden =  false
        }
        
        
    }
    
  
    
    
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//
//        let visiblePaths = self.collectionview.indexPathsForVisibleItems
//        for i in visiblePaths  {
//            let cell = collectionview.cellForItem(at: i) as? homecollCell
//
//            if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
//                let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
//                let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
//                if newStatus != oldStatus {
//                    DispatchQueue.main.async {[weak self] in
//                        if newStatus == .playing || newStatus == .paused {
//
//                            cell?.progressView.signal()
//                            cell?.progressView.alpha = 0
//                        } else {
//                            cell?.progressView.alpha = 1
//                           cell?.progressView.wait()
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    
   //MARK: Cross button clicked
    
    @IBAction func cross(_ sender: Any) {
        
        UIView.animate(withDuration: 0.5, animations: {
            //print(self.out_view.frame.origin.y)
            
            self.out_view.frame = CGRect(x: 0, y:1000 , width: self.view.frame.width, height: self.view.frame.height)
            
            self.out_view.alpha = 0
            
                self.updateVideoData(ind: self.commentIndex)
            
        },  completion: nil)
        
    }
    
    //MARK: UPpdate video data
    func updateVideoData(ind: Int){
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.showAllVideosNew!
        let object = self.friends_array[ind] as! Home
       // let sv = HomeViewController.displaySpinner(onView: self.view)
        var parameter : [String:Any] = [:]
        // if fromComment == true{
        parameter = ["fb_id":UserDefaults.standard.string(forKey: "uid") ?? "","video_id":object.v_id!, "middle_name": self.appDelegate.middle_name,"type":video_type!,"offset":offset!]
        
//    parameter = ["fb_id":UserDefaults.standard.string(forKey: "fb_Id") ?? "", "middle_name": self.appDelegate.middle_name,"type":video_type!,"offset":offset!]
    //    }
    //    print(url)
    //    print(parameter)
        let headers: HTTPHeaders = [
          "api-key": "4444-3333-2222-1111"
        ]
        AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
          respones in
          switch respones.result {
          case .success( let value):
            let json = value
           // HomeViewController.removeSpinner(spinner: sv)
            // self.Follow_Array = []
        //    print(json)
            let dic = json as! NSDictionary
            let code = dic["code"] as! NSString
            if(code == "200"){
              if let myCountry = dic["msg"] as? NSArray{
                guard myCountry != [] else {
                  return self.alertModule(title: "", msg: "Video is deleted by the user.")
                }
                if let sectionData = myCountry[0] as? NSDictionary{
                  let indexPath = IndexPath(row: ind, section: 0)
                  let cell = self.collectionview.cellForItem(at: indexPath) as? homecollCell
                  let count = sectionData["count"] as! NSDictionary
                  let status = sectionData["is_follow"] as! Int
                  cell?.lblLikeCount.text = count["like_count"] as? String
                  cell?.lblCommentCount.text = count["video_comment_count"] as? String
                  cell?.lblViewCount.text = count["view"] as? String
                  cell?.lblShareCount.text = count["share"] as? String
              
                if(status == 1){
                  //  print("video data status")

                    cell?.btnVerification.isHidden = true
                  }else{
                    cell?.btnVerification.isHidden = false
                  }
                }
              }
                //self.collectionview.reloadData()
            }else{
              self.alertModule(title:"Error", msg:dic["msg"] as? String ?? "")
            }
          case .failure(let error):
            print(error)
         //   HomeViewController.removeSpinner(spinner: sv)
            self.alertModule(title:"Error",msg:error.localizedDescription)
          }
        })
      }


    @IBAction func explore(_ sender: Any) {
        

        self.btn_following.titleLabel?.font =  UIFont(name: "Poppins-MediumItalic", size: 16.0)
        self.btn_foryou.titleLabel?.font =  UIFont(name: "Poppins-SemiBoldItalic", size: 16.0)
        self.btn_following.setTitleColor(UIColor.gray, for: .normal)
        self.btn_foryou.setTitleColor(UIColor.white, for: .normal)
        self.video_type = "related"
        self.showAllVideos(offset: self.offset)
    }
    
    // Get All comments Api
    
    func getComents() {
        
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.showVideoComments!
        let  sv = HomeViewController.displaySpinner(onView: self.out_view)
         
        
        let parameter :[String:Any]? = ["video_id":self.video_id!, "middle_name": self.appDelegate.middle_name]
        
//        print(url)
//        print(parameter!)
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
            
        ]
        
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
                
                HomeViewController.removeSpinner(spinner: sv)
                
                self.comments_array = []
               // print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    let myCountry = (dic["msg"] as? [[String:Any]])!
                    for Dict in myCountry {
                        
                        let myRestaurant = Dict as NSDictionary
                        var comments:String! = ""
                        var v_id:String! = ""
                        var first_name:String! = ""
                        var last_name:String! = ""
                        var profile_pic:String! = ""
                        var c_time:String! = ""
                        if let comm =  myRestaurant["comments"] as? String{
                            
                            comments = comm
                        }
                        if let created =  myRestaurant["created"] as? String{
                                                                              
                                                                              c_time = created
                                                                          }
                        if let myID =  myRestaurant["video_id"] as? String{
                            
                            v_id = myID
                        }
                        if let u_info = myRestaurant["user_info"] as? NSDictionary{
                        if let myFirest =  u_info["first_name"] as? String{
                            
                            first_name = myFirest
                        }
                        if let myLast =  u_info["last_name"] as? String{
                            
                            last_name = myLast
                        }
                        if let myPic =  u_info["profile_pic"] as? String{
                            
                            profile_pic = myPic
                        }
                           
                        }
                      
                      
                        
                        let obj = Comment(comments: comments, first_name: first_name, last_name: last_name,profile_pic: profile_pic, v_id: v_id, c_time: c_time)
                        
                        self.comments_array.add(obj)
                        
                        
                        
                    }
                    
                    self.comments_array = NSMutableArray(array: self.comments_array.reversed())
                    
                    //obj.video_comment_count = String(str)
                   // cell.btn_comments.setTitle(obj.video_comment_count, for: .normal)                    self.tableview.delegate = self
                    self.tableview.dataSource = self
                    self.tableview.reloadData()
                    if(self.comments_array.count > 0){
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: self.comments_array.count-1, section: 0)
                        self.tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                    }
                    
                }else{
                    
                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
                
                
            case .failure(let error):
               // print(error)
                HomeViewController.removeSpinner(spinner: sv)
                self.alertModule(title:"Network Issue",msg:"Please try after some time.")
            }
        })
    }
    
    
    // Send Comment Api
    @IBAction func sendComment(_ sender: Any) {
       
        if(UserDefaults.standard.string(forKey: "uid") == ""){
            
            let alertController = UIAlertController(title: "DhakDhak", message: "Please login from profile to send cooment!", preferredStyle: .alert)
            let okalertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
                self.tabBarController?.selectedIndex = 4
                
            })
            alertController.addAction(okalertAction)
            present(alertController, animated: true, completion: nil)
            
        }else{
        if(txt_comment.text != ""){
            
            
             let obj = friends_array[index] as! Home
            
            let url : String = self.appDelegate.baseUrl!+self.appDelegate.postComment!
            
            let  sv = HomeViewController.displaySpinner(onView: self.out_view)
            
            let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"video_id":self.video_id!,"comment":self.txt_comment.text!, "middle_name": self.appDelegate.middle_name]
            
//            print(url)
//            print(parameter!)
            
            let headers: HTTPHeaders = [
                "api-key": "4444-3333-2222-1111"
                
            ]
            
            AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseString(completionHandler: {
                
                respones in
                
                switch respones.result {
                case .success( let value):
                    
                    let json  = value
                    HomeViewController.removeSpinner(spinner: sv)
               //     print(json)
                //    let dic = json as! NSDictionary
                //    let code = dic["code"] as! NSString
                //    if(code == "200"){
                      self.txt_comment.text = ""
    
                  //  .btn_comments.setTitle(obj.video_comment_count, for: .normal)
                        self.getComents()
                      //  }else{
                       // self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    //}
                    
                case .failure(let error):
                   // print(error)
                    HomeViewController.removeSpinner(spinner: sv)
                    self.alertModule(title:"Error",msg:error.localizedDescription)
                }
            })
        }
        }
    }
    
    // Tableview Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CommentTableViewCell = self.tableview.dequeueReusableCell(withIdentifier: "cell01", for: indexPath) as! CommentTableViewCell
        
        let obj = self.comments_array[indexPath.row] as! Comment
        
        cell.comment_title.text = obj.first_name+" "+obj.last_name
        
        cell.comment_name.text = obj.comments
        
        cell.comment_img.sd_setImage(with: URL(string:obj.profile_pic), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
        
        
//        let date = Date()
//               let formatter = DateFormatter()
//               formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//               let result = formatter.string(from: date)
//        let str = self.timeCalculate(dateString:result , dateString1: obj.c_time)
//        print(str)
//        cell.comment_time.text = str
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func onTapFollowing(_ sender : Any) {
   
//        let indexPath = IndexPath(row: buttonTag, section: 0)
//        let cell = collectionview.cellForItem(at: indexPath) as! homecollCell
//
        if(UserDefaults.standard.string(forKey: "uid") == ""){
            
            let alertController = UIAlertController(title: "DhakDhak", message: "Please login from profile.", preferredStyle: .alert)
            let okalertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
                self.tabBarController?.selectedIndex = 4
                
            })
            alertController.addAction(okalertAction)
            present(alertController, animated: true, completion: nil)
            
        }else{
        self.btn_foryou.titleLabel?.font =  UIFont(name: "Poppins-MediumItalic", size: 16.0)
        self.btn_following.titleLabel?.font =  UIFont(name: "Poppins-SemiBoldItalic", size: 16.0)
        self.btn_foryou.setTitleColor(UIColor.gray, for: .normal)
        self.btn_following.setTitleColor(UIColor.white, for: .normal)
        self.video_type = "following"
        
        self.friends_array = []
        self.sound_array = []
        
        self.showAllVideos(offset: self.offset)
        }
    }
    
    @IBAction func onTapPopular(_ sender : Any) {
//        let buttonTag = sender.tag
//        
//        let indexPath = IndexPath(row: buttonTag, section: 0)
//        let cell = collectionview.cellForItem(at: indexPath) as! homecollCell
//        
        self.btn_following.titleLabel?.font =  UIFont(name: "Poppins-MediumItalic", size: 16.0)
        self.btn_foryou.titleLabel?.font =  UIFont(name: "Poppins-SemiBoldItalic", size: 16.0)
        self.btn_following.setTitleColor(UIColor.gray, for: .normal)
        self.btn_foryou.setTitleColor(UIColor.white, for: .normal)
        self.video_type = "related"
//        self.friends_array = []
//        self.sound_array = []
        self.showAllVideos(offset: self.offset)
    }
    
    func timeCalculate(dateString:String,dateString1:String) -> String{
           
           let calendar = Calendar.current
           
           // Get input(date) from textfield
           
           let isoDate = dateString
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           let date = dateFormatter.date(from:isoDate)!
           
           let isoDate1 = dateString1
           let dateFormatter1 = DateFormatter()
           dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
           let date1 = dateFormatter1.date(from:isoDate1)!
           
           let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
           let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: date1);
           
           let seconds = "\(difference.second ?? 0)s"
           let minutes = "\(difference.minute ?? 0)m"
           let hours = "\(difference.hour ?? 0)h" + " " + minutes
           let days = "\(difference.day ?? 0)d" + " " + hours
           
           if let day = difference.day, day          > 0 { return days }
           if let hour = difference.hour, hour       > 0 { return hours }
           if let minute = difference.minute, minute > 0 { return minutes }
           if let second = difference.second, second > 0 { return seconds }
           return ""
           
    }
    
    func addWatermark(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let mixComposition = AVMutableComposition()
        let asset = AVAsset(url: inputURL)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        let timerange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)

            let compositionVideoTrack:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))!

        do {
            try compositionVideoTrack.insertTimeRange(timerange, of: videoTrack, at: CMTime.zero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        } catch {
            print(error)
        }

        let watermarkFilter = CIFilter(name: "CISourceOverCompositing")!
        let watermarkImage = CIImage(image: UIImage(named: "dhakdhak_final")!)
        let videoComposition = AVVideoComposition(asset: asset) { (filteringRequest) in
            let source = filteringRequest.sourceImage.clampedToExtent()
            watermarkFilter.setValue(source, forKey: "inputBackgroundImage")
            let transform = CGAffineTransform(translationX: filteringRequest.sourceImage.extent.width - (watermarkImage?.extent.width)! - 2, y: 0)
            watermarkFilter.setValue(watermarkImage?.transformed(by: transform), forKey: "inputImage")
            filteringRequest.finish(with: watermarkFilter.outputImage!, context: nil)
        }

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480) else {
            handler(nil)

            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = videoComposition
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
}

extension HomeViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView(frame: UIScreen.main.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            
            UIApplication.shared.keyWindow!.addSubview(spinnerView)
            UIApplication.shared.keyWindow!.bringSubviewToFront(spinnerView)
            onView.bringSubviewToFront(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    
    
    
    
    
}
extension UILabel {
    func textDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
    
    static func createCustomLabel() -> UILabel {
        let label = UILabel()
        label.textDropShadow()
        return label
    }
}

extension UIView {
    static let loadingViewTag = 1938123987
    func showLoading(style: UIActivityIndicatorView.Style = .gray) {
        var loading = viewWithTag(UIView.loadingViewTag) as? UIActivityIndicatorView
        if loading == nil {
            loading = UIActivityIndicatorView(style: style)
        }

        loading?.translatesAutoresizingMaskIntoConstraints = false
        loading!.startAnimating()
        loading!.hidesWhenStopped = true
        loading?.tag = UIView.loadingViewTag
        addSubview(loading!)
      loading?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loading?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    func stopLoading() {
        let loading = viewWithTag(UIView.loadingViewTag) as? UIActivityIndicatorView
        loading?.stopAnimating()
        loading?.removeFromSuperview()
    }
}

enum shareType : UIActivity.ActivityType.RawValue{
    
    case Bluetooth = "1"
    case Gmail = "2"
    case Nearbyshare = "3"
    case Message = "4"
    case Facebook = "5"
    case Messanger = "6"
    case Instagram = "7"
    case Whatsapp = "8"
    case WhatsappBusiness = "9"
    case Telegram = "10"
    case AddToiCloudDrive = "11"
    case defalut = "0"
}
