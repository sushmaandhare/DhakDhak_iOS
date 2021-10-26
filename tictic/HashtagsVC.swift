//
//  HashtagsVC.swift
//  TIK TIK
//  Created by MacBook Air on 28/11/1942 Saka.
//  Copyright © 1942 Rao Mudassar. All rights reserved.

import UIKit
import Alamofire

class HashtagsVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var hahstag_Icon: UIImageView!
    
    @IBOutlet weak var total_View: UILabel!
    
    @IBOutlet weak var hashtag_Video_CollectionView: UICollectionView!
    @IBOutlet weak var hashTag_Title: UILabel!
    @IBOutlet weak var hasgtag_Name_Lbl: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var hashTagVideoData = [Videos]()
    var fbid = ""
    var selectedHashtag : String = ""
    var offset : Int? = 0
    var sound_array:NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hasgtag_Name_Lbl.text = selectedHashtag
        hasgtag_Name_Lbl.font = UIFont(name:"Poppins-BoldItalic",size:17)

        fbid = UserDefaults.standard.string(forKey: "uid") ?? " "
        print(fbid)
        
//        hashTag_Title.text = selectedHashtag
 
        let bottomRefreshController = UIRefreshControl()
     bottomRefreshController.triggerVerticalOffset = 50
     bottomRefreshController.addTarget(self, action: #selector(self.refreshBottom), for: .valueChanged)
     hashtag_Video_CollectionView.bottomRefreshControl = bottomRefreshController
     hashtag_Video_CollectionView.isPagingEnabled =  true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hashTagVideoData = []
        getHashtagVideoList(offset: self.offset!)
    }
    //MARK: Refresher bottom
       @objc func refreshBottom() {
           print("refresh")
           updateNextSet()
       }
    
    //MARK: GET Hashtag data
    
    func getHashtagVideoList(offset:Int){
        let sv = HomeViewController.displaySpinner(onView: self.view)
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.SearchByHashTag
        let parameter1 :[String:Any] = ["tag": selectedHashtag, "token":UserDefaults.standard.string(forKey:"DeviceToken")!, "middle_name": self.appDelegate.middle_name, "fb_id":fbid,"offset":offset]
        print(parameter1)
        
        let headers1: HTTPHeaders = [
        "api-key": "4444-3333-2222-1111"
        ]
        AF.request(url, method: .post, parameters:parameter1, encoding:JSONEncoding.default, headers:headers1).validate().responseJSON(completionHandler: {
            respones in
            // print(respones)
            switch respones.result {
            case .success( let value):
                HomeViewController.removeSpinner(spinner: sv)
                self.hashtag_Video_CollectionView.bottomRefreshControl?.endRefreshing()
                let json = value
                print("hashtagJSON --- \(json)")
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                  //  var data = dic["msg"] as! [AnyObject]
                    let myCountry = (dic["msg"] as? [[String:Any]])!
                    var cout = dic["hashtag_view_count"] as! String
                    self.total_View.text = cout + " " + "Views"
                   // self.hashTagVideoData.append(contentsOf: data)
                    
   //                 print("video count",myCountry.count)
                    for Dict in myCountry {
                    
                        let myRestaurant = Dict as NSDictionary
                        
                        let count = myRestaurant["count"] as! NSDictionary
                       // let Username = myRestaurant["user_info"] as! NSDictionary
//                        let sound = myRestaurant["sound"] as! NSDictionary
//                        let sound_id = sound["id"] as? String
//                        let audio_patha = sound["audio_path"] as! NSDictionary
//                        let audio_path:String! =   audio_patha["acc"] as? String
//                        let obj1 = SoundObj(sound_id: sound_id, audioUrl: audio_path)
//                        self.sound_array.add(obj1)
                        
//                        let shareCount = count["share_count"] as? String
//                        let like_count = count["like_count"] as? String
                        
                      //  let video_comment_count = count["video_comment_count"] as? String
                        let view_count = count["view"] as? String
                        
                       // let sound_name = sound["sound_name"] as? String
                      //  let video_url:String! =   myRestaurant["video"] as? String
//                        let video_url = "https://www.radiantmediaplayer.com/media/big-buck-bunny-360p.mp4"
                        
                        let u_id:String! =   myRestaurant["fb_id"] as? String
                        let v_id:String! =   myRestaurant["id"] as? String
                        let thum:String! =   myRestaurant["thum"] as? String
//                        let first_name:String! =   Username["username"] as? String
//                        let last_name:String! =   Username["last_name"] as? String
//                        let profile_pic:String! =   Username["profile_pic"] as? String
                     //   let like:String! =   myRestaurant["liked"] as? String
                     //   let isFollow:Int! = Dict["is_follow"] as! Int
                     //   let desc:String! =   myRestaurant["description"] as? String
//                        let f_name:String! =   Username["first_name"] as? String
//                        let verification : Int! =   Username["verified"] as? Int
//                        let allow_comment:String! =   myRestaurant["allow_comments"] as? String
//                        let allow_duet:String! =   myRestaurant["allow_duet"] as? String
                    //    print("is follow",isFollow)
                      //  let obj = Home(like_count: like_count, video_comment_count: video_comment_count, sound_name: sound_name,thum: thum, first_name: first_name, last_name: last_name,profile_pic: profile_pic, video_url: video_url, v_id: v_id, u_id: u_id, like: like, desc: desc, f_name: f_name, view_count: view_count, verified: verification, allow_comment: allow_comment, allow_duet: allow_duet, isFollow: isFollow, share_count: shareCount)
                        let obj = Videos(thum: thum, first_name: "", last_name: "", profile_pic: "",v_id: v_id, view: view_count, u_id: u_id, approve_status: "0", video: "")
                  
                        self.hashTagVideoData.append(obj)
                        
                    }
                    self.hashtag_Video_CollectionView.reloadData()
                }else{
                }
            case .failure(let error):
                print(error)
                HomeViewController.removeSpinner(spinner: sv)
            }
        })
    }
    
    //MARK: Bck button click action
    @IBAction func back_ButtomCliked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Collectionview delagates method
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         
        return hashTagVideoData.count
       }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = hashtag_Video_CollectionView.dequeueReusableCell(withReuseIdentifier: "HashTagCollectionViewCell", for: indexPath) as! HashTagCollectionViewCell
