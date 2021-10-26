//  ProfileViewController.swift
//  TIK TIK
//  Created by Rao Mudassar on 14/05/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.

import UIKit
import Alamofire
import SDWebImage
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices
import AVKit
import AVFoundation

var flag = false


class ProfileViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,GIDSignInDelegate{
    
    @IBOutlet weak var viewMyVideos: UIView!
    @IBOutlet weak var viewLikeVideo: UIView!
    @IBOutlet weak var inner_view: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //  @IBOutlet weak var btn_menu: UIBarButtonItem!
    @IBOutlet weak var viewEditProfile: UIView!
    @IBOutlet weak var viewLogout: UIView!
    @IBOutlet weak var viewSettings: UIView!
    
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnSettings: UIButton!
    
    @IBOutlet weak var btnMyVideos: UIButton!
    @IBOutlet weak var btnLikeVideos: UIButton!
    @IBOutlet weak var username_Lbl: UILabel!
    @IBOutlet weak var draftView: UIView!
    @IBOutlet weak var lbl_Draft: UILabel!
   // @IBOutlet weak var video_view: UIView!
    
    @IBOutlet weak var outer_view: UIView!
    @IBOutlet weak var user_img: UIImageView!
    
   // @IBOutlet weak var lbl_video: UILabel!
    
    @IBOutlet weak var lbl_follow: UILabel!
    
    @IBOutlet weak var lbl_fan: UILabel!
    
    @IBOutlet weak var lbl_heart: UILabel!
    
    @IBOutlet weak var video_img: UIImageView!
    
    @IBOutlet weak var like_img: UIImageView!
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblTerms: UILabel!
    
    var flagforMyVideo = true
    var first_name:String! = ""
    var last_name:String! = ""
    var email:String! = ""
    var my_id:String! = ""
    var profile_pic:String! = ""
    var signUPType:String! = ""
    var offset : Int? = 0

    var allVideos: [Videos] = []
    var video_array =  [Discover]()
   
    var likeVideoCount : Int = 0
    var totalVideoCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text = "By signing up , you confirm you agree to our Terms of Use and Privacy Policy"
        lblTerms.text = text
        self.lblTerms.textColor =  UIColor.white
        let underlineAttriString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "Terms of Use")
        let range2 = (text as NSString).range(of: "Privacy Policy")
        
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont.init(name: "Poppins-Medium", size: 15)!, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont.init(name: "Poppins-Medium", size: 15)!, range: range2)
        
        if #available(iOS 13.0, *) {
            underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.link, range: range1)
        } else {
            underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: range1)
        }
        
        if #available(iOS 13.0, *) {
            underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.link, range: range2)
        } else {
            underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: range2)
        }
        
        lblTerms.attributedText = underlineAttriString
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.isHidden = true
        
        let bottomRefreshController = UIRefreshControl()
        bottomRefreshController.triggerVerticalOffset = 50
        bottomRefreshController.addTarget(self, action: #selector(self.refreshBottom), for: .valueChanged)
        collectionview.bottomRefreshControl = bottomRefreshController
        collectionview.isPagingEnabled =  true
        
        viewSettings.layer.masksToBounds = false
        viewSettings.layer.cornerRadius = viewSettings.frame.height/2
        viewSettings.clipsToBounds = true
        
        viewEditProfile.layer.masksToBounds = false
        viewEditProfile.layer.cornerRadius = viewEditProfile.frame.height/2
        viewEditProfile.clipsToBounds = true
        
        viewLogout.layer.masksToBounds = false
        viewLogout.layer.cornerRadius = viewLogout.frame.height/2
        viewLogout.clipsToBounds = true
        
        
    }
    
     //MARK: Refresher bottom
       @objc func refreshBottom() {
           print("refresh")
        if totalVideoCount == allVideos.count{
            self.collectionview.bottomRefreshControl?.endRefreshing()

        }else{
            if btnMyVideos.tag == 1{
                updateNextSet()
            }else if btnLikeVideos.tag == 1{
                updateNextSetLike()
            }
           
           
        }
       }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = true
        
        UserDefaults.standard.set(false, forKey: "DraftSave")
        let placesData = UserDefaults.standard.object(forKey: "Draft") as? NSData

        if let placesData = placesData {
            let placesArray = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as? [URL]
            if placesArray!.isEmpty {
                draftView.isHidden = true
            }else{
                draftView.isHidden = false
            }
            lbl_Draft.text = "\(placesArray!.count)"
        }
        
       
