//
//  BlockedUserListVC.swift
//  TIK TIK
//
//  Created by MacBook Air on 12/08/1942 Saka.
//  Copyright © 1942 Rao Mudassar. All rights reserved.
//

import UIKit
import Alamofire

class BlockedUserListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var list : NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.blockUserList
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name]
        
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
                
                HomeViewController.removeSpinner(spinner: sv)
                
             //     print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        print(myCountry)
                        for dict in myCountry{
                            if  let sectionData = dict as? NSDictionary{
                                let fname:String! = (sectionData["first_name"] as! String)
                                let lname:String! = (sectionData["last_name"] as! String)
                                let profilepic:String! = (sectionData["profile_pic"] as! String)
                                let fb_id:String! = (sectionData["fb_id"] as! String)
                                
                                let obj = BlockList(first_name: fname, last_name: lname, profile_pic: profilepic, fb_id: fb_id)
                                
                                self.list.add(obj)
                                
                                if(self.list.count == 0){
                                    self.emptyView.isHidden = false
                                    self.tableView.isHidden = true
                                }else{
                                    self.emptyView.isHidden = true
                                    self.tableView.isHidden = false
                                    self.tableView.reloadData()
                                }
                                
                                
                            }
                        }
                        
                    }
                   
                }else{
                    
                  //  self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
            case .failure(let error):
                print(error)
                HomeViewController.removeSpinner(spinner: sv)
               // self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
        
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:BlockListTVC = self.tableView.dequeueReusableCell(withIdentifier: "BlockListTVC") as! BlockListTVC
        let obj = self.list[indexPath.row] as! BlockList
        
        cell.outerView.layer.cornerRadius = cell.outerView.frame.width / 2
        cell.outerView.layer.borderWidth = 1.5
        cell.profileImgView.clipsToBounds = true
        cell.profileView.clipsToBounds = true
        cell.profileImgView.sd_setImage(with: URL(string:obj.profile_pic), placeholderImage: UIImage(named:"nobody_m.1024x1024"))
        cell.lblName.text = obj.first_name + " " + obj.last_name
        cell.btn_Unblock.layer.cornerRadius = 5
        cell.btn_Unblock.tag = indexPath.row
        
        cell.btn_Unblock.addTarget(self, action: #selector(BlockedUserListVC.unblockUser(_:)), for:.touchUpInside)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           
           return 80
       }
   
    @objc func unblockUser(_ sender : UIButton) {
           
           print(sender.tag)
                       
           let buttonTag = sender.tag
      
        let obj = self.list[buttonTag] as! BlockList
     
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.blockUser
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid") ?? "", "middle_name": self.appDelegate.middle_name, "user_id": obj.fb_id, "block":"0"]

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
                
              //  print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    let alertController = UIAlertController(title: "User Unblocked!!", message: "User unblocked successfully.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)

                   
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
    
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
        
    }
}

class BlockListTVC : UITableViewCell{
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btn_Unblock: UIButton!
    
    
}

