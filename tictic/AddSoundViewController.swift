//
//  AddSoundViewController.swift
//  TIK TIK
//
//  Created by Rao Mudassar on 02/05/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import AVKit

protocol AddSoundViewControllerDelegate {
    func dismiss()
}

class AddSoundViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var delegate : AddSoundViewControllerDelegate?
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var romanceView: UIView!
    @IBOutlet weak var newView: UIView!
    @IBOutlet weak var trendingView: UIView!
    @IBOutlet weak var originalView: UIView!
    @IBOutlet weak var nintysView: UIView!
  //  @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblSection: UILabel!
  //  @IBOutlet weak var soud_view: UIView!
   // @IBOutlet weak var fav_view: UIView!
    @IBOutlet weak var btn_discover: UIButton!
    @IBOutlet weak var btn_favourite: UIButton!
    @IBOutlet weak var tablview: UITableView!
    
    var sound_array =  [Sound]()
    var Fav_Array:NSMutableArray = []
    var player:AVPlayer!
    var loadingToggle:String? = "yes"
    var refreshControl = UIRefreshControl()
    var isDisCover:String! = "yes"
  var isCopyright = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tablview.tableFooterView = UIView()
        
        //self.getCategories()
        self.getSounds(params: ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name, "section": "1"])
    }
    
    //MARK: Refresh action
    @objc func refresh(sender:AnyObject) {
        loadingToggle = "no"
        self.getSounds(params: ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name, "section": ""])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    //MARK: Get All Sounds Api
    func getSounds(params:[String:Any]){
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.allSoundsNew!
        let  sv = HomeViewController.displaySpinner(onView: self.view)

        // let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name, "section": ""]
        
        print(url)
        print(params)
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
            
        ]
        
        AF.request(url, method: .post, parameters:params, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
                
                HomeViewController.removeSpinner(spinner: sv)
                
                self.sound_array = []
               // print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        for i in 0...myCountry.count-1{
                            
                            if  let sectionData = myCountry[i] as? NSDictionary{
                                let tempMenuObj = Sound()
                                tempMenuObj.name = sectionData["section_name"] as? String
                                if let extraData = sectionData["sections_sounds"] as? NSArray{
                                    
                                    for j in 0...extraData.count-1{
                                        let dic2 = extraData[j] as! [String:Any]
                                        
                                        var tempProductList = Itemlist()
                                        
                                        if let audio_path = dic2["audio_path"] as? NSDictionary{
                                            
                                            tempProductList.audio_path = audio_path["acc"] as? String
                                            
                                            tempProductList.uid = dic2["id"] as? String
                                            tempProductList.sound_name = dic2["sound_name"] as? String
                                            tempProductList.thum = dic2["thum"] as? String
                                            tempProductList.description = dic2["description"] as? String
                                            var fave = dic2["fav"] as? NSNumber
                                            print("fave",fave)
                                            tempProductList.fav = String(fave?.stringValue ?? "0");     tempMenuObj.listOfProducts.append(tempProductList)
                                            
                                        }
                                        
                                    }
                                    self.sound_array.append(tempMenuObj)
                                }
                            }
                            
                        }
                        
                    }
                    
                    self.tablview.delegate = self
                    self.tablview.dataSource = self
                    self.tablview.reloadData()
                    
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
    
    //MARK: Get All Favourite Api
    func getFavSounds(){
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.my_FavSound!
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
                
                self.Fav_Array = []
               // print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    let myCountry = (dic["msg"] as? [[String:Any]])!
                    for Dict in myCountry {
                        
                        let myRestaurant = Dict as NSDictionary
                        
                        let sid = myRestaurant["id"] as! String
                        let audio_patha = myRestaurant["audio_path"] as! NSDictionary
                        let thum = myRestaurant["thum"] as! String
                        
                        let descri = myRestaurant["description"] as! String
                        
                        let sound_name = myRestaurant["sound_name"] as? String
                        let audio_path:String! =   audio_patha["acc"] as? String
                        
                        
                        let obj = FavSound(sid: sid, thum: thum, sound_name: sound_name,audio_path: audio_path, descri: descri)
                        
                        self.Fav_Array.add(obj)
                    }
                    
                    self.tablview.delegate = self
                    self.tablview.dataSource = self
                    self.tablview.reloadData()
                    
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
    
    //MARK: Tableview Delegate methods
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if(self.isDisCover == "yes"){
//            if section < sound_array.count {
//                let obj = sound_array[section]
//                return obj.name
//            }
//        }
//        return ""
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
       
        if(self.isDisCover == "yes"){
            return sound_array.count
        }else{
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.isDisCover == "yes") {
            if section < sound_array.count {
                return sound_array[section].listOfProducts.count
            }
        }else{
            categoryView.isHidden = true
            return self.Fav_Array.count
        }
        
        return Int()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SoundTableViewCell = self.tablview.dequeueReusableCell(withIdentifier: "cell02") as! SoundTableViewCell
        
        if(self.isDisCover == "yes"){
            categoryView.isHidden = false
            let obj:Itemlist = sound_array[indexPath.section].listOfProducts[indexPath.row]
            
            cell.sound_name.text = obj.sound_name
            cell.sound_type.text = obj.description
            cell.sound_img.sd_setImage(with: URL(string:obj.thum), placeholderImage: UIImage(named:"ic_music"))
            
            // set fave image
            let favId = obj.fav!
            
            if favId == "0"{
                cell.btn_favourites.setBackgroundImage(UIImage(named:"icon_favourit"), for: .normal)
                // cell.btn_favourites.setImage(UIImage(named: "9"), for: .normal)
            }else{
                cell.btn_favourites.setBackgroundImage(UIImage(named:"icon_favourit_filled"), for: .normal)
                //   cell.btn_favourites.setImage(UIImage(named: "7"), for: .normal)
            }
            
            cell.btn_favourites.addTarget(self, action: #selector(AddSoundViewController.connected(_:)), for:.touchUpInside)
            cell.select_btn.addTarget(self, action: #selector(AddSoundViewController.connected1(_:)), for:.touchUpInside)
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
            
            cell.btn_play.image = UIImage(named: "ic_play_icon.png")
            cell.select_view.alpha = 0
            cell.select_btn.alpha = 0
            
            return cell
            
        }else{
            
            if let obj = self.Fav_Array[indexPath.row] as? FavSound{
                categoryView.isHidden = true
                cell.sound_name.text = obj.sound_name
                cell.sound_type.text = obj.descri
                cell.sound_img.sd_setImage(with: URL(string:obj.thum ?? ""), placeholderImage: UIImage(named:"ic_music"))
                
                cell.btn_favourites.alpha = 0
                
                cell.innerview.layer.masksToBounds = false
                
                cell.innerview.layer.cornerRadius = 4
                cell.innerview.clipsToBounds = true
                
                cell.outerview.layer.masksToBounds = false
                
                cell.outerview.layer.cornerRadius = 4
                cell.outerview.clipsToBounds = true
                
                cell.select_view.layer.masksToBounds = false
                
                cell.select_view.layer.cornerRadius = 4
                cell.select_view.clipsToBounds = true
                
                cell.select_btn.addTarget(self, action: #selector(AddSoundViewController.connected1(_:)), for:.touchUpInside)
                cell.select_btn.tag = indexPath.row
                
                cell.btn_play.image = UIImage(named: "ic_play_icon.png")
                cell.select_view.alpha = 0
                cell.select_btn.alpha = 0
                return cell
            }
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90
    }
    
    //    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //        let delete = UIContextualAction(style: .destructive, title: "Add") { (action, sourceView, completionHandler) in
    //            print("index path of delete: \(indexPath)")
    //            if(self.isDisCover == "yes"){
    //            let obj:Itemlist = self.sound_array[indexPath.section].listOfProducts[indexPath.row]
    //
    //                UserDefaults.standard.set(obj.audio_path, forKey: "url")
    //
    //                 UserDefaults.standard.set(obj.uid, forKey: "sid")
    //
    //                if let audioUrl = URL(string: obj.audio_path) {
    //
    //                    // then lets create your document folder url
    //                    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    //
    //                    // lets create your destination file url
    //                    let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
    //                    print(destinationUrl)
    //
    //                    // to check if it exists before downloading it
    //                    if FileManager.default.fileExists(atPath: destinationUrl.path) {
    //                        print("The file already exists at path")
    //
    //                        // if the file doesn't exist
    //                    } else {
    //
    //                        // you can use NSURLSession.sharedSession to download the data asynchronously
    //                        URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
    //                            guard let location = location, error == nil else { return }
    //                            do {
    //                                // after downloading your file you need to move it to your destination url
    //                                try FileManager.default.moveItem(at: location, to: destinationUrl)
    //                                print("File moved to documents folder")
    //                            } catch let error as NSError {
    //                                print(error.localizedDescription)
    //                            }
    //                        }).resume()
    //                    }
    //                }
    //            }else{
    //
    //               let obj = self.Fav_Array[indexPath.row] as! FavSound
    //
    //                 UserDefaults.standard.set(obj.audio_path, forKey: "url")
    //                UserDefaults.standard.set(obj.sid, forKey: "sid")
    //
    //                if let audioUrl = URL(string: obj.audio_path) {
    //
    //                    // then lets create your document folder url
    //                    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    //
    //                    // lets create your destination file url
    //                    let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
    //                    print(destinationUrl)
    //
    //                    // to check if it exists before downloading it
    //                    if FileManager.default.fileExists(atPath: destinationUrl.path) {
    //                        print("The file already exists at path")
    //
    //                        // if the file doesn't exist
    //                    } else {
    //
    //                        // you can use NSURLSession.sharedSession to download the data asynchronously
    //                        URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
    //                            guard let location = location, error == nil else { return }
    //                            do {
    //                                // after downloading your file you need to move it to your destination url
    //                                try FileManager.default.moveItem(at: location, to: destinationUrl)
    //                                print("File moved to documents folder")
    //                            } catch let error as NSError {
    //                                print(error.localizedDescription)
    //                            }
    //                        }).resume()
    //                    }
    //                }
    //
    //
    //            }
    //
    //
    //            completionHandler(true)
    //
    //            self.dismiss(animated:true, completion: nil)
    //        }
    //
    //
    //
    //
    //        let swipeActionConfig = UISwipeActionsConfiguration(actions: [delete])
    //        swipeActionConfig.performsFirstActionWithFullSwipe = false
    //        return swipeActionConfig
    //    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.groupTableViewBackground
//
//        let headerLabel = UILabel(frame: CGRect(x: 25, y: 5, width:
//            tableView.bounds.size.width, height: tableView.bounds.size.height))
//        headerLabel.font = UIFont(name: "Verdana", size: 14)
//        headerLabel.textColor = UIColor.black
//        headerLabel.text = self.tableView(self.tablview, titleForHeaderInSection: section)
//        headerLabel.sizeToFit()
//        headerView.addSubview(headerLabel)
//
//        return headerView
//    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//
//        if(self.isDisCover == "yes"){
//
//            return 30
//
//        }else{
//            return 0
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.tablview.cellForRow(at: indexPath) as? SoundTableViewCell
        
        DispatchQueue.main.async {
            
            if(self.isDisCover == "yes"){
                
                let obj:Itemlist = self.sound_array[indexPath.section].listOfProducts[indexPath.row]
                if cell?.btn_play.tag == 1001 {
                    
                    // cell!.btn_play.setBackgroundImage(UIImage(named: "ic_pause_icon"), for: .normal)
                    cell?.btn_play.image = UIImage(named: "ic_pause_icon.png")
                    cell?.btn_play.tag = 1002
                    let url = obj.audio_path!
                    let playerItem = AVPlayerItem( url:NSURL( string:url )! as URL )
                    self.player = AVPlayer(playerItem:playerItem)
                    self.player!.rate = 1.0;
                    cell?.select_view.alpha = 1
                    cell?.select_btn.alpha = 1
                    self.player!.play()
                }else {
                    // cell!.btn_play.setBackgroundImage(UIImage(named: "ic_play_icon"), for: .normal)
                    cell?.btn_play.tag = 1001
                    cell?.btn_play.image = UIImage(named: "ic_play_icon.png")
                    cell?.select_view.alpha = 0
                    cell?.select_btn.alpha = 0
                    self.player.pause()
                }
                
            }else{
                
                
                let obj = self.Fav_Array[indexPath.row] as! FavSound
                
                
                if cell?.btn_play.tag == 1001 {
                    
                    cell?.btn_play.image = UIImage(named: "ic_pause_icon")
                    cell?.btn_play.tag = 1002
                    let url = obj.audio_path!
                    let playerItem = AVPlayerItem( url:NSURL( string:url )! as URL )
                    self.player = AVPlayer(playerItem:playerItem)
                    self.player!.rate = 1.0;
                    cell?.select_view.alpha = 1
                    cell?.select_btn.alpha = 1
                    
                    self.player!.play()
                }else{
                    cell?.btn_play.image = UIImage(named: "ic_play_icon")
                    cell?.btn_play.tag = 1001
                    cell?.select_view.alpha = 0
                    cell?.select_btn.alpha = 0
                    self.player.pause()
                }
            }
        }
        
        self.tablview.reloadData()
        
    }
    
    //MARK: Cell for row action method connected1
    @objc func connected1(_ sender : UIButton) {
        print(sender.tag)
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tablview)
        let indexPath = self.tablview.indexPathForRow(at:buttonPosition)
        
        if(self.isDisCover == "yes"){
            let obj:Itemlist = self.sound_array[indexPath!.section].listOfProducts[indexPath!.row]
            UserDefaults.standard.set(obj.audio_path, forKey: "url")
            UserDefaults.standard.set(obj.audio_path, forKey: "audioUrl")
            UserDefaults.standard.set(obj.uid, forKey: "sid")
            UserDefaults.standard.set(obj.sound_name, forKey: "sound_name")
            
            if let audioUrl = URL(string: obj.audio_path) {
                
                // then lets create your document folder url
                let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                
                // lets create your destination file url
                let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
                print(destinationUrl)
                
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
        }else{
            
            let obj = self.Fav_Array[indexPath!.row] as! FavSound
            
            UserDefaults.standard.set(obj.audio_path, forKey: "url")
            UserDefaults.standard.set(obj.audio_path, forKey: "audioUrl")
            UserDefaults.standard.set(obj.sid, forKey: "sid")
            UserDefaults.standard.set(obj.sound_name, forKey: "sound_name")
            
            if let audioUrl = URL(string: obj.audio_path) {
                
                // then lets create your document folder url
                let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                
                // lets create your destination file url
                let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
                print(destinationUrl)
                
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
            
            
        }
        
        
        // completionHandler(true)
        if isCopyright == true{
            self.dismiss(animated:true, completion: {
                self.delegate?.dismiss()
            })
        }else{
            self.dismiss(animated:true, completion: nil)
        }
       
        
        
    }
    //MARK: Connected
    @objc func connected(_ sender : UIButton) {
        print(sender.tag)
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tablview)
        let indexPath = self.tablview.indexPathForRow(at:buttonPosition)
        let cell = self.tablview.cellForRow(at: indexPath!) as! SoundTableViewCell
        let obj:Itemlist = sound_array[indexPath!.section].listOfProducts[indexPath!.row]
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.fav_sound!
        
        var favoutite = "1"
        let faveobj = obj.fav!
        print(faveobj )
        var faveObjInt = Int(faveobj ?? "0")
        print(faveObjInt)
        
        if faveObjInt! == 0
        {
            favoutite = "1"
        }
        else
        {
            favoutite = "0"
        }
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"sound_id":obj.uid!,"fav":favoutite, "middle_name": self.appDelegate.middle_name]
        
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
                    
                    self.getSounds(params: ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name, "section": ""])
                    
                }else{
                    
                    
                    
                }
                
                
                
            case .failure(let error):
                print(error)
                //cell.btn_favourites.setBackgroundImage(UIImage(named:"7"), for: .normal)
            }
        })
        
        
    }
    
    //    @objc func connected1(_ sender : UIButton) {
    //        print(sender.tag)
    //
    //        let buttonPosition = sender.convert(CGPoint.zero, to: self.tablview)
    //        let indexPath = self.tablview.indexPathForRow(at:buttonPosition)
    //        let cell = self.tablview.cellForRow(at: indexPath!) as! SoundTableViewCell
    //        let obj:Itemlist = sound_array[indexPath!.section].listOfProducts[indexPath!.row]
    //
    //
    //        if cell.btn_play.currentBackgroundImage!.isEqual(UIImage(named: "ic_play_icon")) {
    //
    //     cell.btn_play.setBackgroundImage(UIImage(named: "ic_pause_icon"), for: .normal)
    //        let url = obj.audio_path!
    //        let playerItem = AVPlayerItem( url:NSURL( string:url )! as URL )
    //        player = AVPlayer(playerItem:playerItem)
    //        player!.rate = 1.0;
    //
    //        player!.play()
    //        }else{
    //            cell.btn_play.setBackgroundImage(UIImage(named: "ic_play_icon"), for: .normal)
    //            player.pause()
    //        }
    //    }
    
    
    //MARK: Cross action button clicked
    @IBAction func cross(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Discover button Action
    @IBAction func discover(_ sender: Any) {
       // categoryView.isHidden = false
        self.btn_favourite.titleLabel?.font =  UIFont(name:"Poppins-Regular",size:17)
        self.btn_discover.titleLabel?.font =  UIFont(name:"Poppins-SemiBold",size:17)
        self.isDisCover = "yes"
//        self.fav_view.backgroundColor = .clear
//        self.soud_view.backgroundColor = .white
        self.btn_discover.setTitleColor(UIColor.white, for: .normal)
        self.btn_favourite.setTitleColor(UIColor.lightGray, for: .normal)
        self.getSounds(params: ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name, "section": ""])
        
    }
    
    //MARK: Favorites button Clicked
    @IBAction func favourite(_ sender: Any) {
        self.btn_discover.titleLabel?.font =  UIFont(name:"Poppins-Regular",size:17)
        self.btn_favourite.titleLabel?.font =  UIFont(name:"Poppins-SemiBold",size:17)
        self.isDisCover = "no"
//        self.fav_view.backgroundColor = .white
//        self.soud_view.backgroundColor = .clear
        self.btn_discover.setTitleColor(UIColor.lightGray, for: .normal)
        self.btn_favourite.setTitleColor(UIColor.white, for: .normal)
        self.getFavSounds()
        
        
    }
    
    //MARK: Alert Module function
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: On tap clicked
    @IBAction func onTapNew(_ sender: Any) {
        lblSection.text = "New"
        self.getSounds(params: ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name, "section": "1"])
    }
    
    //MARK: On ta[ trending button clicked
    @IBAction func onTapTrending(_ sender: Any) {
        lblSection.text = "Trending"
        self.getSounds(params: ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name, "section": "2"])
    }
    
    //MARK: On tap original clicked
    @IBAction func onTapOriginal(_ sender: Any) {
        lblSection.text = "Romance"
        self.getSounds(params: ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name, "section": "3"])
    }
    
    //MARK: On tap 90s clicked
    @IBAction func onTap90s(_ sender: Any) {
        lblSection.text = "Motivational"
        self.getSounds(params: ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name, "section": "4"])
    }
    
    //MARK: On tap Romance clicked
    @IBAction func onTapRomance(_ sender: Any) {
        lblSection.text = "Friendship"
        self.getSounds(params: ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name, "section": "5"])
    }
    
//MARK: Get Categoried
    func getCategories(){
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.getCategories!
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
         let parameter :[String:Any]? = ["middle_name": self.appDelegate.middle_name]
        
        print(url)
        print(parameter)
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
            
        ]
        
        AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
                
                HomeViewController.removeSpinner(spinner: sv)
                
                self.sound_array = []
              //  print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        for i in 0...myCountry.count-1{
                            
                            if  let sectionData = myCountry[i] as? NSDictionary{
                          //    sectionData["id"] as Int
                               
                            }
                        }
                    }
                    
                    self.tablview.delegate = self
                    self.tablview.dataSource = self
                    self.tablview.reloadData()
                    
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
    
    
}

