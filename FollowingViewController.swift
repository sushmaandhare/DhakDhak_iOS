//
//  FollowingViewController.swift
//  TIK TIK
//
//  Created by Rao Mudassar on 30/06/2020.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class FollowingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var outer_view: UIView!
    
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var Follow_Array:NSMutableArray = []
    var fbId = ""
    var offset : Int? = 0
    var totalCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = true
        self.tableview.tableFooterView = UIView()
        
        let bottomRefreshController = UIRefreshControl()
        bottomRefreshController.triggerVerticalOffset = 50
        bottomRefreshController.addTarget(self, action: #selector(self.refreshBottom), for: .valueChanged)
        tableview.bottomRefreshControl = bottomRefreshController
        tableview.isPagingEnabled =  true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.getFolowes(offset: self.offset)
    }
    
    //MARK: Refresher bottom
      @objc func refreshBottom() {
         // print("refresh")
       if totalCount == Follow_Array.count{
           self.tableview.bottomRefreshControl?.endRefreshing()

       }else{
               updateNextSet()
       }
      }
    
    //MARK: Update next offset
    func updateNextSet(){
        self.offset =  self.offset! + 15
        getFolowes(offset: self.offset)
           //requests another set of data (20 more items) from the server.
    }
    
    func getFolowes(offset: Int?){
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.get_followings!
        
          let  sv = HomeViewController.displaySpinner(onView: self.view)
     let parameter :[String:Any]? = ["fb_id":self.fbId, "middle_name": self.appDelegate.middle_name, "my_fb_id" : UserDefaults.standard.string(forKey: "uid")!, "offset": String(offset ?? 0)]
          
          //print(url)
         // print(parameter!)
          
          let headers: HTTPHeaders = [
              "api-key": "4444-3333-2222-1111"
              
          ]
          
          AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
              
              respones in
              
              switch respones.result {
              case .success( let value):
                  
                  let json  = value
                  
                  HomeViewController.removeSpinner(spinner: sv)
                self.tableview.bottomRefreshControl?.endRefreshing()
                  self.Follow_Array = []
                 // print(json)
                  let dic = json as! NSDictionary
                  let code = dic["code"] as! NSString
                  if(code == "200"){
                    if let count = dic["total_following"] as? String{
                        self.totalCount = Int(count) ?? 0
                      //  print(self.totalNotificationCount)
                    }
                    
                    if let myCountry = dic["msg"] as? [[String:Any]]{
                        
                        for Dict in myCountry {
                            var fb_id:String! = ""
                            var first_name:String! = ""
                            var last_name:String! = ""
                            var follow_status_button:String! = ""
                            
                            var profile_pic:String! = ""
                            var username:String! = ""
                            var status:String! = ""
                            var my_follow_status_button:String! = ""
                            var myStatus:String! = ""
                            
                            let myRestaurant = Dict as NSDictionary
                            
                            if  let my_id =   myRestaurant["fb_id"] as? String{
                                
                                fb_id = my_id
                            }
                            
                            if let my_first =   myRestaurant["first_name"] as? String{
                                
                                first_name = my_first
                            }
                            
                            if let my_last =   myRestaurant["last_name"] as? String{
                                
                                last_name = my_last
                            }
                            
                            if let my_pic =   myRestaurant["profile_pic"] as? String{
                                profile_pic = my_pic
                            }
                            if let my_user =   myRestaurant["username"] as? String{
                                username = my_user
                            }
                            if let myRestaurant1 = myRestaurant["follow_Status"] as? NSDictionary{
                                
                                if let my_button =   myRestaurant1["follow_status_button"] as? String{
                                    follow_status_button = my_button
                                }
                                
                                if let my_status =   myRestaurant1["follow"] as? String{
                                    status = my_status
                                }
                                
                            }
                            
                            if let my_follow_Status = myRestaurant["my_follow_Status"] as? NSDictionary{
                                
                                if let my_button =   my_follow_Status["my_follow_status_button"] as? String{
                                    my_follow_status_button = my_button
                                }
                                
                                if let my_status =   my_follow_Status["follows"] as? String{
                                    myStatus = my_status
                                }
                                
                            }
                            
                            let obj = Follow(fb_id: fb_id, first_name: first_name, last_name: last_name,follow_status_button: follow_status_button, profile_pic: profile_pic, username: username, status: status, my_follow_status_button: my_follow_status_button, myStatus: myStatus)
                            
                            
                            self.Follow_Array.add(obj)
                            
                            
                        }
                        
                        if(self.Follow_Array.count == 0){
                            
                            
                            self.outer_view.isHidden = false
                            self.tableview.isHidden = true
                        }else{
                            
                            self.outer_view.isHidden = true
                            self.tableview.isHidden = false
                            self.tableview.reloadData()
                        }
                    }
                  }else{
                      
                      self.alertModule(title:"Error", msg:dic["msg"] as! String)
                      
                  }
        
                  
                  
              case .failure(let error):
                  print(error)
                  HomeViewController.removeSpinner(spinner: sv)
                  self.alertModule(title:"Network Error",msg: "Please try after some time.")
              }
          })
          
          
      }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.Follow_Array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:FollowTableViewCell = self.tableview.dequeueReusableCell(withIdentifier: "cell01") as! FollowTableViewCell
        
        let obj = self.Follow_Array[indexPath.row] as! Follow
        
        cell.folow_name.text = obj.first_name+" "+obj.last_name
        cell.folow_username.text = obj.username
        
        cell.follow_img.sd_setImage(with: URL(string:obj.profile_pic), placeholderImage: UIImage(named:"nobody_m.1024x1024"))
        cell.follow_img.layer.cornerRadius = cell.follow_img.frame.size.width / 2
        cell.follow_img.clipsToBounds = true
        
        cell.follow_view.layer.cornerRadius = cell.follow_view.frame.size.width / 2
        cell.follow_view.clipsToBounds = true
        
