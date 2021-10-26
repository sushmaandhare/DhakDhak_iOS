//  DiscoverViewController.swift
//  TIK TIK
//  Created by Rao Mudassar on 08/05/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.

import UIKit
import Alamofire
import SDWebImage
import ContentLoader
import AVKit
import ImageSlideshow

class DiscoverViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate,ContentLoaderDataSource {
    
    @IBOutlet weak var SearchUserTableView: UITableView!
    @IBOutlet var no_Data_IMG: UIImageView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var userBtn: UIButton!
    @IBOutlet weak var VideoBtn: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var SearchText = ""
    var player:AVPlayer!
    
    @IBOutlet weak var audioBottomView: UIView!
    @IBOutlet weak var videoBottomView: UIView!
    @IBOutlet weak var userBottonView: UIView!
    @IBOutlet weak var audioBtn: UIButton!
    
    var video_array =  [Discover]()
    var filterUserArr = [SearchUser]()
    var filterSoundArr = [SearchSound]()
    var FilerVideoArr = [ItemVideo]()
    
    var SearchUserArr = [SearchUser]()
    var SearchVideoArr = [ItemVideo]()
    var sound_array = [SearchSound]()
    
    @IBOutlet var slideshow: ImageSlideshow!
    
    
    @IBOutlet weak var discoverView: UIView!
    @IBOutlet weak var searchView: UIView!
    
    var filtered = [Discover]()
    var searchActive : Bool = false
    var Newssection:NSMutableArray = []
    var loadingToggle:String? = "yes"
    var refreshControl = UIRefreshControl()
    var bannerList = [BannerImagesList]()
    var img = [String]()
    var hashArr : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        getBannerImages()
       
        self.search.delegate = self
        SearchUserTableView.tableFooterView = UIView(frame: .zero)
        tableview.tableFooterView = UIView(frame: .zero)
        self.tableview.backgroundColor = UIColor(displayP3Red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0, alpha: 1)
       // tableview.tableFooterView = UIView()
     //   self.getVideos()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(DiscoverViewController.refresh), for: UIControl.Event.valueChanged)
        
       //self.tableview?.addSubview(refreshControl)
        
        //self.tableview.isLoadable = true
        
        var format = ContentLoaderFormat()
        format.color = "#F6F6F6".hexColor
        format.radius = 5
        format.animation = .fade
        
        
       // self.tableview.startLoading(format: format)
        
        //self.tableview.startLoading()
        
        self.searchView.isHidden = true
        self.discoverView.isHidden = false
        
      
        userBottonView.backgroundColor = .white
        audioBottomView.backgroundColor = .clear
        videoBottomView.backgroundColor = .clear
        
        
      slideshow.activityIndicator = DefaultActivityIndicator()
      slideshow.currentPageChanged = {
          page in
          print("current page:", page)
      }
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        slideshow.addGestureRecognizer(recognizer)
        self.getVideos()
    }
    