//         cell.contentView.setGradientBackgroundImage(colorTop: UIColor.clear, colorBottom: UIColor(displayP3Red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1))
//        cell.hashTagVideo_Img.setGradientBackgroundImage(colorTop: UIColor.clear, colorBottom: UIColor(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1))
//         cell.hashTagVideo_Img.layer.masksToBounds = false
//         cell.hashTagVideo_Img.layer.cornerRadius = 4
//         cell.hashTagVideo_Img.clipsToBounds = true
        let dict = self.hashTagVideoData[indexPath.item]
       
        cell.view_Count_Lbl.text = dict.view
        cell.hashTagVideo_Img.sd_setImage(with: URL(string:dict.thum), placeholderImage: UIImage(named:"Spinner-1s-200px.gif"))
        return cell
       }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//         let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//         let vc: DiscoverVideoViewController = storyboard.instantiateViewController(withIdentifier: "DiscoverVideoViewController") as! DiscoverVideoViewController
//         if indexPath.row > 0{
//             let range = 0...(indexPath.row - 1)
//             self.hashTagVideoData.removeSubrange(range)
//         }
//         vc.friends_array = self.hashTagVideoData
//     
//         self.navigationController?.pushViewController(vc, animated: true)
         
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: DiscoverVideoViewController = storyboard.instantiateViewController(withIdentifier: "DiscoverVideoViewController") as! DiscoverVideoViewController
//        if indexPath.row > 0{
//            let range = 0...(indexPath.row - 1)
//            self.allVideos.removeSubrange(range)
//        }
//        vc.friends_array = self.allVideos
        vc.fbId = ""
        vc.videoId = self.hashTagVideoData[indexPath.row].v_id
        vc.type = "hashtag"
        vc.sectionId = self.selectedHashtag
        self.navigationController?.pushViewController(vc, animated: true)
     }
   
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let noOfCellsInRow = 3
//
//        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//
//        let totalSpace = flowLayout.sectionInset.left
//            + flowLayout.sectionInset.right
//            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
//
//        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
//
//        return CGSize(width: size, height: 120)
// //        return CGSize(width: collectionView.layer.frame.width / 3, height:  collectionView.layer.frame.width / 3)
//
//    }
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
        return UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 5
//    }
        
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
          if indexPath.row >= hashTagVideoData.count {  //numberofitem count
            print("next update call")
              updateNextSet()
          }
      }

    //MARK: Update next set
     func updateNextSet(){
          self.offset =  self.offset! + 15
          self.getHashtagVideoList(offset: self.offset ?? 0)
             //requests another set of data (20 more items) from the server.
      }
}
