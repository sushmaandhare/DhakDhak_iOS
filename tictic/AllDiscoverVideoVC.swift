//
//  AllDiscoverVideoVC.swift
//  TIK TIK
//
//  Created by Apple on 12/10/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit
import AVKit
import Alamofire

class AllDiscoverVideoVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var hashtag_Name: UILabel!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var total_ViewCount: UILabel!
    
    var hashtagname = ""
    var hashtagIcon = ""
    var hashtagCount = ""
    
    @IBOutlet weak var HASHTAG_iCON: UIImageView!
    // var allVideos : Discover!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var video_array =  [ItemVideo]()
    var sectionId : String!
    var offset : Int? = 0
    var index:Int! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        total_ViewCount.text = "\(hashtagCount) " + "Views"
        var data = try? Data(contentsOf: URL(string: hashtagIcon)!)
        HASHTAG_iCON.image = UIImage(data: data!)
        hashtag_Name.text = " #\(hashtagname)"
        hashtag_Name.font = UIFont(name:"Poppins-BoldItalic",size:17)

        self.navigationController?.navigationBar.isHidden = true
        let bottomRefreshController = UIRefreshControl()
        bottomRefreshController.triggerVerticalOffset = 50
        bottomRefreshController.addTarget(self, action: #selector(self.refreshBottom), for: .valueChanged)
        collectionview.bottomRefreshControl = bottomRefreshController
        collectionview.isPagingEnabled =  true
       
    }
    
    //MARK: Back button click
    @IBAction func back_Click(_ sender: Any) {
     
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Refresher bottom
    @objc func refreshBottom() {
        print("refresh")
        updateNextSet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.isHidden =  false
        self.video_array.removeAll()
        getVideos(offset: self.offset)
    }
    
    // Collectionview Deleagte methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return video_array.count ?? 0
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:DiscoverAllVideoCell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "DiscoverAllVideoCell", for: indexPath) as! DiscoverAllVideoCell
  
//        cell.contentView.setGradientBackgroundImage(colorTop: UIColor.clear, colorBottom: UIColor(displayP3Red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1))
//        cell.video_image.setGradientBackgroundImage(colorTop: UIColor.clear, colorBottom: UIColor(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1))
        let obj = video_array[indexPath.row]
        cell.btnPlay.tag = indexPath.item
        let viewobj = obj.view_count
        cell.view_Count_Lbl.text = viewobj
        cell.video_image.sd_setImage(with: URL(string:obj.thum ?? ""), placeholderImage: UIImage(named:"Spinner-1s-200px.gif"))
        cell.btnPlay.addTarget(self, action: #selector(AllDiscoverVideoVC.onTapPlay(_:)), for:.touchUpInside)
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc: DiscoverCategoriesVC = storyboard.instantiateViewController(withIdentifier: "DiscoverCategoriesVC") as! DiscoverCategoriesVC
//        if indexPath.row > 0{
//            let range = 0...(indexPath.row - 1)
//            video_array.removeSubrange(range)
//        }
//        vc.friends_array = video_array
//        self.navigationController?.pushViewController(vc, animated: true)
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: DiscoverVideoViewController = storyboard.instantiateViewController(withIdentifier: "DiscoverVideoViewController") as! DiscoverVideoViewController
//        if indexPath.row > 0{
//            let range = 0...(indexPath.row - 1)
//            self.allVideos.removeSubrange(range)
//        }
//        vc.friends_array = self.allVideos
        vc.fbId = UserDefaults.standard.string(forKey: "uid") ?? ""
        vc.videoId = self.video_array[indexPath.row].v_id
        vc.type = "discover"
        vc.sectionId = self.sectionId
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
    }
//
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row >= (video_array.count) {  //numberofitem count
            updateNextSet()
        }
    }

    
    
    
    func updateNextSet(){
        self.offset =  self.offset! + 15
        self.getVideos(offset: self.offset)
           //requests another set of data (20 more items) from the server.
    }
    
    @objc func onTapPlay(_ sender: UIButton) {
//        draftArr.remove(at: sender.tag)
//        let draftData = NSKeyedArchiver.archivedData(withRootObject: draftArr)
//         UserDefaults.standard.set(draftData, forKey: "Draft")
//        collectionview.reloadData()
    }
    
    
    //MARK: GET VIDEOS
    func getVideos(offset:Int?)
    {
        
        let url  : String = self.appDelegate.baseUrl!+self.appDelegate.discover_details
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name, "offset":String(offset ?? 0), "section_id": sectionId!]
//        print(url)
//        print(parameter!)
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
        ]
        
        AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
              // self.video_array = []
                
              //  print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    HomeViewController.removeSpinner(spinner: sv)
                    self.collectionview.bottomRefreshControl?.endRefreshing()
                    if let myCountry = dic["msg"] as? NSArray{
                        for i in 0...myCountry.count-1{
                            
                            if  let sectionData = myCountry[i] as? NSDictionary{
                              
                                var tempMenuObj = Discover()
                                tempMenuObj.name = sectionData["section_name"] as? String
                           //     self.Newssection.add(tempMenuObj.name!)
                              
                                if let extraData = sectionData["sections_videos"] as? NSArray{
                                    
                                    for j in 0...extraData.count-1{
                                        let dic2 = extraData[j] as! [String:Any]
                                        
                                        var tempProductList = ItemVideo()
                                        
                                        if let count = dic2["count"] as? NSDictionary{
//                                            tempProductList.description = dic2["description"] as! String
//                                            tempProductList.like_count = count["like_count"] as? String
//
//                                            tempProductList.video_comment_count = count["video_comment_count"] as? String
                                            
                                            tempProductList.view_count = count["view"] as? String
                                            
                                       //     tempProductList.share = count["share"] as? String
                                        }
                                        
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
                                        
                                        
                                        tempProductList.thum = dic2["thum"] as? String
                                      //  tempProductList.liked = dic2["liked"] as? String
                                        tempProductList.v_id = dic2["id"] as? String
                                        
//                                        if let sound = dic2["sound"] as? NSDictionary{
//                                            let audio_patha = sound["audio_path"] as! NSDictionary
//                                            tempProductList.sound_name = sound["sound_name"] as? String
//                                             tempProductList.audio_url = audio_patha["acc"] as! String
//                                             tempProductList.s_id = sound["id"] as? String
//                                        }
                                        
                                        self.video_array.append(tempProductList)
                                        
                                    }
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                    
                   
                    self.title = "#" + (self.hashtagname)
                    self.collectionview.reloadData()
                    
                }else{
                    HomeViewController.removeSpinner(spinner: sv)
                    if Reachability.isConnectedToNetwork() == false{
                  //     self.alertModule(title:"Network Issue", msg: "Internet connection appears to be offline. Please try again later.")
                    }else{
                    //     self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    }
                }
                
            case .failure(let error):
                HomeViewController.removeSpinner(spinner: sv)
                if Reachability.isConnectedToNetwork() == false{
               //   self.alertModule(title:"Network Issue",msg: "No Internet Connection")
                }else{
               //   self.alertModule(title:"Error",msg:error.localizedDescription)
                }
            }
        })
    }
    
}

extension UIView{
    
    func setGradientBackgroundImage(colorTop: UIColor, colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
