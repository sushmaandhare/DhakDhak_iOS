//
//  NotificationViewController.swift
//  TIK TIK
//
//  Created by Rao Mudassar on 24/04/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import Alamofire
import AuthenticationServices

class NotificationViewController: UIViewController,GIDSignInDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var inner_view: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var outer_view: UIView!
    var first_name:String! = ""
    var last_name:String! = ""
    var email:String! = ""
    var my_id:String! = ""
    var profile_pic:String! = ""
    var signUPType:String! = ""
    
    var Notifications_Array:NSMutableArray = []
    var offset : Int? = 0
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var lblTerms: UILabel!
    
    var totalNotificationCount = 0

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

        
        self.view.backgroundColor = .black
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self

        let bottomRefreshController = UIRefreshControl()
        bottomRefreshController.triggerVerticalOffset = 50
        bottomRefreshController.addTarget(self, action: #selector(self.refreshBottom), for: .valueChanged)
        tableview.bottomRefreshControl = bottomRefreshController
        tableview.isPagingEnabled =  true
    }
    
    //MARK: Refresher bottom
      @objc func refreshBottom() {
          print("refresh")
       if totalNotificationCount == Notifications_Array.count{
           self.tableview.bottomRefreshControl?.endRefreshing()

       }else{
               updateNextSet()
       }
      }
    
    override func viewWillAppear(_ animated: Bool) {
        flag = false
           tableview.tableFooterView = UIView(frame: .zero)
       
        UIApplication.shared.statusBarStyle = .default
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = true
        self.navigationController?.navigationBar.isHidden = true
     
        if(UserDefaults.standard.string(forKey: "uid") == ""){
            
            self.inner_view.alpha = 1
//            self.navigationController?.navigationBar.isHidden = true
//            self.navigationItem.title = "Login"
         
        }else{
            
            self.inner_view.alpha = 0
//            self.navigationItem.title = "INBOX"
//            self.navigationController?.navigationBar.isHidden = false
            self.getNotifications(offset: self.offset)
            
        }
       
    }
    
    // Facebook Login Method
    
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
                            self.signUPType = "facebook"
                            let dic1 = dict["picture"] as! NSDictionary
                            let pic = dic1["data"] as! NSDictionary
                            self.profile_pic = pic["url"] as? String
                
                            
                            self.SignUpApi()
                            
                        }
                    }
                    
                }else{
                    
                    HomeViewController.removeSpinner(spinner: sv)
                    
                    
                }
            })
        }
        
    }
    
    // Gmail Login Method
    
    
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
                
            }else{
                self.profile_pic = ""
            }
            
            self.signUPType = "gmail"
            self.SignUpApi()
        }
        
        
    }
    
    // Signup Api
    
    func SignUpApi(){
        
        
        
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        var VersionString:String! = ""
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            VersionString = version
        }
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.signUp!
        let udid = UIDevice.current.identifierForVendor?.uuidString

        let parameter:[String:Any]?  = ["fb_id":self.my_id!,"first_name":self.first_name!,"last_name":self.last_name!,"profile_pic":self.profile_pic!,"gender":"m","signup_type":self.signUPType!,"version":VersionString!,"device":"iOS","device_id":udid!]
        
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
                        
                        self.inner_view.alpha = 0
                        self.navigationItem.title = "INBOX"
                        self.navigationController?.navigationBar.isHidden = true
                        self.tabBarController?.selectedIndex = 3
                        
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
    
    //MARK: Update next offset
    func updateNextSet(){
        self.offset =  self.offset! + 6
        getNotifications(offset: self.offset)
           //requests another set of data (20 more items) from the server.
    }
    
    func getNotifications(offset: Int?){
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.getNotifications!
        
      //  let  sv = HomeViewController.displaySpinner(onView: self.view)
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!, "middle_name": self.appDelegate.middle_name, "offset": String(offset ?? 0)]
        //   let parameter :[String:Any]? = ["fb_id":"10158924645617150", "middle_name": self.appDelegate.middle_name]
        
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
                
             //   HomeViewController.removeSpinner(spinner: sv)
                self.tableview.bottomRefreshControl?.endRefreshing()
               // self.Notifications_Array = []
            //     print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let count = dic["total_count"] as? String{
                        self.totalNotificationCount = Int(count) ?? 0
                        print(self.totalNotificationCount)
                    }
                    
                    if let myCountry = dic["msg"] as? [[String:Any]]{
                        
                        for Dict in myCountry {
                            var effected_fb_id:String! = ""
                            var first_name:String! = ""
                            var last_name:String! = ""
                            var profile_pic:String! = ""
                            var username:String! = ""
                            var type:String! = ""
                            
                            var v_id:String! = ""
                            var fb_id:String! = ""
                            var thumb:String! = ""
                            var Vvalue:String! = ""
                            
                            let myRestaurant = Dict as NSDictionary
                            if  let effectedFb_id =   myRestaurant["effected_fb_id"] as? String{
                                
                                effected_fb_id = effectedFb_id
                            }
                            
                            if  let my_id =   myRestaurant["fb_id"] as? String{
                                
                                fb_id = my_id
                            }
                            if  let my_value =   myRestaurant["value"] as? String{
                                
                                Vvalue = my_value
                            }
                            
                            if  let my_type =   myRestaurant["type"] as? String{
                                
                                type = my_type
                            }
                            if  let my_value_data =   myRestaurant["value_data"] as? NSDictionary{
                                
                                if  let my_video =   my_value_data["id"] as? String{
                                    v_id = my_video
                                }
                                if  let thum =   my_value_data["thum"] as? String{
                                    thumb = thum
                                }
                                print(v_id)
                            }
                            
                            if let fb_id_details =   myRestaurant["fb_id_details"] as? NSDictionary{
                                if let my_first =   fb_id_details["first_name"] as? String{
                                    
                                    first_name = my_first
                                }
                                
                                if let my_last =   fb_id_details["last_name"] as? String{
                                    
                                    last_name = my_last
                                }
                                
                                if let my_pic =   fb_id_details["profile_pic"] as? String{
                                    profile_pic = my_pic
                                }
                                if let my_user =   fb_id_details["username"] as? String{
                                    username = my_user
                                }
                            }
                            
                            
                            let obj = Notifications(effected_fb_id:effected_fb_id,first_name: first_name, last_name: last_name,profile_pic: profile_pic, v_id: v_id, username: username,type:type,fb_id: fb_id,Vvalue:Vvalue, thum: thumb)
                            
                            
                            self.Notifications_Array.add(obj)
                            
                            
                        }
                        
                        if(self.Notifications_Array.count == 0){
                            self.outer_view.alpha = 1
                        }else{
                            self.outer_view.alpha = 0
                            self.tableview.delegate = self
                            self.tableview.dataSource = self
                            self.tableview.reloadData()
                        }
                        
                    }
                    
                }else{
                    
                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
            case .failure(let error):
                print(error)
            //    HomeViewController.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
        
        
    }
    
    // Tableview Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.Notifications_Array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:NotificationTableViewCell = self.tableview.dequeueReusableCell(withIdentifier: "NotificationTableViewCell") as! NotificationTableViewCell
        
        let obj = self.Notifications_Array[indexPath.row] as! Notifications
        
        cell.lblName.text = obj.username
        if(obj.type == "video_like"){
            
            cell.lblMsg.text = obj.first_name+" liked your video"
            // cell.foolow_btn_view.alpha = 1
        }else{
            
            cell.lblMsg.text = obj.first_name+" just started following you"
            //   cell.foolow_btn_view.alpha = 0
        }
        
        if obj.v_id == ""{
            cell.videoImg.isHidden = true
            cell.btnPlay.isHidden = true
            cell.playImg.isHidden = true
            
        }else{
            cell.videoImg.sd_setImage(with: URL(string:obj.thum), placeholderImage: UIImage(named:"liveBanner1"))
        }
    
        
        
        cell.user_img.sd_setImage(with: URL(string:obj.profile_pic), placeholderImage: UIImage(named:"nobody_m.1024x1024"))
        cell.userView.layer.cornerRadius = cell.userView.frame.width / 2
        cell.userView.layer.borderWidth = 1.5
        // cell.follow_img.layer.cornerRadius = cell.follow_img.frame.size.width / 2
        cell.user_img.clipsToBounds = true
        
        // cell.follow_view.layer.cornerRadius = cell.follow_view.frame.size.width / 2
        cell.userView.clipsToBounds = true
        
        //              cell.foolow_btn_view.layer.cornerRadius = 5
        //              cell.foolow_btn_view.clipsToBounds = true
        //
        cell.btnPlay.tag = indexPath.item
        cell.btnPlay.addTarget(self, action: #selector(NotificationViewController.connected(_:)), for:.touchUpInside)
        

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           
           return 140
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj = self.Notifications_Array[indexPath.row] as! Notifications
        
        if(obj.fb_id != UserDefaults.standard.string(forKey: "uid")!){
            
            StaticData.obj.other_id = obj.fb_id
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let yourVC: Profile1ViewController = storyboard.instantiateViewController(withIdentifier: "Profile1ViewController") as! Profile1ViewController
            
            self.navigationController?.pushViewController(yourVC, animated: true)
        }else{
            
            self.tabBarController?.selectedIndex = 3
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if (Notifications_Array.count != 1) {
//            // print("frind count",friends_array.count)
//            if indexPath.row > Notifications_Array.count-1{ //numberofitem count
//                updateNextSet()
//            }
//        }
//    }
    
    @objc func connected(_ sender : UIButton) {
           
           print(sender.tag)
                       
           let buttonTag = sender.tag
      
        let obj = self.Notifications_Array[buttonTag] as! Notifications
//        StaticData.obj.userName = obj.first_name+" "+obj.last_name
//                 StaticData.obj.userImg = obj.profile_pic
//                 StaticData.obj.liked = "0"
//                 StaticData.obj.like_count = "0"
//                 StaticData.obj.soundName = "0"
//                 StaticData.obj.videoID = obj.v_id
//                StaticData.obj.other_id = obj.fb_id
//                 DispatchQueue.main.async {
//
//                     let vc = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverVideoViewController") as! DiscoverVideoViewController
//
//                     self.present(vc, animated: true, completion: nil)
//                 }
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.showAllVideosNew!
                     
                    let  sv = HomeViewController.displaySpinner(onView: self.view)
        let parameter :[String:Any]? = ["fb_id":obj.fb_id!,"video_id":obj.v_id!,"device_token":"Null", "middle_name": self.appDelegate.middle_name]
                       
//                       print(url)
//                       print(parameter!)
                       
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
                                      //  return self.alertModule(title: "", msg: "Video is deleted by the user.")
                                        return
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
                                        StaticData.obj.share = count["share"] as? String
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
                                                vc.fbId = UserDefaults.standard.string(forKey: "uid") ?? ""
                                                vc.videoId = obj.v_id
                                                vc.fromScreen = "Notification"
                                            
                                                self.navigationController?.pushViewController(vc, animated: true)
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
    
    
    
    @IBAction func GoogleLogin(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    
    private func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        //UIActivityIndicatorView.stopAnimating()
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
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
    
    @IBAction func phoneNologin(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: LoginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func Applelogin(_ sender: Any) {
        
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
        
    }
    extension NotificationViewController: ASAuthorizationControllerDelegate {
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
//                                      }else{
//
//                                       self.alertModule(title:"Error", msg: "Please share your email.")
//                                   }
             return
            }
            //TODO: Perform user login given User ID
            
            
            
            
          }
          
        @available(iOS 13.0, *)
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            print("Authorization returned an error: \(error.localizedDescription)")
          }
        }
        extension NotificationViewController: ASAuthorizationControllerPresentationContextProviding {
            @available(iOS 13.0, *)
            func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return view.window!
          }
    }