//MARK: Slideshow Image Tap
    @objc func didTap() {
        let int = slideshow.currentPage // GET CURRENT PAGE VALUE
        print("tap count",int)
       
        if bannerList[int].comment == "DISCOVER"{
            
            for item in video_array{
                if item.name == bannerList[int].banner_url{
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc: AllDiscoverVideoVC = storyboard.instantiateViewController(withIdentifier: "AllDiscoverVideoVC") as! AllDiscoverVideoVC
                  //  vc.allVideos = item
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }else if bannerList[int].comment == "URL"{
            var bannerUrl = bannerList[int].banner_url
            print(bannerUrl)
            guard let url = URL(string: bannerUrl!) else { return }
            UIApplication.shared.open(url)
        }else if bannerList[int].comment == "USER"{
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: Profile1ViewController = storyboard.instantiateViewController(withIdentifier: "Profile1ViewController") as! Profile1ViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            
           /* let url : String = self.appDelegate.baseUrl!+self.appDelegate.showAllVideosNew!
                         
        let  sv = HomeViewController.displaySpinner(onView: self.view)
            let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"video_id":bannerList[int].banner_url,"device_token":"Null", "middle_name": self.appDelegate.middle_name]
                           
                           print(url)
                           print(parameter!)
                           
                           let headers: HTTPHeaders = [
                               "api-key": "4444-3333-2222-1111"
                               
                           ]
                           
                           AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
                               
                               respones in
                               
                               
                               
                               switch respones.result {
                               case .success( let value):
                                   
                                   let json  = value
                                   
                                   HomeViewController.removeSpinner(spinner: sv)
                                   
                                  // self.Follow_Array = []
                                  // print(json)
                                   let dic = json as! NSDictionary
                                   let code = dic["code"] as! NSString
                                   if(code == "200"){
                                    
                                    if let myCountry = dic["msg"] as? NSArray{
                                        guard myCountry != [] else {
                                            return self.alertModule(title: "", msg: "Video is deleted by the user.")
                                        }

                                        if  let sectionData = myCountry[0] as? NSDictionary{
                                            
                                             let count = sectionData["count"] as! NSDictionary
                                            let sound = sectionData["sound"] as! NSDictionary
                                            let Username = sectionData["user_info"] as! NSDictionary
                                       
                                   StaticData.obj.userName = Username["username"] as? String
                                                 StaticData.obj.userImg = Username["profile_pic"] as? String
                                                 StaticData.obj.liked = sectionData["liked"] as? String
                                                 StaticData.obj.like_count = count["like_count"] as? String
                                            StaticData.obj.view_count = count["view"] as? String
                                                 StaticData.obj.soundName = sound["sound_name"] as? String
                                            StaticData.obj.comment_count = count["video_comment_count"] as? String
                                                 StaticData.obj.videoID = sectionData["id"] as? String
                                                StaticData.obj.other_id = sectionData["fb_id"] as? String
                                            
                                            let audio_patha = sound["audio_path"] as! NSDictionary
                                            let audio_url = audio_patha["acc"] as! String
                                            let s_id = sound["id"] as? String ?? ""
                                            let desc = sectionData["description"] as? String
                                            let thum = sectionData["thum"] as! String
                                            
                                            UserDefaults.standard.set(sectionData["video"], forKey: "dis_url")
                                            UserDefaults.standard.set(sectionData["thum"] as! String, forKey: "dis_img")
                                            
                                                 DispatchQueue.main.async {
                                                     
                                                     let vc = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverVideoViewController") as! DiscoverVideoViewController

                                                    vc.videoId = self.bannerList[int].banner_url
                                                    vc.fromScreen = "Discover"
                                                   // self.navigationController?.pushViewController(vc, animated: true)
                                                 }
                                        }
                                    }
                                   }else{
                                       
                                       self.alertModule(title:"Error", msg:dic["msg"] as! String)
                                       
                                   }
                         
                                   
                                   
                               case .failure(let error):
                                   print(error)
                                   HomeViewController.removeSpinner(spinner: sv)
                                   self.alertModule(title:"Error",msg:error.localizedDescription)
                               }
                           })*/
        }
        
       
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        flag = false
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = true
        if appDelegate.tabbarSelect != 1
        {
            self.searchView.isHidden = true
            self.discoverView.isHidden = false
            search.text = ""
        }
       
    }
    
    
    
    
    //MARK: Get banner Image API
    func getBannerImages(){
        //slideshow.setImageInputs(bannerList!)
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.getBannerImages
        let parameter :[String:Any]? = ["middle_name": self.appDelegate.middle_name]
        let headers: HTTPHeaders = [
          "api-key": "4444-3333-2222-1111"
        ]
        AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
          respones in
          switch respones.result {
          case .success( let value):
            let json = value
           //  HomeViewController.removeSpinner(spinner: sv)
           //  print(json)
            let dic = json as! NSDictionary
            let code = dic["code"] as! NSString
            if(code == "200"){
              var imageSource: [ImageSource] = []
              if let myCountry = dic["msg"] as? NSArray{
                for dict in myCountry{
                  if let sectionData = dict as? NSDictionary{
                    let banner_img:String! = (sectionData["banner_img"] as! String)
                    let banner_id:String! = (sectionData["id"] as! String)
                    let banner_url:String! = (sectionData["url"] as! String)
                    let type:String! = (sectionData["type"] as! String)
                    let comment:String! = (sectionData["comment"] as! String)
                    let obj = BannerImagesList(banner_img: banner_img, banner_url: banner_url, banner_id: banner_id, type: type, comment: comment)
                    self.bannerList.append(obj)
                    if(self.bannerList.count == 0){
                      //show empty view
                    }else{
                      //self.getVideos()
                    }
              print(banner_img)
              var imf = banner_img .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                    var img = banner_img.replacingOccurrences(of: " ", with: "%20")
                    let url = NSURL(string: img)
                if url != nil{
                  print("imgurl",url)
                  let data = NSData(contentsOf:url! as URL)
                  if data == nil{
                    print("data",data)
                    print("imgurl",url)
                  }else{
                    let img = UIImage(data: data! as Data)
                    print("data",data)
                    imageSource.append(ImageSource(image: img!))
                    }
                  }
                  }
                }
              }
              print("input image", imageSource)
              //set images to slideshow
              self.slideshow.setImageInputs(imageSource)
            }else{
             // self.alertModule(title:"Error", msg:dic["msg"] as! String)
            }
          case .failure(let error):
            print(error)
           //  HomeViewController.removeSpinner(spinner: sv)
            // self.alertModule(title:"Error",msg:error.localizedDescription)
          }
        })
      }
    
    //MARK: GET VIDEOS
    func getVideos()
    {
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.discover!
        
        if(loadingToggle == "yes"){
            
            //  sv = HomeViewController.displaySpinner(onView: self.view)
        }
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name]
        print(url)
        print(parameter!)
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
        ]
        
        AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
                
               // self.tableview.hideLoading()
                self.hashArr.removeAll()
                self.video_array = []
                self.Newssection = []
               // print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        for i in 0...myCountry.count-1{
                            
                            if  let sectionData = myCountry[i] as? NSDictionary{
                              
                                var tempMenuObj = Discover()
                                tempMenuObj.name = sectionData["section_name"] as? String
                                tempMenuObj.hashtagIcon = sectionData["section_icon"] as? String ?? " "
                                tempMenuObj.totalView = sectionData["section_views"] as! String
                                tempMenuObj.section_Id = sectionData["section_id"] as? String
                                self.Newssection.add(tempMenuObj.name!)
                                self.hashArr.append(tempMenuObj.name!)
                                tempMenuObj.sectionInd = i
                                if let extraData = sectionData["sections_videos"] as? NSArray{
                                    
                                    for j in 0...extraData.count-1{
                                        
                                        let dic2 = extraData[j] as! [String:Any]
                                        var tempProductList = ItemVideo()
                                        
                                      //  tempProductList.description = dic2["description"] as? String
                                         
//                                        if let count = dic2["count"] as? NSDictionary{
//
//                                            tempProductList.like_count = count["like_count"] as? String
//
//                                            tempProductList.video_comment_count = count["video_comment_count"] as? String
//
//                                            tempProductList.view_count = count["view"] as? String
//
//                                            tempProductList.share = count["share"] as? String
//                                        }
                                        
//                                        if let user_info = dic2["user_info"] as? NSDictionary{
//
//                                            tempProductList.first_name = user_info["username"] as? String ?? "No Name"
//                                            tempProductList.f_name = user_info["first_name"] as? String ?? ""
//                                            tempProductList.last_name = user_info["last_name"] as? String
//
//                                            tempProductList.profile_pic = user_info["profile_pic"] as? String
//
//                                            tempProductList.u_id = user_info["fb_id"] as? String
//                                        }
                                        
                                        
//                                        tempProductList.video = dic2["video"] as? String
                                        tempProductList.thum = dic2["thum"] as? String
//                                        tempProductList.liked = dic2["liked"] as? String
                                        tempProductList.v_id = dic2["id"] as? String
                                        
//                                        if let sound = dic2["sound"] as? NSDictionary{
//                                            let audio_patha = sound["audio_path"] as! NSDictionary
//                                            tempProductList.sound_name = sound["sound_name"] as? String
//                                            tempProductList.audio_url = audio_patha["acc"] as! String
//                                            tempProductList.s_id = sound["id"] as? String
//                                        }
                                        
                                        tempMenuObj.listOfProducts.append(tempProductList)
                                        
                                    }
                                    
                                }
                                
                                self.video_array.append(tempMenuObj)
                            }
                            
                        }
                        
                    }
                    
                    //self.refreshControl.endRefreshing()
                    self.tableview.delegate = self
                    self.tableview.dataSource = self
                    self.tableview.reloadData()
                    
                }else{
                    //self.refreshControl.endRefreshing()
                    if Reachability.isConnectedToNetwork() == false{
                       self.alertModule(title:"Network Issue", msg: "Internet connection appears to be offline. Please try again later.")
                    }else{
                         self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    }
                }
                
            case .failure(let error):
               // print(error)
                self.refreshControl.endRefreshing()
                //self.tableview.hideLoading()
                //to hide the loader
                if Reachability.isConnectedToNetwork() == false{
                  self.alertModule(title:"Network Issue",msg: "No Internet Connection")
                }else{
                  self.alertModule(title:"Error",msg:error.localizedDescription)
                }
            }
        })
    }
    
    //MARK: Send Data to server
    func sendDataToServer()
    {
            
            let group = DispatchGroup()
            group.enter()
            
             let  sv = HomeViewController.displaySpinner(onView: self.view)
            
            let url1 : String = self.appDelegate.baseUrl!+self.appDelegate.Search_User!
            
            
            if(loadingToggle == "yes"){
                
                //sv = HomeViewController.displaySpinner(onView: self.view)
            }
            //"fb_id":UserDefaults.standard.string(forKey: "uid")!,"
        
            //old paeameter
        let parameter1 :[String:Any]? = ["keyword":SearchText, "type":"users", "middle_name": self.appDelegate.middle_name,"user_id":UserDefaults.standard.string(forKey: "uid")!,"offset":0 ]
//
//        let parameter1 :[String:Any]? = ["keyword":SearchText, "type":"hashtag", "middle_name": self.appDelegate.middle_name, "starting_point":"0", "user_id":UserDefaults.standard.string(forKey: "uid")!]
    //         print("--url user ----\(url1)")
             print("--parameter user ----\(parameter1)")
            
            let headers1: HTTPHeaders = [
                "api-key": "4444-3333-2222-1111"
                
            ]
            
            AF.request(url1, method: .post, parameters:parameter1, encoding:JSONEncoding.default, headers:headers1).validate().responseJSON(completionHandler: {
                
                respones in
                print(respones)
                
                switch respones.result {
                case .success( let value):
                    HomeViewController.removeSpinner(spinner: sv)
                    let json  = value
                    
                    self.SearchUserArr.removeAll()
                    
                   // self.tableview.hideLoading()
                    
                    //self.video_array = []
                   // self.Newssection = []
                    print(print("userJSON --- \(json)"))
                    let dic = json as! NSDictionary
                    let code = dic["code"] as! NSString
                    if(code == "200"){
                        
                        
                        
                        if let myCountry = dic["msg"] as? NSArray{
                            if myCountry.count > 0{
                            for i in 0...myCountry.count-1{
                                
                                if  let sectionData = myCountry[i] as? NSDictionary{
                                    var tempMenuObj = SearchUser()
                                    tempMenuObj.block = sectionData["block"] as? String
                                    tempMenuObj.created = sectionData["created"] as? String
                                    tempMenuObj.fb_id = sectionData["fb_id"] as? String
                                    tempMenuObj.device = sectionData["device"] as? String
                                    tempMenuObj.first_name = sectionData["first_name"] as? String ?? "No Name"
                                    tempMenuObj.gender = sectionData["gender"] as? String
                                    tempMenuObj.last_name = sectionData["last_name"] as? String
                                    tempMenuObj.profile_pic = sectionData["profile_pic"] as? String
                                    tempMenuObj.signup_type = sectionData["signup_type"] as? String
                                    tempMenuObj.username = sectionData["username"] as? String
                                    tempMenuObj.verified = sectionData["verified"] as? String
                                    tempMenuObj.version = sectionData["version"] as? String
                                    tempMenuObj.videos = sectionData["videos"] as? Int ?? 0
                                    
                                    self.SearchUserArr.append(tempMenuObj)
                                }
                                
                            }
                        }
                        }
                        
                        
                        
                        //                    self.refreshControl.endRefreshing()
                        //                    self.SearchUserTableView.delegate = self
                        //                    self.SearchUserTableView.dataSource = self
                        //                    self.SearchUserTableView.reloadData()
                        //
                        
                        
                        
                    }else{
                        self.refreshControl.endRefreshing()
                        self.alertModule(title:"Error", msg:dic["msg"] as! String)
                        
                    }
                    
                    
                    
                case .failure(let error):
                    print(error)
                    self.refreshControl.endRefreshing()
                   // self.SearchUserTableView.hideLoading()
                    HomeViewController.removeSpinner(spinner: sv)
                    //to hide the loader
                    
                    self.alertModule(title:"Error",msg:error.localizedDescription)
                }
                
                group.leave()
            })
            
            
          /*  group.enter()
            
            
            let url2 : String = self.appDelegate.baseUrl!+self.appDelegate.Search_User!
            
            let parameter2 :[String:Any]? = ["keyword":self.SearchText, "type":"video", "middle_name": self.appDelegate.middle_name]
            
    //        print(url2)
    //        print(parameter2!)
            
            let headers2: HTTPHeaders = [
                "api-key": "4444-3333-2222-1111"
                
            ]
            
            AF.request(url2, method: .post, parameters:parameter2, encoding:JSONEncoding.default, headers:headers2).validate().responseJSON(completionHandler: {
                
                respones in
                
                switch respones.result {
                case .success( let value):
                    
                    let json  = value
                    
                    //self.tableview.hideLoading()
                    self.SearchVideoArr.removeAll()
                    //self.video_array = []
                    //self.Newssection = []
                 //   print("videoJSON --- \(json)")
                    let dic = json as! NSDictionary
                    let code = dic["code"] as! NSString
                    if(code == "200"){
                        
                        if let myCountry = dic["msg"] as? NSArray{
                          if  myCountry.count > 0{
                            for i in 0...myCountry.count-1{
                                if  let dic2 = myCountry[i] as? NSDictionary{
                                    //   if  let sectionData = myCountry[i] as? NSDictionary{
                                   // let tempMenuObj = Discover()

                                    
                                    var tempProductList = ItemVideo()
                                    
                                    if let count = dic2["count"] as? NSDictionary{
                                        
                                        tempProductList.like_count = count["like_count"] as? String
                                        
                                        tempProductList.video_comment_count = count["video_comment_count"] as? String
                                    }
                                    
                                    if let user_info = dic2["user_info"] as? NSDictionary{
                                        
                                        tempProductList.first_name = user_info["first_name"] as?  String ?? " "
                                        
                                        tempProductList.last_name = user_info["last_name"] as? String
                                        
                                        tempProductList.profile_pic = user_info["profile_pic"] as? String
                                        
                                        //tempProductList.u_id = user_info["id"] as? String
                                    }
                                    
                                     tempProductList.u_id = dic2["fb_id"] as? String
                                    tempProductList.video = dic2["video"] as? String
                                    tempProductList.thum = dic2["gif"] as? String
                                    tempProductList.liked = dic2["liked"] as? String
                                    tempProductList.v_id = dic2["id"] as? String
                                    tempProductList.description =  dic2["description"] as? String
                                    
                                    if let sound = dic2["sound"] as? NSDictionary{
                                        
                                        tempProductList.sound_name = sound["sound_name"] as? String
                                        
                                    }
              
                                    self.SearchVideoArr.append(tempProductList)
                                }
                                
                            }
                        }
                        }
               
                    }else{
                        // self.refreshControl.endRefreshing()
                        self.alertModule(title:"Error", msg:dic["msg"] as! String)
                        
                    }
                    
                    
                    
                    
                case .failure(let error):
                    print(error)
                    //  self.refreshControl.endRefreshing()
                    //self.SearchUserTableView.hideLoading()
                    
                    //to hide the loader
                    HomeViewController.removeSpinner(spinner: sv)

                    self.alertModule(title:"Error",msg:error.localizedDescription)
                }
                
                 group.leave()
            })
            
           
            
            group.enter()
            
            let url3 : String = self.appDelegate.baseUrl!+self.appDelegate.Search_User!
            //  let  sv = HomeViewController.displaySpinner(onView: self.view)
            
            
            let parameter3 :[String:Any]? = ["keyword":self.SearchText, "type":"sound", "middle_name": self.appDelegate.middle_name]
            
    //        print(url3)
    //        print(parameter3!)
            
            let headers3: HTTPHeaders = [
                "api-key": "4444-3333-2222-1111"
                
            ]
            
            AF.request(url3, method: .post, parameters:parameter3, encoding:JSONEncoding.default, headers:headers3).validate().responseJSON(completionHandler: {
                
                respones in
                
                switch respones.result {
                case .success( let value):
                    
                    let json  = value
                    
                    //HomeViewController.removeSpinner(spinner: sv)
                    
                    self.sound_array.removeAll()
                  //  print("soundJSON --- \(json)")
                    let dic = json as! NSDictionary
                    let code = dic["code"] as! NSString
                    if(code == "200"){
                        
                        if let myCountry = dic["msg"] as? NSArray{
                            if myCountry.count > 0{
                            for i in 0...myCountry.count-1{
                                
                                if  let sectionData = myCountry[i] as? NSDictionary
                                {
                                    let tempMenuObj = Sound()
                                    
                                    var tempProductList = SearchSound()
                                    
                                    if let audio_path = sectionData["audio_path"] as? NSDictionary{
                                        
                                        //print("audio data ===\(audio_path)")
                                        
                                        tempProductList.audio_path = audio_path["acc"] as? String
                                        tempProductList.mpthree = audio_path["mp3"] as? String
                                        
                                        
                                    }
                                    
                                    tempProductList.created = sectionData["created"] as? String
                                    tempProductList.description = sectionData["description"] as? String
                                    tempProductList.sound_name = sectionData["sound_name"] as? String
                                    tempProductList.fav = sectionData["fav"] as? String
                                    tempProductList.id = sectionData["id"] as? String
                                    tempProductList.section = sectionData["section"] as? String
                                    tempProductList.thum = sectionData["thum"] as? String
                                    
                                    
                                    self.sound_array.append(tempProductList)
                                    
                                    
                                    
                                }
                                
                                // print("sound_name data ===\(self.sound_array)")
                                
                            }
                            
                        }
                    }

                        
                    }else{
                        
                        self.alertModule(title:"Error", msg:dic["msg"] as! String)
                        
                    }
                    
                    
                    
                case .failure(let error):
                    print(error)
                     HomeViewController.removeSpinner(spinner: sv)
                    self.alertModule(title:"Error",msg:error.localizedDescription)
                }
                group.leave()
            })
           */
            
            
            group.notify(queue: DispatchQueue.main) {
                
              //  if self.appDelegate.SelectedBtn == 0
              //  {
                    if((self.SearchUserArr.count) > 0){
                        self.filterUserArr.removeAll()
                        for i in 0...(self.SearchUserArr.count)-1{
                            let obj = self.SearchUserArr[i]
                            if obj.first_name.lowercased().range(of:self.SearchText.lowercased()) != nil {
                                
                                self.filterUserArr.append(obj)
                                
                            }
                        }
                    }
                    
                 if((self.SearchVideoArr.count) > 0){
                                self.FilerVideoArr.removeAll()
                                for i in 0...(self.SearchVideoArr.count)-1{
                                    let obj = self.SearchVideoArr[i]
                                    if obj.first_name.lowercased().range(of:self.SearchText.lowercased()) != nil {
                                        
                                        self.FilerVideoArr.append(obj)
                                        
                                    }
                                }
                            }
                
                if((self.sound_array.count) > 0){
                    self.filterSoundArr.removeAll()
                    for i in 0...(self.sound_array.count)-1{
                        let obj = self.sound_array[i]
                        if obj.sound_name.lowercased().range(of:self.SearchText.lowercased()) != nil {
                            
                            self.filterSoundArr.append(obj)
                            
                        }
                    }
                }
                
               
                
                 DispatchQueue.main.async {
                    
                     HomeViewController.removeSpinner(spinner: sv)

                    self.SearchUserTableView.reloadData()
                }
                
            }
            
            
        }
    

    @objc func refresh(sender:AnyObject) {
        loadingToggle = "no"
        self.getVideos()
    }
    
    
    @IBAction func userBtnAction(_ sender: Any) {
        
        //        userBottonView.isHidden = false
        //        audioBottomView.isHidden = true
        //        videoBottomView.isHidden = true
        appDelegate.SelectedBtn = 0
        userBottonView.backgroundColor = .white
        audioBottomView.backgroundColor = .clear
        videoBottomView.backgroundColor = .clear
        
        userBtn.isUserInteractionEnabled = false

        //Execute your code here

        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { [weak userBtn] timer in
            userBtn!.isUserInteractionEnabled = true
        })
        
        
