//
//  EditProfileViewController.swift
//  TIK TIK
//
//  Created by Rao Mudassar on 14/05/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import YPImagePicker
import Photos
import FirebaseStorage

class EditProfileViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var user_img: UIImageView!
    
     var downloadURL:String! = ""
    
    @IBOutlet weak var fill_img: UIImageView!
    
    @IBOutlet weak var empty_img: UIImageView!
    
    @IBOutlet weak var txt_last: UITextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var txt_bio: UITextView!
    @IBOutlet weak var txt_username: UITextField!
    
    @IBOutlet weak var txt_first: UITextField!
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var gen_seg: UISegmentedControl!
    
    var gender:String! = ""
    var first_name:String! = ""
    var last_name:String! = ""
    var user_name:String! = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txt_bio.text = "Write Your Bio Here"
        txt_bio.textColor = UIColor.lightGray
        txt_bio.delegate = self
        
        user_img.layer.masksToBounds = false
        user_img.layer.cornerRadius = user_img.frame.height/2
        user_img.clipsToBounds = true
        self.getUserData()
        
        let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
        self.btnSave.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // Get Profile Api
    
    func getUserData(){
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.get_user_data!
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name]
        
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
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        
                        if myCountry.count == 0{
                            
                        }else{
                            if  let sectionData = myCountry[0] as? NSDictionary{
                                
                                self.first_name = sectionData["first_name"] as? String
                                self.last_name = sectionData["last_name"] as? String
                                self.user_name = sectionData["username"] as? String
                                self.txt_first.text = self.first_name
                                self.txt_last.text = self.last_name
                                self.txt_username.text = self.user_name
                                
                                self.downloadURL = sectionData["profile_pic"] as? String
                                
                                self.user_img.sd_setImage(with: URL(string:(sectionData["profile_pic"] as? String)!), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
                                
                                self.gender = sectionData["gender"] as? String
                                
                                if(self.gender == "Female"){
                                    
                                    self.empty_img.image = UIImage(named:"radio-active")
                                    self.fill_img.image = UIImage(named:"radio")
                                    self.gender = "Female"
                                }else{
                                    self.fill_img.image = UIImage(named:"radio-active")
                                    self.empty_img.image = UIImage(named:"radio")
                                    self.gender = "Male"
                                }
                                
                                if let bio = sectionData["bio"] as? String{
                                    if bio != ""{
                                      self.txt_bio.text = bio
                                        self.txt_bio.textColor = .white
                                    }
                                }
                                
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
        })
        
        
    }
    
    // Choose Photo Delegate methods
    
    @IBAction func camera(_ sender: Any) {
        
        var config = YPImagePickerConfiguration()
        
        
        config.library.mediaType = .photo
        
        config.shouldSaveNewPicturesToAlbum = false
        
        config.video.compression = AVAssetExportPresetMediumQuality
        
        
        config.startOnScreen = .library
        config.showsPhotoFilters = false
     
        
        /* Defines which screens are shown at launch, and their order.
         Default value is `[.library, .photo]` */
        config.screens = [.library, .photo]
       
        config.showsCrop = .none
        
        /* Defines the overlay view for the camera. Defaults to UIView(). */
        // let overlayView = UIView()
        // overlayView.backgroundColor = .red
        // overlayView.alpha = 0.3
        // config.overlayView = overlayView
        /* Customize wordings */
        config.wordings.libraryTitle = "Gallery"
        
        /* Defines if the status bar should be hidden when showing the picker. Default is true */
        config.hidesStatusBar = false
        
        /* Defines if the bottom bar should be hidden when showing the picker. Default is false */
        config.hidesBottomBar = false
        
        config.library.maxNumberOfItems = 1
        
        /* Disable scroll to change between mode */
        // config.isScrollToChangeModesEnabled = false
        //        config.library.minNumberOfItems = 2
        
        /* Skip selection gallery after multiple selections */
        // config.library.skipSelectionsGallery = true
        /* Here we use a per picker configuration. Configuration is always shared.
         That means than when you create one picker with configuration, than you can create other picker with just
         let picker = YPImagePicker() and the configuration will be the same as the first picker. */
        
        
        /* Only show library pictures from the last 3 days */
        //let threDaysTimeInterval: TimeInterval = 3 * 60 * 60 * 24
        //let fromDate = Date().addingTimeInterval(-threDaysTimeInterval)
        //let toDate = Date()
        //let options = PHFetchOptions()
        //options.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", fromDate as CVarArg, toDate as CVarArg)
        //
        ////Just a way to set order
        //let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        //options.sortDescriptors = [sortDescriptor]
        //
        //config.library.options = options
        let picker = YPImagePicker(configuration: config)
        
        /* Change configuration directly */
        // YPImagePickerConfiguration.shared.wordings.libraryTitle = "Gallery2"
        
        
        /* Multiple media implementation */
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }
            
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    
                    print(photo.image)
                    
                    self.user_img.image = photo.image
            
                    let  sv = HomeViewController.displaySpinner(onView: self.view)
                    picker.dismiss(animated: true, completion: nil)
                    
                    let number = Int.random(in: 0 ... 1000)
                    let pickedImage = photo.image
                    
                    let storageRef = Storage.storage().reference().child(String(number)+"_myImage.png")
                    
                    if let uploadData = pickedImage.jpeg(.lowest) {
                            
                            storageRef.putData(uploadData, metadata: nil, completion: { (metadata,error ) in
                                               
                                    guard let metadata = metadata else{
                                                   print(error!)
                                                   HomeViewController.removeSpinner(spinner: sv)
                                                   
                                                   return
                                               }
                                               storageRef.downloadURL { (url, error) in
                                                   print(url!)
                                                   self.downloadURL = String(describing: url!)
                                                var data = photo.image
                                               // let imageData = data.pngData()!
                                              //  var imgData =  imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
                                                
                                                HomeViewController.removeSpinner(spinner: sv)
                                                let imageData:NSData = try! Data(contentsOf: url!) as NSData
                                            //    let imageStr = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                                               
                                                var da = imageData.base64EncodedString(options: .lineLength76Characters)

                                                 print(da)
                                                self.UploadImage(imgSrring: da)
                                                   guard let downloadURL = url else {
                                                       //Chat1ViewController.removeSpinner(spinner: sv)
                                                       HomeViewController.removeSpinner(spinner: sv)
                                                       return
                                                   }
                                               }
                                           })
                    }
                case .video(let video):
                    print(video)
                  
                        
                    }
                
                    picker.dismiss(animated: true, completion: { [weak self] in
                        
                    })
                }
            }
        
    
        present(picker, animated: true, completion: nil)
        
        
    }
    
    @IBAction func changeGender(_ sender: Any) {
        
        if gen_seg.selectedSegmentIndex == 0 {
            self.gender = "Male"
            
        }else{
            self.gender = "Female"
            
            
        }
    }
    
    func UploadImage(imgSrring:String){
        
       let url : String = self.appDelegate.baseUrl!+self.appDelegate.uploadImage!
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        var str = ""
        
        let utf8str = downloadURL.data(using: .utf8)

        if let base64Encoded = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
            print("Encoded: \(base64Encoded)")
           str = base64Encoded
            if let base64Decoded = Data(base64Encoded: base64Encoded, options: Data.Base64DecodingOptions(rawValue: 0))
            .map({ String(data: $0, encoding: .utf8) }) {
                // Convert back to a string
                print("Decoded: \(base64Decoded ?? "")")
            }
        }
        let imgDict = ["file_data":imgSrring]
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"image":imgDict, "middle_name": self.appDelegate.middle_name]
        
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
                       
                      // print(json)
                       let dic = json as! NSDictionary
                       let code = dic["code"] as! NSString
                       if(code == "200"){
                        if let myCountry = dic["msg"] as? NSArray{
                            
                            if  let sectionData = myCountry[0] as? NSDictionary{
                                
                               let profile = sectionData["profile_pic"] as? String ?? ""
                                print(profile)
                                UserDefaults.standard.set(profile, forKey: "Profile_Pic")
                            }}
                           //self.navigationController?.popViewController(animated: true)
                          HomeViewController.removeSpinner(spinner: sv)
                           
                       }else{
                        
                        self.alertModule(title:"Error", msg:dic["msg"] as? String ?? "")
                           
                       }
                       
                   case .failure(let error):
                       print(error)
                       HomeViewController.removeSpinner(spinner: sv)
                       self.alertModule(title:"Error",msg:error.localizedDescription)
                   }
               })
        
    }
    
    @IBAction func onTapCross(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
      
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.edit_profile!
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        let userName = self.txt_username.text
        let usernemFnl = userName?.replacingOccurrences(of: "@", with: "")
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"first_name":self.txt_first.text!,"last_name":txt_last.text!,"gender":self.gender!,"bio":self.txt_bio.text!,"username":usernemFnl ?? "", "middle_name": self.appDelegate.middle_name]
        
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
                
              //  print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    self.navigationController?.popViewController(animated: true)
                   
                    
                }else{
                    
                  //  self.alertModule(title:"Error", msg:dic["msg"] as? String)
                    
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
    
    
    @IBAction func male(_ sender: Any) {
        self.fill_img.image = UIImage(named:"radio-active")
        self.empty_img.image = UIImage(named:"radio")
        self.gender = "Male"
    }
    
    @IBAction func female(_ sender: Any) {
        
        self.empty_img.image = UIImage(named:"radio-active")
        self.fill_img.image = UIImage(named:"radio")
        self.gender = "Female"
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.text = ""
        textView.textColor = .white
        return true
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