//        cell.foolow_btn_view.layer.cornerRadius = 5
//        cell.foolow_btn_view.clipsToBounds = true
        
        cell.btn_follow.tag = indexPath.item
               cell.btn_follow.addTarget(self, action: #selector(FollowingViewController.connected(_:)), for:.touchUpInside)
        
        if(obj.myStatus == "0"){
            
            let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
            cell.btn_follow.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
                     cell.foolow_btn_view.layer.borderColor = UIColor.clear.cgColor
                     cell.foolow_btn_view.layer.borderWidth = 1
          
            cell.btn_follow.setTitleColor(UIColor.white, for: .normal)
            cell.btn_follow.setTitle(obj.my_follow_status_button, for: .normal)
            
        }else{
            cell.foolow_btn_view.backgroundColor = UIColor.clear
            cell.btn_follow.backgroundColor = UIColor.clear
            cell.foolow_btn_view.backgroundColor = UIColor.clear
                      cell.foolow_btn_view.layer.borderColor = UIColor.lightGray.cgColor
                      cell.foolow_btn_view.layer.borderWidth = 1
            cell.btn_follow.setTitleColor(UIColor.lightGray, for: .normal)
            cell.btn_follow.setTitle("Friends", for: .normal)
         
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    @objc func connected(_ sender : UIButton) {
        
       // print(sender.tag)
                    
        let buttonTag = sender.tag
        let indexPath = IndexPath(row: buttonTag, section: 0)
              let cell = tableview.cellForRow(at: indexPath) as! FollowTableViewCell
         let obj = self.Follow_Array[buttonTag] as! Follow
        
        var nyStatus = "0"
        
        if(obj.myStatus == "0"){
            
            nyStatus = "1"
            obj.myStatus = "1"
            cell.foolow_btn_view.backgroundColor = UIColor.clear
            cell.btn_follow.backgroundColor = UIColor.clear
                      cell.foolow_btn_view.layer.borderColor = UIColor.lightGray.cgColor
                      cell.foolow_btn_view.layer.borderWidth = 1
            cell.btn_follow.setTitleColor(UIColor.lightGray, for: .normal)
            cell.btn_follow.setTitle("Friends", for: .normal)
            
            
        }else{
            nyStatus = "0"
            obj.myStatus = "0"
            
            let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
            cell.btn_follow.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
                               cell.foolow_btn_view.layer.borderColor = UIColor.clear.cgColor
                               cell.foolow_btn_view.layer.borderWidth = 1
                    
                      cell.btn_follow.setTitleColor(UIColor.white, for: .normal)
              cell.btn_follow.setTitle("Follow", for: .normal)
        }
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.follow_users!
              
                //let  sv = HomeViewController.displaySpinner(onView: self.view)
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"followed_fb_id":obj.fb_id!,"status":nyStatus, "middle_name": self.appDelegate.middle_name]
                
               // print(url)
                //print(parameter!)
                
                let headers: HTTPHeaders = [
                    "api-key": "4444-3333-2222-1111"
                    
                ]
                
                AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
                    
                    respones in
                    
                    
                    
                    switch respones.result {
                    case .success( let value):
                        
                        let json  = value
                        
                        //HomeViewController.removeSpinner(spinner: sv)
                        
                       // self.Follow_Array = []
                      //  print(json)
                        let dic = json as! NSDictionary
                        let code = dic["code"] as! NSString
                        if(code == "200"){
                            
                        
                  
                            
                        }else{
                            
                            self.alertModule(title:"Error", msg:dic["msg"] as! String)
                            
                        }
              
                        
                        
                    case .failure(let error):
                       // print(error)
                        //HomeViewController.removeSpinner(spinner: sv)
                        self.alertModule(title:"Error",msg:error.localizedDescription)
                    }
                })
        
       
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          
          let obj = self.Follow_Array[indexPath.row] as! Follow
                 
                 if(obj.fb_id != UserDefaults.standard.string(forKey: "uid")!){
                 
                 StaticData.obj.other_id = obj.fb_id
                     
                     let storyboard = UIStoryboard(name: "Main", bundle: nil)
                     let yourVC: Profile1ViewController = storyboard.instantiateViewController(withIdentifier: "Profile1ViewController") as! Profile1ViewController
                    self.navigationController?.pushViewController(yourVC, animated: true)
                 }else{
                     
                     
                 }
      }
    
    
    
    
    @IBAction func close(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func alertModule(title:String,msg:String){
           
           let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
           
           let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
               alertController.dismiss(animated: true, completion: nil)
           })
           
           alertController.addAction(alertAction)
           
           present(alertController, animated: true, completion: nil)
           
       }

}