//        if((self.SearchUserArr.count) > 0){
//                  self.filterUserArr.removeAll()
//                  for i in 0...(SearchUserArr.count)-1{
//                      let obj = SearchUserArr[i]
//                      if obj.first_name.lowercased().range(of:self.SearchText.lowercased()) != nil {
//
//                          self.filterUserArr.append(obj)
//
//                      }
//                  }
//              }
                DispatchQueue.main.async {
                           self.SearchUserTableView.reloadData()
                       }
    }
    
    @IBAction func videoBtnAction(_ sender: Any) {
        
        appDelegate.SelectedBtn = 1
        userBottonView.backgroundColor = .clear
        videoBottomView.backgroundColor = .white
        audioBottomView.backgroundColor = .clear
        
          VideoBtn.isUserInteractionEnabled = false
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { [weak VideoBtn] timer in
            VideoBtn?.isUserInteractionEnabled = true
        })

        
        //  searchVideoData()
        
        
       // self.searchVideoData()
        // self.getSounds()
        
                                  
          DispatchQueue.main.async {
                self.SearchUserTableView.reloadData()
                 }
        
        
        
        
        
    }
    
    @IBAction func audioBtnAction(_ sender: Any) {
        
        appDelegate.SelectedBtn = 2
        
        userBottonView.backgroundColor = .clear
        videoBottomView.backgroundColor = .clear
        audioBottomView.backgroundColor = .white
        //searchSoundData()
        
        //  getSounds()
        
        audioBtn.isUserInteractionEnabled = false
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { [weak audioBtn] timer in
                   audioBtn!.isUserInteractionEnabled = true
               })
        
       
          DispatchQueue.main.async {
                     self.SearchUserTableView.reloadData()
                 }
        
        
        
    }
    
    func getSounds(){
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.Search_User!
        //  let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        let parameter1 :[String:Any]? = ["search":self.SearchText, "type":"sound", "middle_name": self.appDelegate.middle_name]
        
//        print(url)
//        print(parameter1!)
        
        let headers1: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
        ]
        
        AF.request(url, method: .post, parameters:parameter1, encoding:JSONEncoding.default, headers:headers1).validate().responseJSON(completionHandler: {
            
            respones in
            
            
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
                
                //HomeViewController.removeSpinner(spinner: sv)
                
                self.sound_array = []
               //  print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        for i in 0...myCountry.count-1{
                            
                            if  let sectionData = myCountry[i] as? NSDictionary
                            {
                                let tempMenuObj = Sound()
                                
                                var tempProductList = SearchSound()
                                
                                if let audio_path = sectionData["audio_path"] as? NSDictionary{
                                    
                                   // print("audio data ===\(audio_path)")
                                    
                                    tempProductList.audio_path = audio_path["acc"] as? String
                                    tempProductList.mpthree = audio_path["mp3"] as? String
                                    
                                    
                                }
                                
                                tempProductList.created = sectionData["created"] as? String
                                tempProductList.description = sectionData["description"] as? String
                                tempProductList.sound_name = sectionData["sound_name"] as? String
                                tempProductList.fav = sectionData["fav"] as? String
                                tempProductList.id = sectionData["id"] as? String
                                tempProductList.section = sectionData["section"] as? String
                                tempProductList.thum = sectionData["thum"] as? String
                                
                                
                                self.sound_array.append(tempProductList)
                                
                                
                                
                            }
                            
                           // print("sound_name data ===\(self.sound_array)")
                            
                        }
                        
                    }
                    
                    if((self.sound_array.count) > 0){
                        self.filterSoundArr.removeAll()
                        for i in 0...(self.sound_array.count)-1{
                            let obj = self.sound_array[i]
                            if obj.sound_name.lowercased().range(of:self.SearchText.lowercased()) != nil {
                                
                                self.filterSoundArr.append(obj)
                                
                            }
                        }
                    }
                    
                    
                    self.SearchUserTableView.reloadData()
                    
                    
                    
                    
                    
                    //                    self.tablview.delegate = self
                    //                   self.tablview.dataSource = self
                    //                  self.tablview.reloadData()
                    //
                    //
                    
                    
                }else{
                    
                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
                
                
            case .failure(let error):
               // print(error)
                // HomeViewController.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
        
        
    }
    
    
    
    func searchSoundData()
    {
        
        //users, video, sound
        
        
        let url1 : String = self.appDelegate.baseUrl!+self.appDelegate.Search_User!
        
        let parameter1 :[String:Any]? = ["search":self.SearchText, "type":"sound", "middle_name": self.appDelegate.middle_name]
        
        //print(url1)
       // print(parameter1!)
        
        let headers1: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
            
        ]
        
        AF.request(url1, method: .post, parameters:parameter1, encoding:JSONEncoding.default, headers:headers1).validate().responseJSON(completionHandler: {
            
            respones in
            
            
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
                
                self.tableview.hideLoading()
                
                self.video_array = []
                self.Newssection = []
                //print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        for i in 0...myCountry.count-1{
                            
                            if  let sectionData = myCountry[i] as? NSDictionary{
                                var tempMenuObj = SearchUser()
                                tempMenuObj.block = sectionData["block"] as? String
                                tempMenuObj.created = sectionData["created"] as? String
                                tempMenuObj.fb_id = sectionData["fb_id"] as? String
                                tempMenuObj.device = sectionData["device"] as? String
                                tempMenuObj.first_name = sectionData["first_name"] as? String ?? "No Name"
                                tempMenuObj.gender = sectionData["gender"] as? String
                                tempMenuObj.last_name = sectionData["last_name"] as? String
                                tempMenuObj.profile_pic = sectionData["profile_pic"] as? String
                                tempMenuObj.signup_type = sectionData["signup_type"] as? String
                                tempMenuObj.username = sectionData["username"] as? String
                                tempMenuObj.verified = sectionData["verified"] as? String
                                tempMenuObj.version = sectionData["version"] as? String
                                tempMenuObj.videos = sectionData["videos"] as? Int ?? 0
                                
                                self.SearchUserArr.append(tempMenuObj)
                            }
                            
                        }
                        
                    }
                    
                    
                    
                    self.refreshControl.endRefreshing()
                    self.SearchUserTableView.delegate = self
                    self.SearchUserTableView.dataSource = self
                    self.SearchUserTableView.reloadData()
                    
                    
                    
                    
                }else{
                    self.refreshControl.endRefreshing()
                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
                
                
            case .failure(let error):
              //  print(error)
                self.refreshControl.endRefreshing()
                self.SearchUserTableView.hideLoading()
                
                //to hide the loader
                
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
            
            
        })
    }
    
    
    func searchVideoData()
    {
        
        //users, video, sound
        
        
        let url1 : String = self.appDelegate.baseUrl!+self.appDelegate.Search_User!
//
        let parameter1 :[String:Any]? = ["search":self.SearchText, "type":"video", "middle_name": self.appDelegate.middle_name]
        
//        print(url1)
//        print(parameter1!)
        
        let headers1: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
            
        ]
        
        AF.request(url1, method: .post, parameters:parameter1, encoding:JSONEncoding.default, headers:headers1).validate().responseJSON(completionHandler: {
            
            respones in
            
            
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
                
                self.tableview.hideLoading()
                
                //self.video_array = []
                //self.Newssection = []
                //print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        for i in 0...myCountry.count-1{
                            if  let dic2 = myCountry[i] as? NSDictionary{
                                //   if  let sectionData = myCountry[i] as? NSDictionary{
                                let tempMenuObj = Discover()
                                //   tempMenuObj.name = sectionData["section_name"] as? String
                                // self.Newssection.add(tempMenuObj.name!)
                                // if let extraData = sectionData["sections_videos"] as? NSArray{
                                
                                // for j in 0...extraData.count-1{
                                // let dic2 = extraData[j] as! [String:Any]
                                
                                var tempProductList = ItemVideo()
                                
                                if let count = dic2["count"] as? NSDictionary{
                                    
                                    tempProductList.like_count = count["like_count"] as? String
                                    
                                    tempProductList.video_comment_count = count["video_comment_count"] as? String
                                }
                                
                                if let user_info = dic2["user_info"] as? NSDictionary{
                                    
                                    tempProductList.first_name = user_info["first_name"] as? String ?? " "
                                    
                                    tempProductList.last_name = user_info["last_name"] as? String
                                    
                                    tempProductList.profile_pic = user_info["profile_pic"] as? String
                                    
                                    tempProductList.u_id = user_info["id"] as? String
                                }
                                
                                
                                tempProductList.video = dic2["video"] as? String
                                tempProductList.thum = dic2["gif"] as? String
                                tempProductList.liked = dic2["liked"] as? String
                                tempProductList.v_id = dic2["id"] as? String
                                tempProductList.description =  dic2["description"] as? String
                                
                                if let sound = dic2["sound"] as? NSDictionary{
                                    
                                    tempProductList.sound_name = sound["sound_name"] as? String
                                    
                                }
                                
                                
                                
                                // tempMenuObj.listOfProducts.append(tempProductList)
                                
                                //}
                                
                                // }
                                
                                self.SearchVideoArr.append(tempProductList)
                            }
                            
                        }
                        
                    }
                    
                    if((self.SearchVideoArr.count) > 0){
                        self.FilerVideoArr.removeAll()
                        for i in 0...(self.SearchVideoArr.count)-1{
                            let obj = self.SearchVideoArr[i]
                            if obj.first_name.lowercased().range(of:self.SearchText.lowercased()) != nil {
                                
                                self.FilerVideoArr.append(obj)
                                
                            }
                        }
                    }
                    
                    
                    self.SearchUserTableView.reloadData()
                    
                    
                    
                    
                }else{
                    // self.refreshControl.endRefreshing()
                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
                
                
                
            case .failure(let error):
               // print(error)
                //  self.refreshControl.endRefreshing()
                //self.SearchUserTableView.hideLoading()
                
                //to hide the loader
                
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
            
            
        })
    }
    
    
    
    // tableview Delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if  tableView ==  SearchUserTableView
        {
            if  appDelegate.SelectedBtn == 0
            {
                
                if self.filterUserArr.count > 0
                {
                    self.SearchUserTableView.restore()
                    
                     return self.filterUserArr.count
                }
                else {
                    self.SearchUserTableView.setEmptyMessage("No Record Found")
                  //  no_Data_IMG.isHidden = false
                     return 0
                }
               
            }
            else if appDelegate.SelectedBtn == 1
            {
                if self.FilerVideoArr.count > 0
                {
                   self.SearchUserTableView.restore()
                   return self.FilerVideoArr.count
                   
                }
                else {
                     self.SearchUserTableView.setEmptyMessage("No Record Found")
                 //   no_Data_IMG.isHidden = false

                       return 0
                }
                
            }
            else
            {
                if self.filterSoundArr.count > 0
                {
                    self.SearchUserTableView.restore()
                    return self.filterSoundArr.count
                }
                else {
                    self.SearchUserTableView.setEmptyMessage("No Record Found")
                    //no_Data_IMG.isHidden = false

                     return 0
                   
                }
                
            }
            
        }
        else if tableview == tableView
        {
           if  video_array.count > 0
           {
              return video_array.count
            }
            else
           {
             return 0
            }
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell1 = UITableView.dequeueReusableCell(withIdentifier: UITableView)
        
        
        
        if tableView == SearchUserTableView
        {
            let cell = self.SearchUserTableView.dequeueReusableCell(withIdentifier: "SearchUserCell") as! SearchUserCell
             cell.contentView.backgroundColor = UIColor(displayP3Red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0, alpha: 1)
            
            if appDelegate.SelectedBtn == 0
                
            {
                if let obj = self.filterUserArr[safe : indexPath.row]
               {
                
                
                cell.nameLbl.text = obj.first_name + " " + obj.last_name
                cell.userNameLbl.text = obj.username
                cell.videoLbl.text = "\(obj.videos) (Videos)"
                
                cell.profileImageView.layer.cornerRadius = (cell.profileImageView?.frame.size.width ?? 0.0) / 2
                cell.profileImageView.clipsToBounds = true
                cell.profileImageView.layer.borderWidth = 3.0
                cell.profileImageView.layer.borderColor = UIColor.black.cgColor
                
                cell.profileImageView.sd_setImage(with: URL(string:obj.profile_pic), placeholderImage: UIImage(named:"nobody_m.1024x1024"))
                
                
                }
                return cell
                
            }
            else if  appDelegate.SelectedBtn == 1
                
            {
                
                let cell:SearchVideoCell = self.SearchUserTableView.dequeueReusableCell(withIdentifier: "SearchVideoCell") as! SearchVideoCell
                 cell.contentView.backgroundColor = UIColor(displayP3Red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0, alpha: 1)
               if let obj = self.FilerVideoArr[safe : indexPath.row]
                
               {
                cell.name1Lbl.text =  obj.first_name + " " + obj.last_name
                cell.desc1Lbl.text = obj.description
                cell.profile1ImageView.sd_setImage(with: URL(string:obj.thum), placeholderImage: UIImage(named:"nobody_m.1024x1024"))
                
                cell.watch1Btn.tag = indexPath.row
                 cell.watch1Btn.addTarget(self, action: #selector(DiscoverViewController.connected222(_:)), for:.touchUpInside)
                
                // cell.select_btn.addTarget(self, action: #selector(DiscoverViewController.connected1(_:)), for:.touchUpInside)
                
                
                }
                
                
                return cell
                
            }
            else if  appDelegate.SelectedBtn == 2
                
            {
                
                let cell:SoundTableViewCell = self.SearchUserTableView.dequeueReusableCell(withIdentifier: "cell02") as! SoundTableViewCell
                cell.contentView.backgroundColor = UIColor(displayP3Red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0, alpha: 1)
                //if(self.isDisCover == "yes"){
                if let obj:SearchSound = filterSoundArr[safe : indexPath.row]
                {
                
                
                
                cell.sound_name.text = obj.sound_name
                cell.sound_type.text = obj.description
                cell.sound_img.sd_setImage(with: URL(string:obj.thum), placeholderImage: UIImage(named:"ic_music"))
                
                //cell.btn_favourites.tag = [indexPath
                cell.btn_favourites.addTarget(self, action: #selector(DiscoverViewController.connected(_:)), for:.touchUpInside)
                
                cell.select_btn.addTarget(self, action: #selector(DiscoverViewController.connected1(_:)), for:.touchUpInside)
                
                cell.select_btn.tag = indexPath.row
                
                cell.btn_favourites.alpha = 1
                
                cell.innerview.layer.masksToBounds = false
                
                cell.innerview.layer.cornerRadius = 4
                cell.innerview.clipsToBounds = true
                
                cell.outerview.layer.masksToBounds = false
                
                cell.outerview.layer.cornerRadius = 4
                cell.outerview.clipsToBounds = true
                
                cell.select_view.layer.masksToBounds = false
                
                cell.select_view.layer.cornerRadius = 4
                cell.select_view.clipsToBounds = true
                
                }
                
                return cell
            }
            else {
                
                 return UITableViewCell()
            }
        }

        else if tableview == tableView
        {
            let cell:dicoverTableCell = self.tableview.dequeueReusableCell(withIdentifier: "ditaCell") as! dicoverTableCell
            
            if(self.searchActive == true){
                
                let obj = self.filtered[indexPath.row]
                cell.dis_label.text =  "#" + obj.name
                cell.dis_label.font = UIFont(name:"Poppins-BoldItalic",size:17)
                cell.lblVideoCount.text = "\(obj.totalView) " + "Views"
                var hasgtagImg = obj.hashtagIcon
                var data = try? Data(contentsOf: URL(string: hasgtagImg)!)
                cell.hashtag_Img.image = UIImage(data: data!)
//                cell.lblVideoCount.text = "\(obj.view_count)" + "Views"
                cell.viewAll_Btn.tag = indexPath.row
                
                if obj.listOfProducts.count > 3{
                    cell.viewAll_Btn.isHidden = false
                }else{
                    cell.viewAll_Btn.isHidden = true
                }
                 cell.viewAll_Btn.addTarget(self, action: #selector(DiscoverViewController.onTapViewAll(_:)), for:.touchUpInside)
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .horizontal
                layout.minimumLineSpacing = 5
                layout.minimumInteritemSpacing = 5
                layout.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
                
                cell.collectionview.collectionViewLayout = layout
                cell.collectionview.dataSource = self
                cell.collectionview.delegate = self
                cell.collectionview.reloadData()
                cell.collectionview.tag = indexPath.row
                
            }else{
                
                let obj = self.video_array[indexPath.row]
                cell.dis_label.text =  "#" + obj.name
                cell.dis_label.font = UIFont(name:"Poppins-BoldItalic",size:17)
               // cell.lblVideoCount.text = "\(obj.listOfProducts.count)"
                cell.lblVideoCount.text = "\(obj.totalView) " + "Views"
                var hasgtagImg = obj.hashtagIcon
//                var data = try? Data(contentsOf: URL(string: hasgtagImg)!)
//                cell.hashtag_Img.image = UIImage(data: data!)
                cell.viewAll_Btn.tag = indexPath.row
                
                if obj.listOfProducts.count > 3{
                    
                    cell.viewAll_Btn.isHidden = false
                    
                }else{
                    
                    cell.viewAll_Btn.isHidden = true
                }
                cell.viewAll_Btn.addTarget(self, action: #selector(DiscoverViewController.onTapViewAll(_:)), for:.touchUpInside)
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .horizontal
                layout.minimumLineSpacing = 5
                layout.minimumInteritemSpacing = 5
                layout.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
                
                cell.collectionview.collectionViewLayout = layout
                cell.collectionview.dataSource = self
                cell.collectionview.delegate = self
                cell.collectionview.reloadData()
                cell.collectionview.tag = indexPath.row
            
            }
            return cell
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView ==  SearchUserTableView
        {
            return 70
        }
        else
        {
            return 220
        }
        
    }
    
    func numSections(in contentLoaderView: UIView) -> Int {
        return 1
    }
    
    // Number of rows you would like to show in loader
    func contentLoaderView(_ contentLoaderView: UIView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    /// Cell reuse identifier you would like to use (ContenLoader will search loadable objects here!)
    func contentLoaderView(_ contentLoaderView: UIView, cellIdentifierForItemAt indexPath: IndexPath) -> String {
        return "ditaCell"
    }
    
    // Collectionview Delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        if(searchActive == true){
//
//            return self.filtered[collectionView.tag].listOfProducts.count
//        }else{
            
            return self.video_array[collectionView.tag].listOfProducts.count
       // }
        
    
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:discoverCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "dicocell", for: indexPath) as! discoverCollectionCell
        
//        if(self.searchActive == true){
//            let obj:ItemVideo = filtered[collectionView.tag].listOfProducts[indexPath.row]
//            cell.tik_img.layer.masksToBounds = false
//            cell.tik_img.layer.cornerRadius = 4
//            cell.tik_img.clipsToBounds = true
//            cell.tik_img.sd_setImage(with: URL(string:obj.thum), placeholderImage: UIImage(named:"Spinner-1s-200px.gif"))
//
//        }else{
            let obj:ItemVideo = video_array[collectionView.tag].listOfProducts[indexPath.row]
            
            cell.tik_img.layer.masksToBounds = false
            cell.tik_img.layer.cornerRadius = 4
            cell.tik_img.clipsToBounds = true
//            cell.contentView.setGradientBackgroundImage(colorTop: UIColor.clear, colorBottom: UIColor(displayP3Red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1))
//            cell.tik_img.setGradientBackgroundImage(colorTop: UIColor.clear, colorBottom: UIColor(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1))
            cell.tik_img.sd_setImage(with: URL(string:obj.thum), placeholderImage: UIImage(named:"Spinner-1s-200px.gif"))
       // }
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.SearchUserTableView.cellForRow(at: indexPath) as? SoundTableViewCell
        
        if tableView == self.SearchUserTableView
        {
            if appDelegate.SelectedBtn == 0
            {
                 let obj = self.filterUserArr[indexPath.row]
                
                if(obj.fb_id != UserDefaults.standard.string(forKey: "uid")!){
                      
                      StaticData.obj.other_id = obj.fb_id
                          
                          let storyboard = UIStoryboard(name: "Main", bundle: nil)
                          let yourVC: Profile1ViewController = storyboard.instantiateViewController(withIdentifier: "Profile1ViewController") as! Profile1ViewController
                          
                    self.navigationController?.pushViewController(yourVC, animated: true)
                      }else{
                          
                         // self.tabBarController?.selectedIndex = 3
                      }
            }
            else if appDelegate.SelectedBtn == 1
            {
                let obj = self.FilerVideoArr[indexPath.row]
                
                if(obj.u_id != UserDefaults.standard.string(forKey: "uid")!){
                    
                    StaticData.obj.other_id = obj.u_id
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let yourVC: Profile1ViewController = storyboard.instantiateViewController(withIdentifier: "Profile1ViewController") as! Profile1ViewController
                    
                   self.navigationController?.pushViewController(yourVC, animated: true)
                }else{
                    // self.tabBarController?.selectedIndex = 3
                }
                
                
            }
            
           else  if appDelegate.SelectedBtn == 2
            {
                if let obj = self.filterSoundArr[indexPath.row] as? SearchSound
                {
                
                if cell?.btn_play.tag == 1001 {
                    
                    UserDefaults.standard.set(obj.id, forKey: "sid")
                    
                    cell?.btn_play.image = UIImage(named: "ic_pause_icon")
                    cell?.btn_play.tag = 1002
                   if let url = obj.audio_path
                   {
                    let playerItem = AVPlayerItem( url:NSURL( string:url )! as URL )
                    player = AVPlayer(playerItem:playerItem)
                    player.rate = 1.0;
                    cell?.select_view.alpha = 1
                    cell?.select_btn.alpha = 1
                    
                    player.play()
                    }
                }else{
                    cell?.btn_play.image = UIImage(named: "ic_play_icon")
                    cell?.btn_play.tag = 1001
                    cell?.select_view.alpha = 0
                    cell?.select_btn.alpha = 0
                    player.pause()
                }
                }
                
            }
            
        }
        else if tableview == tableView
        {
           
            
            
            
            
        }
        

    }
    
    
    
    //    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //
    //        if(self.searchActive == true){
    //
    //            let obj =  self.filtered[collectionView.tag].listOfProducts[indexPath.row]
    //            UserDefaults.standard.set(obj.video, forKey: "dis_url")
    //            UserDefaults.standard.set(obj.thum, forKey: "dis_img")
    //            StaticData.obj.userName = "@"+obj.first_name
    //            StaticData.obj.userImg = obj.profile_pic
    //            StaticData.obj.liked = obj.liked
    //            StaticData.obj.comment_count = obj.video_comment_count
    //            StaticData.obj.like_count = obj.like_count
    //            StaticData.obj.soundName = obj.sound_name
    //            StaticData.obj.videoID = obj.v_id
    //            StaticData.obj.other_id = obj.u_id
    //
    //            DispatchQueue.main.async {
    //
    //                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverVideoViewController") as! DiscoverVideoViewController
    //
    //                self.present(vc, animated: true, completion: nil)
    //            }
    //        }else{
    //            let obj =  self.video_array[collectionView.tag].listOfProducts[indexPath.row]
    //            UserDefaults.standard.set(obj.video, forKey: "dis_url")
    //            UserDefaults.standard.set(obj.thum, forKey: "dis_img")
    //            StaticData.obj.userName = obj.first_name+" "+obj.last_name
    //            StaticData.obj.userImg = obj.profile_pic
    //            StaticData.obj.liked = obj.liked
    //            StaticData.obj.comment_count = obj.video_comment_count
    //            StaticData.obj.like_count = obj.like_count
    //            StaticData.obj.soundName = obj.sound_name
    //            StaticData.obj.videoID = obj.v_id
    //            StaticData.obj.other_id = obj.u_id
    //            DispatchQueue.main.async {
    //                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverVideoViewController") as! DiscoverVideoViewController
    //                self.present(vc, animated: true, completion: nil)
    //            }
    //        }
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        //return CGSize(width: collectionView.layer.frame.width / 4, height:  collectionView.layer.frame.width / 4)
         
        return CGSize(width: collectionView.layer.frame.width / 4, height:  130)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,left: 7,bottom: 0,right: 7)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc: DiscoverCategoriesVC = storyboard.instantiateViewController(withIdentifier: "DiscoverCategoriesVC") as! DiscoverCategoriesVC
    
        
//        if indexPath.row > 0{
//            let range = 0...(indexPath.row - 1)
//            video_array[indexPath.section].listOfProducts.removeSubrange(range)
//        }
//        vc.friends_array = video_array[indexPath.section].listOfProducts
        
 //       self.navigationController?.pushViewController(vc, animated: true)
        
    
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: DiscoverVideoViewController = storyboard.instantiateViewController(withIdentifier: "DiscoverVideoViewController") as! DiscoverVideoViewController
//        if indexPath.row > 0{
//            let range = 0...(indexPath.row - 1)
//            self.allVideos.removeSubrange(range)
//        }
//        vc.friends_array = self.allVideos
        vc.position = indexPath.row
        vc.fbId = UserDefaults.standard.string(forKey: "uid") ?? ""
        vc.videoId = self.video_array[indexPath.section].listOfProducts[indexPath.row].v_id
        vc.type = "discover"
        vc.sectionId = self.video_array[indexPath.section].section_Id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // search bar delegate methods
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        searchActive = false;
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        
        searchBar.text = ""
        searchActive = false;
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        
        self.searchView.isHidden = true
        // self.discoverView.isHidden = false
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchActive = false;
        
        self.searchView.isHidden = false
        
        sendDataToServer()
        
        
        // self.discoverView.isHidden = true
        
        //self.filterUserArr.removeAll()
        
        self.view.endEditing(true)
        
        //             userBottonView.backgroundColor = .red
        //             audioBottomView.backgroundColor = .clear
        //             videoBottomView.backgroundColor = .clear
        
      
        
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        
        searchBar.showsCancelButton = true
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       // filtered = []
        searchActive = true;
        
        self.SearchText = searchText
        
        
        
      //  print("filterArr --- \(self.filterUserArr)")
        
        
        //filterUserArr
        
        
        
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
      //  self.tableview.reloadData()
        
    }
    
    
    
    
    
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    @objc func connected222(_ sender : UIButton) {
       // print(sender.tag)
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.SearchUserTableView)
               let indexPath = self.SearchUserTableView.indexPathForRow(at:buttonPosition)
               let cell = self.SearchUserTableView.cellForRow(at: indexPath!) as! SearchVideoCell
        
        
            let obj = self.FilerVideoArr[indexPath!.row]
        
                     UserDefaults.standard.set(obj.video, forKey: "dis_url")
                     UserDefaults.standard.set(obj.thum, forKey: "dis_img")
                     StaticData.obj.userName = obj.first_name+" "+obj.last_name
                     StaticData.obj.userImg = obj.profile_pic
                     StaticData.obj.liked = obj.liked
                     StaticData.obj.comment_count = obj.video_comment_count
                     StaticData.obj.like_count = String(obj.like_count)
                     StaticData.obj.soundName = obj.sound_name
                     StaticData.obj.videoID = obj.v_id
                     StaticData.obj.other_id = obj.u_id
                     DispatchQueue.main.async {
                         
                         let vc = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverVideoViewController") as! DiscoverVideoViewController
//                         vc.audioTitle = obj.f_name + "" + obj.last_name
//                         vc.audioString = obj.audio_url
//                         vc.soundId = obj.s_id ?? "null"
//                         vc.videoImg = obj.thum
//                         vc.desc = obj.description
//                         vc.videoId = obj.v_id
                     
                         self.navigationController?.pushViewController(vc, animated: true)
                     
                 }
        
    }
    
    @objc func connected(_ sender : UIButton) {
      //  print(sender.tag)
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.SearchUserTableView)
        let indexPath = self.SearchUserTableView.indexPathForRow(at:buttonPosition)
        let cell = self.SearchUserTableView.cellForRow(at: indexPath!) as! SoundTableViewCell
        let obj:SearchSound = sound_array[indexPath!.row]
        
        
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.fav_sound!
        
        let favoutite = "1"
        //        if obj.fav == "0"
        //        {
        //            favoutite = "1"
        //        }
        //        else
        //        {
        //            favoutite = "0"
        //
        //        }
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"sound_id":obj.id!,"fav":favoutite, "middle_name": self.appDelegate.middle_name]
        
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
                
                
               // print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    cell.btn_favourites.setBackgroundImage(UIImage(named:"7"), for: .normal)
                    
                }else{
                    
                    
                    
                }
                
            case .failure(let error):
                print(error)
                //cell.btn_favourites.setBackgroundImage(UIImage(named:"7"), for: .normal)
            }
        })
        
    }
    
    @objc func connected1(_ sender : UIButton) {
       // print(sender.tag)
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.SearchUserTableView)
        let indexPath = self.SearchUserTableView.indexPathForRow(at:buttonPosition)
        
        //  if(self.isDisCover == "yes"){
        let obj:SearchSound = self.filterSoundArr[indexPath!.row]
        
        UserDefaults.standard.set(obj.audio_path, forKey: "url")
        UserDefaults.standard.set(obj.audio_path, forKey: "audioUrl")
        UserDefaults.standard.set(obj.sound_name, forKey: "sound_name")
       // UserDefaults.standard.set(obj.id, forKey: "sid")
        
        if let audioUrl = URL(string: obj.audio_path) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
         //   print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
        self.dismiss(animated:true, completion: nil)
    }
    
    @objc func onTapViewAll(_ sender: UIButton) {
        print(sender.tag)
       
        let obj:Discover = video_array[sender.tag]
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: AllDiscoverVideoVC = storyboard.instantiateViewController(withIdentifier: "AllDiscoverVideoVC") as! AllDiscoverVideoVC
            vc.hashtagname = obj.name
            vc.hashtagIcon = obj.hashtagIcon
            vc.hashtagCount = obj.totalView
            vc.sectionId = obj.section_Id
            self.navigationController?.pushViewController(vc, animated: true)
        }
}

extension UIImageView {
    public func maskCircle(anyImage: UIImage) {
        self.contentMode = UIView.ContentMode.scaleAspectFill
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        
        // make square(* must to make circle),
        // resize(reduce the kilobyte) and
        // fix rotation.
        self.image = anyImage
    }
}

extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
