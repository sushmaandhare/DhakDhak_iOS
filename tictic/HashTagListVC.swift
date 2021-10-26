//
//  HashTagListVC.swift
//  TIK TIK
//
//  Created by MacBook Air on 01/01/1943 Saka.
//  Copyright © 1943 Rao Mudassar. All rights reserved.
//

import UIKit
import Alamofire

protocol HashTagListVCDelegate {
    func sendList(val:String)
}

class HashTagListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate : HashTagListVCDelegate?
    var hashtagListArr = [hashtagList]()
    var selectedHashtags : String = ""
    var selectedHashtagsArr : [String] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getHashtagList()
    }
    
    //MARK: On TAP Dismiss
    @IBAction func onTapDismiss(_ sender: Any) {
        
        self.dismiss(animated: true, completion: { [self] in
            
            self.delegate?.sendList(val: self.selectedHashtagsArr.joined(separator: " "))
        })
    }

    //MARK:- TableView Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hashtagListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HashtagTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "HashtagTableViewCell") as! HashtagTableViewCell
        
        let obj = self.hashtagListArr[indexPath.row]
        cell.lblName.text = obj.hashtag
        cell.lblView.text = obj.videos_count
        cell.btnFavourit.tag = indexPath.item
       // cell.btnFavourit.addTarget(self, action: #selector(VideoUploadViewController.connected(_:)), for:.touchUpInside)
   
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = self.hashtagListArr[indexPath.row]
       
        let cell = tableView.cellForRow(at: indexPath) as! HashtagTableViewCell
        let str = "#" + obj.hashtag
        if cell.btnFavourit.isHidden == true{
            cell.btnFavourit.isHidden = false
            selectedHashtagsArr.append(str)
        }else{
            cell.btnFavourit.isHidden = true
            selectedHashtagsArr = selectedHashtagsArr.filter { $0 != str }
        }
        
        print(selectedHashtagsArr)
    }

    
     //MARK: GET hashtag list
    
    func getHashtagList(){
        
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.Search_User!
        let parameter1 :[String:Any]? = ["keyword": "", "type":"hashtag", "middle_name": self.appDelegate.middle_name, "starting_point":"0", "user_id":UserDefaults.standard.string(forKey: "uid")!,"offset":0]
        
        let headers1: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
            
        ]
        
        AF.request(url, method: .post, parameters:parameter1, encoding:JSONEncoding.default, headers:headers1).validate().responseJSON(completionHandler: {
            
            respones in
            print(respones)
            
            switch respones.result {
            case .success( let value):
                HomeViewController.removeSpinner(spinner: sv)
                let json  = value
                self.hashtagListArr = []
                
                print(print("hashtagJSON --- \(json)"))
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        if myCountry.count > 0{
                            for i in 0...myCountry.count-1{
                                
                                if  let sectionData = myCountry[i] as? NSDictionary{
                                    if let tempMenuObj = sectionData["Hashtag"] as? NSDictionary{
                                        var list = hashtagList()
                                        
                                        list.favourite = tempMenuObj["favourite"] as? String
                                        list.hashtag = tempMenuObj["hashtag"] as? String
                                        list.hashtag_id = tempMenuObj["hashtag_id"] as? String
                                        list.videos_count = tempMenuObj["videos_count"] as? String
                                        list.views = tempMenuObj["views"] as? String
                                        //
                                        self.hashtagListArr.append(list)
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    
                    print(self.hashtagListArr)
                    
                    
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                    
                    
                }else{
                    //                    self.refreshControl.endRefreshing()
                    //                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
            case .failure(let error):
                print(error)
                HomeViewController.removeSpinner(spinner: sv)
            }
        })
        
    }
}

class HashtagTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnFavourit: UIButton!
    @IBOutlet weak var lblView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}