//        self.tabBarController?.tabBar.tintColor = UIColor.white
//        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor(red: 205, green: 205, blue: 205, alpha: 1)
        
        print("selected index \(tabBarController?.selectedIndex)")
        print(flagforMyVideo)
        print(flag)
        if(UserDefaults.standard.string(forKey: "uid") == ""){
            self.inner_view.alpha = 1

        }else{
            self.inner_view.alpha = 0
            if flagforMyVideo == true{
                self.allVideos = []
                self.getAllVideos(offset1: self.offset!)
            }else{
                self.allVideos = []
                self.getLikeVideos(offset1: self.offset!)
            }
        }
        
        if UserDefaults.standard.value(forKey: "Profile_Pic") != nil{
        self.user_img.sd_setImage(with: URL(string:UserDefaults.standard.value(forKey: "Profile_Pic") as! String), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
        }
    }
    
    //MARK:  Facebook Login
    
    @IBAction func FBLogin(_ sender: Any) {
        
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        
                        
                    }
                }
            }
        }
        
    }
    
    func getFBUserData(){
        
        let sv = HomeViewController.displaySpinner(onView: self.view)
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email,age_range"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let dict = result as! [String : AnyObject]
                    print(dict)
                    if let dict = result as? [String : AnyObject]{
                        if(dict["email"] as? String == nil || dict["id"] as? String == nil || dict["email"] as? String == "" || dict["id"] as? String == "" ){
                            
                            HomeViewController.removeSpinner(spinner: sv)
                            
                            self.alertModule(title:"Error", msg:"You cannot login with this facebook account because your facebook is not linked with any email")
                            
                        }else{
                            HomeViewController.removeSpinner(spinner: sv)
                            self.email = dict["email"] as? String
                            self.first_name = dict["first_name"] as? String
                            self.last_name = dict["last_name"] as? String
                            self.my_id = dict["id"] as? String
                            let dic1 = dict["picture"] as! NSDictionary
                            let pic = dic1["data"] as! NSDictionary
                            self.profile_pic = pic["url"] as? String
                            UserDefaults.standard.set(self.profile_pic, forKey: "Profile_Pic")
                           
                            self.signUPType = "facebook"
                            
                            self.SignUpApi()
                            
                        }
                    }
                    
                }else{
                    
                    HomeViewController.removeSpinner(spinner: sv)
                    
                    
                }
            })
        }
        
    }
    
    // get All videos api
    
    //MARK: Get all videos api
    func getAllVideos(offset1: Int){
        viewMyVideos.isHidden = true
        viewLikeVideo.isHidden = true
        flagforMyVideo = true
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = true
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.showMyAllVideos!
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        let parameter :[String:Any]? = ["my_fb_id":UserDefaults.standard.string(forKey: "uid")!,"fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name,"offset":offset1]
        
    //    let parameter :[String:Any]? = ["my_fb_id":"10158924645617150","fb_id":"10158924645617150", "middle_name": self.appDelegate.middle_name,"offset":0]
        
//        print(url)
//        print(parameter!)
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
        ]
        
        AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            print(respones)
            switch respones.result {
            case .success( let value):
                
                let json  = value
                
                HomeViewController.removeSpinner(spinner: sv)
                self.collectionview.bottomRefreshControl?.endRefreshing()
                
//                self.allVideos = []
                  print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        
                        if  let sectionData = myCountry[0] as? NSDictionary{
                            
                            self.totalVideoCount = sectionData["total_video_count"] as? Int ?? 0
                            self.likeVideoCount = sectionData["total_like_count"] as? Int ?? 0
                            
                            let user_info = sectionData["user_info"] as? NSDictionary
                            let str1:String! = (user_info!["first_name"] as! String)
                            let str2:String! = (user_info!["last_name"] as! String)
                          //  self.navigationItem.title = str1+" "+str2
                            self.username_Lbl.text = str1 + str2
                            self.lblUsername.text = (user_info!["username"] as! String)
                            let hearts = sectionData["total_heart"] as? Int
                            self.lbl_follow.text = sectionData["total_following"] as? String
                            self.lbl_fan.text = sectionData["total_fans"] as? String
                            self.lbl_heart.text = String(sectionData["total_heart"] as? Int ?? 0)
                          
                            var tempProductList = ItemVideo()

                            if let  myCountry1 = (sectionData["user_videos"] as? [[String:Any]]){
                                if myCountry1.count == 0 || myCountry1.isEmpty || myCountry1 == nil{
                                    
                                }else if myCountry1.count == 1{
                                   
                                    let count = myCountry1[0]["count"] as! NSDictionary
                                
                                    let view = count["view"] as! String
                                     tempProductList.view_count = count["view"] as? String
                                    let thum = myCountry1[0]["thum"] as! String
                                    let v_id = myCountry1[0]["id"] as! String
                                    let final_approve_status = myCountry1[0]["final_approve_status"] as! String
                                    let first_name = user_info?["first_name"] as! String
                                    let last_name = user_info?["last_name"] as! String
                                  //  let profile_pic = user_info?["profile_pic"] as! String
                                    
                                    let u_id = user_info?["fb_id"] as! String
                                    let video = myCountry1[0]["video"] as? String
                                    let obj = Videos(thum: thum, first_name: first_name, last_name: last_name, profile_pic: "", v_id: v_id, view: view,u_id:u_id, approve_status: final_approve_status, video: video)
//                                    if self.totalVideoCount == self.allVideos.count{
//
//                                    }else{
                                        self.allVideos.append(obj)
                                   // }
                                    
                                    
                                }else{
                                    
                                    for Dict in myCountry1 {
                                        
                                        let count = Dict["count"] as! NSDictionary
                                        let view = count["view"] as! String
                                        tempProductList.view_count = count["view"] as? String
                                        let thum = Dict["thum"] as! String
                                        let v_id = Dict["id"] as! String
                                        
                                        let first_name = user_info?["first_name"] as! String
                                        let last_name = user_info?["last_name"] as! String
                                        //  let profile_pic = user_info?["profile_pic"] as! String
                                        let final_approve_status = Dict["final_approve_status"] as! String
                                        let u_id = user_info?["fb_id"] as! String
                                        let video = Dict["video"] as? String
                                        let obj = Videos(thum: thum, first_name: first_name, last_name: last_name, profile_pic: "", v_id: v_id, view: view,u_id:u_id, approve_status: final_approve_status, video: video)
                                        
                                       // if self.totalVideoCount == self.allVideos.count{
                                            
                                            
                                    //    }else{
                                            
                                            self.allVideos.append(obj)
                                      //  }
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                    
                    
                    if(self.allVideos.count == 0){
                        
                        self.btnMyVideos.setTitle("My Videos (0)", for: .normal)
                        self.btnLikeVideos.setTitle("Like Videos (\(String(self.likeVideoCount)))", for: .normal)
                        self.outer_view.alpha = 1
                        
                        self.collectionview.delegate = self
                        self.collectionview.dataSource = self
                        self.collectionview.reloadData()
                        
                    }else{
                        
                        self.btnMyVideos.setTitle("My Videos (\(String(self.totalVideoCount)))", for: .normal)
                        self.btnLikeVideos.setTitle("Like Videos (\(String(self.likeVideoCount)))", for: .normal)
                        self.outer_view.alpha = 0
                        
                        self.collectionview.delegate = self
                        self.collectionview.dataSource = self
                        self.collectionview.reloadData()
                    }
                    
                    
                }else{
                    
                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
            case .failure(let error):
                print(error)
                HomeViewController.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
        
        
    }
    
    //MARK:  get only like videos api
    func getLikeVideos(offset1: Int){
        viewMyVideos.isHidden = true
        viewLikeVideo.isHidden = true
        flagforMyVideo = false
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.my_liked_video!
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name, "offset":offset1]
        
//        print(url)
//        print(parameter!)
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
            
        ]
        
        AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            print(respones)
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
                
                HomeViewController.removeSpinner(spinner: sv)
                self.collectionview.bottomRefreshControl?.endRefreshing()
                self.allVideos = []
               //  print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        
                        if  let sectionData = myCountry[0] as? NSDictionary{
                            
                            self.likeVideoCount = sectionData["total_video_count"] as? Int ?? 0
//                            self.btnMyVideos.setTitle("My Videos (\(String(self.totalVideoCount)))", for: .normal)
//                            self.btnLikeVideos.setTitle("Like Videos (\(String(self.likeVideoCount)))", for: .normal)
                            
                            let user_info = sectionData["user_info"] as? NSDictionary
                            let str1:String! = (user_info!["first_name"] as! String)
                            let str2:String! = (user_info!["last_name"] as! String)
                          //  self.navigationItem.title = str1+" "+str2
                            
                          //  self.user_img.sd_setImage(with: URL(string:UserDefaults.standard.value(forKey: "Profile_Pic") as! String), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
                            
                            if let myCountry1 = sectionData["user_videos"] as? [[String:Any]]{
                                
                                if myCountry1.count == 0 || myCountry1.isEmpty || myCountry1 == nil {
                                    
                                }else{
                                    
                                    for Dict in myCountry1 {
                                        
                                        let count = Dict["count"] as! NSDictionary
                                        let view = count["view"] as? String
                                        let thum = Dict["thum"] as? String
                                        let v_id = Dict["id"] as? String
                                        let u_id = Dict["fbid"] as? String // fb id of other user for pass data
                                      
                                        let obj = Videos(thum: thum, first_name: "", last_name: "", profile_pic: "",v_id: v_id, view: view, u_id: u_id, approve_status: "0", video: "")
                                        
                                        self.allVideos.append(obj)
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                    if(self.allVideos.count == 0){
                        
//                        self.btnMyVideos.setTitle("My Videos (\(String(self.totalVideoCount)))", for: .normal)
//                        self.btnLikeVideos.setTitle("Like Videos (0)", for: .normal)
                        self.outer_view.alpha = 1
                        
                        self.collectionview.delegate = self
                        self.collectionview.dataSource = self
                        self.collectionview.reloadData()
                        
                    }else{
                        
//                        self.btnLikeVideos.setTitle("Like Videos (\(String(self.likeVideoCount)))", for: .normal)
//                        self.btnMyVideos.setTitle("My Videos (\(String(self.totalVideoCount)))", for: .normal)
                        self.outer_view.alpha = 0
                        
                        self.collectionview.delegate = self
                        self.collectionview.dataSource = self
                        self.collectionview.reloadData()
                    }
                    
                    
                    
                    
                    
                }else{
                    
                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
                
                
            case .failure(let error):
                print(error)
                HomeViewController.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
        
        
    }
    
    //MARK: Collectionview Deleagte methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
//        if indexPath.item == 0{
//            let cell1:CreateVideoTableViewCell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "CreateVideoTableViewCell", for: indexPath) as! CreateVideoTableViewCell
//            // let obj = self.allVideos[indexPath.item] as! Videos
//            // cell.lbl_seen.text = obj.view
//            let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
//            cell1.btnView.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
//            //  cell.video_image.sd_setImage(with: URL(string:obj.thum), placeholderImage: UIImage(named:“placeholderImg”))
//            cell = cell1
//        }else {
            let cell1:ProfileCell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "cellProfile", for: indexPath) as! ProfileCell
            let obj = self.allVideos[indexPath.item]
            cell1.lbl_seen.text = obj.view
        cell1.video_image.sd_setImage(with: URL(string:obj.thum), placeholderImage: UIImage(named:"placeholderImg"))
//        cell1.contentView.setGradientBackgroundImage(colorTop: UIColor.clear, colorBottom: UIColor(displayP3Red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1))
//        cell1.video_image.setGradientBackgroundImage(colorTop: UIColor.clear, colorBottom: UIColor(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1))
            cell = cell1
//        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        let obj = self.allVideos[indexPath.row] as! Videos
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: DiscoverVideoViewController = storyboard.instantiateViewController(withIdentifier: "DiscoverVideoViewController") as! DiscoverVideoViewController
//        if indexPath.row > 0{
//            let range = 0...(indexPath.row - 1)
//            self.allVideos.removeSubrange(range)
//        }
//        vc.friends_array = self.allVideos
        vc.fbId = UserDefaults.standard.string(forKey: "uid") ?? ""
        vc.videoId = self.allVideos[indexPath.row].v_id
        vc.position = indexPath.row
       // print(obj.approve_status)
        if flagforMyVideo == true{
            vc.type = "profile"
             if obj.approve_status == "2"{
                HomeViewController.removeSpinner(spinner: sv)
                self.navigationController?.pushViewController(vc, animated: true)
            }else if obj.approve_status == "3"{
                print(obj.v_id)
                let asset   = AVURLAsset.init(url: URL(string: obj.video)!)
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc1: VideoTrimmerVC = storyboard.instantiateViewController(withIdentifier: "VideoTrimmerVC") as! VideoTrimmerVC
                vc1.videoId = obj.v_id
                vc1.fromCopyRight = true
                vc1.url = URL(string: obj.video)! as NSURL
                vc1.asset = asset
                HomeViewController.removeSpinner(spinner: sv)
                self.navigationController?.pushViewController(vc1, animated: true)
            }else{
                self.alertModule(title: "", msg: "Video is under review")
                HomeViewController.removeSpinner(spinner: sv)
            }
        }else{
            vc.type = "mylikevideos"
            HomeViewController.removeSpinner(spinner: sv)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 3
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        return CGSize(width: size, height: size)
        // return CGSize(width: collectionView.layer.frame.width / 3, height:  collectionView.layer.frame.width / 3)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//         if indexPath.row >= allVideos.count {  //numberofitem count
//             updateNextSet()
//         }
     }

    func updateNextSet(){
         self.offset =  self.offset! + 10
        self.getAllVideos(offset1: self.offset!)
            //requests another set of data (20 more items) from the server.
     }
    
    func updateNextSetLike(){
         self.offset =  self.offset! + 10
        self.getLikeVideos(offset1: self.offset!)
            //requests another set of data (20 more items) from the server.
     }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
    
    @IBAction func videoChange(_ sender: Any) {
        self.allVideos = []
        self.getAllVideos(offset1: self.offset!)
        self.btnMyVideos.titleLabel?.font =  UIFont(name: "Poppins-Medium", size: 13)
        self.btnLikeVideos.titleLabel?.font =  UIFont(name: "Poppins-Regular", size: 13)
        self.btnMyVideos.setTitleColor(UIColor.white, for: .normal)
        self.btnLikeVideos.setTitleColor(UIColor.gray, for: .normal)
        self.btnMyVideos.tag = 1
        self.btnLikeVideos.tag = 0
//        self.video_img.image = UIImage(named:"Untitled-1-3")
//        self.like_img.image = UIImage(named:"Untitled-1-2")
        
        
    }
    
    @IBAction func likeChange(_ sender: Any) {
        flag = true
        self.getLikeVideos(offset1: self.offset!)
        self.btnLikeVideos.titleLabel?.font =  UIFont(name: "Poppins-Medium", size: 13)
        self.btnMyVideos.titleLabel?.font =  UIFont(name: "Poppins-Regular", size: 13)
        self.btnMyVideos.setTitleColor(UIColor.gray, for: .normal)
        self.btnLikeVideos.setTitleColor(UIColor.white, for: .normal)
        self.btnLikeVideos.tag = 1
        self.btnMyVideos.tag = 0
//        self.video_img.image = UIImage(named:"Untitled-1-1")
//        self.like_img.image = UIImage(named:"Untitled-1-4")
        
    }
    
   /* @IBAction func options(_ sender: Any) {
        let actionSheet =  UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
               
               let camera = UIAlertAction(title: "Edit Profile", style: .default, handler: {
                   (_:UIAlertAction)in
                   
                   self.performSegue(withIdentifier:"gotoedit", sender: self)
                   
               })
                let requestVerification = UIAlertAction(title: "Request Verification", style: .default, handler: {
                             
                        (_:UIAlertAction)in
                               
                          print("request verification")
                   let requestvc = self.storyboard?.instantiateViewController(withIdentifier: "RequestVerificationViewController") as! RequestVerificationViewController
                   self.present(requestvc, animated: true, completion: nil)
                  
                })

        let blockList = UIAlertAction(title: "Blocked Users", style: .default, handler: {
            
            (_:UIAlertAction)in
            
            self.performSegue(withIdentifier:"goToBlockList", sender: self)
            
        })

        
               let gallery = UIAlertAction(title: "Logout", style: .destructive, handler: {
                   (_:UIAlertAction)in
                   
                   UserDefaults.standard.set("", forKey: "uid")
                   self.navigationItem.title = "Profile"
                   self.navigationItem.rightBarButtonItem?.isEnabled = false
                   self.tabBarController?.selectedIndex = 0
                   
               })
               
               let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
               
               actionSheet.addAction(camera)
               actionSheet.addAction(requestVerification)
               actionSheet.addAction(blockList)
               actionSheet.addAction(gallery)
               //actionSheet.addAction(Giphy)
               actionSheet.addAction(cancel)
               if let popoverController = actionSheet.popoverPresentationController {
                   popoverController.sourceView = self.user_img
               }
               self.present(actionSheet, animated: true, completion: nil)
        
    }*/
    
    // Gmail Login
    
    func GoogleApi(user: GIDGoogleUser!){
        
        let sv = HomeViewController.displaySpinner(onView: self.view)
        
        if(user.profile.email == nil || user.userID == nil || user.profile.email == "" || user.userID == ""){
            
            
            
            HomeViewController.removeSpinner(spinner: sv)
            self.alertModule(title:"Error", msg:"You cannot signup with this Google account because your Google is not linked with any email.")
            
        }else{
            
            
            HomeViewController.removeSpinner(spinner: sv)
            //SliderViewController.removeSpinner(spinner: sv)
            self.email = user.profile.email
            self.first_name = user.profile.givenName
            self.last_name = user.profile.familyName
            self.my_id = user.userID
            if user.profile.hasImage
            {
                let pic = user.profile.imageURL(withDimension: 100)
                self.profile_pic = pic!.absoluteString
                UserDefaults.standard.set(self.profile_pic, forKey: "Profile_Pic")
            }else{
                self.profile_pic = ""
            }
            
            self.signUPType = "gmail"
            self.SignUpApi()
        }
        
        
    }
    
    // Register Api
    
    func SignUpApi(){
        
                let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        var VersionString:String! = ""
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            VersionString = version
        }
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.signUp!
        let udid = UIDevice.current.identifierForVendor?.uuidString

        
        let parameter:[String:Any]?  = ["fb_id":self.my_id!,"first_name":self.first_name!,"last_name":self.last_name!,"profile_pic":self.profile_pic!,"gender":"m","signup_type":self.signUPType!,"version":VersionString!,"device":"iOS", "latitude" : UserDefaults.standard.value(forKey: "Latitude") ?? "", "longitude" : UserDefaults.standard.value(forKey: "Longitude") ?? "","device_id":udid!, "referral_fb_id": UserDefaults.standard.value(forKey: "referral_fb_id") ?? ""]
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
                  // print(json)
                
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                
                if(code == "200"){
                    
                    let myCountry = dic["msg"] as? NSArray
                    
                    if let data = myCountry![0] as? NSDictionary{
                        
                        print(data)
                        
                        let uid = data["fb_id"] as! String
                        UserDefaults.standard.set(uid, forKey: "uid")
                        
                        self.navigationController?.navigationBar.isHidden = true
                     //   self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.inner_view.alpha = 0
                        
                        //  self.btn_menu.tintColor = UIColor.white
                        self.allVideos = []
                        self.getAllVideos(offset1: self.offset!)
                        
                    }
                    
                }else{
                    
                    
                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
                
            case .failure(let error):
                
                print(error)
                
                HomeViewController.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
                
                
            }
        })
        
        
    }
    
    @IBAction func GoogleLogin(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        //UIActivityIndicatorView.stopAnimating()
    }
    
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if (error == nil) {
            // Perform any operations on signed in user here.
            self.GoogleApi(user: user)
            
            // ...
        } else {
            
            //            self.view.isUserInteractionEnabled = true
            //            KRProgressHUD.dismiss {
            //                print("dismiss() completion handler.")
            //
            //            }
            print("\(error.localizedDescription)")
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
        
        
        
    }
    
    @IBAction func privacy(_ sender: Any) {
        
        guard let url = URL(string: "https://dhakdhak.world/privacy_policy.html") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func terms(_ sender: Any) {
        
        guard let url = URL(string: "https://dhakdhak.world/terms_conditions.html") else { return }
        UIApplication.shared.open(url)
        
    }
    
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func applelogin(_ sender: Any) {
        if #available(iOS 13.0, *) {
            //Show sign-in with apple button. Create button here via code if you need.
            self.setupAppleIDCredentialObserver()
            let appleSignInRequest = ASAuthorizationAppleIDProvider().createRequest()
            appleSignInRequest.requestedScopes = [.fullName, .email]
            let controller = ASAuthorizationController(authorizationRequests: [appleSignInRequest])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        } else {
            // Fallback on earlier versions
            //Hide your sign in with apple button here.
        }
    }
    
    @IBAction func phoneNologin(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: LoginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
        //performSegue(withIdentifier: "showLoginVC", sender: nil)
    }
    
    private func setupAppleIDCredentialObserver() {
        if #available(iOS 13.0, *) {
            let authorizationAppleIDProvider = ASAuthorizationAppleIDProvider()
            authorizationAppleIDProvider.getCredentialState(forUserID: "currentUserIdentifier") { (credentialState: ASAuthorizationAppleIDProvider.CredentialState, error: Error?) in
                if let error = error {
                    print(error)
                    // Something went wrong check error state
                    return
                }
                switch (credentialState) {
                case .authorized:
                    //User is authorized to continue using your app
                    break
                case .revoked:
                    //User has revoked access to your app
                    break
                case .notFound:
                    //User is not found, meaning that the user never signed in through Apple ID
                    break
                default: break
                }
            }
        }else{
        }
    }
    
    @IBAction func onTapFollowers(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Following1ViewController") as! Following1ViewController
        vc.fbId = UserDefaults.standard.string(forKey: "uid")!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTapFollowing(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowingViewController") as! FollowingViewController
        vc.fbId = UserDefaults.standard.string(forKey: "uid")!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onTapDraft(_ sender: Any) {
           
           let vc = self.storyboard?.instantiateViewController(withIdentifier: "DraftVC") as! DraftVC
           self.navigationController?.pushViewController(vc, animated: true)
       }
    
    @IBAction func onTapEditProfile(_ sender: Any) {
        self.performSegue(withIdentifier:"gotoedit", sender: self)
    }
    
    @IBAction func onTapSettings(_ sender: Any) {
        let actionSheet =  UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        
        let requestVerification = UIAlertAction(title: "Request Verification", style: .default, handler: {
            
            (_:UIAlertAction)in
            
            print("request verification")
            let requestvc = self.storyboard?.instantiateViewController(withIdentifier: "RequestVerificationViewController") as! RequestVerificationViewController
            self.present(requestvc, animated: true, completion: nil)
            
        })
        
        let privacypolicy = UIAlertAction(title: "Privacy Policy", style: .default, handler: {
            
            (_:UIAlertAction)in
            
            guard let url = URL(string: "https://dhakdhak.world/privacy_policy.html") else { return }
            UIApplication.shared.open(url)
            
        })
        
        let blockList = UIAlertAction(title: "Blocked Users", style: .default, handler: {
            
            (_:UIAlertAction)in
            
            self.performSegue(withIdentifier:"goToBlockList", sender: self)
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // actionSheet.addAction(camera)
        actionSheet.addAction(requestVerification)
        actionSheet.addAction(privacypolicy)
        actionSheet.addAction(blockList)
         
        //actionSheet.addAction(Giphy)
        actionSheet.addAction(cancel)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.user_img
        }
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func onTapLogout(_ sender: Any) {
        UserDefaults.standard.set("", forKey: "uid")
        self.navigationItem.title = "Profile"
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.tabBarController?.selectedIndex = 0
    }
    
}

extension ProfileViewController: ASAuthorizationControllerDelegate {
    @available(iOS 12.0, *)
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        print("User ID: \(appleIDCredential.user)")
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            print(appleIDCredential)
        case let passwordCredential as ASPasswordCredential:
            print(passwordCredential)
        default: break
        }
        
        if let userEmail = appleIDCredential.email {
            print("Email: \(userEmail)")
            self.email = userEmail
            self.my_id = appleIDCredential.user
        }
        
        if let userGivenName = appleIDCredential.fullName?.givenName,
            
            let userFamilyName = appleIDCredential.fullName?.familyName {
            //print("Given Name: \(userGivenName)")
            // print("Family Name: \(userFamilyName)",
            self.my_id = appleIDCredential.user
            self.first_name = userGivenName
            self.last_name = userFamilyName
            
            
        }
        
        
        
        if let authorizationCode = appleIDCredential.authorizationCode,
            let identifyToken = appleIDCredential.identityToken {
            print("Authorization Code: \(authorizationCode)")
            print("Identity Token: \(identifyToken)")
            //First time user, perform authentication with the backend
            //TODO: Submit authorization code and identity token to your backend for user validation and signIn
            //self.signUp(self)
            // if(self.email != ""){
            
            self.signUPType = "apple"
            self.profile_pic = ""
            self.SignUpApi()
            // }else{
            
            //self.alertModule(title:"Error", msg: "Please share your email.")
            // }
            return
        }
        //TODO: Perform user login given User ID
        
        
        
        
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization returned an error: \(error.localizedDescription)")
    }
}
extension ProfileViewController: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

