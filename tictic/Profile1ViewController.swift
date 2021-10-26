

import UIKit
import Alamofire
import SDWebImage
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices
import CCBottomRefreshControl



class Profile1ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,GIDSignInDelegate{
    
    @IBOutlet weak var viewReport: UIView!
    @IBOutlet weak var btnBlock: UIButton!
    
    @IBOutlet weak var view_UserProfile: UIImageView!
    
    @IBOutlet weak var cancel_Profile_Btn: UIButton!
    @IBOutlet weak var user_Profile_View: UIView!
    
    @IBOutlet weak var inner_view: UIView!
    
    @IBOutlet weak var btn_send: UIButton!
    
    @IBOutlet weak var message_icon: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var btn_follow: UIButton!
    
    @IBOutlet weak var btn_menu: UIBarButtonItem!
    
    //@IBOutlet weak var video_view: UIView!
    
    @IBOutlet weak var outer_view: UIView!
    @IBOutlet weak var user_img: UIImageView!
    
    @IBOutlet weak var lbl_Desc: UILabel!
    
    @IBOutlet weak var lbl_follow: UILabel!
    
    @IBOutlet weak var lbl_fan: UILabel!
    
    @IBOutlet weak var lbl_heart: UILabel!
    
    @IBOutlet weak var viewMyVideos: UIView!
    @IBOutlet weak var viewLikeVideo: UIView!
    @IBOutlet weak var btnMyVideos: UIButton!
    @IBOutlet weak var btnLikeVideos: UIButton!
    @IBOutlet weak var profile_name: UILabel!
    
    @IBOutlet weak var collectionview: UICollectionView!
    
     @IBOutlet weak var lblTerms: UILabel!
    
    var isNotification = false
    var user_fb_id:String! = ""
    var first_name:String! = ""
    var last_name:String! = ""
    var email:String! = ""
    var my_id:String! = ""
    var profile_pic:String! = ""
    var signUPType:String! = ""
    
    var follow:String! = "0"
    var status:String! = ""
    
    var allVideos: [Videos] = []
    var offset : Int? = 0
    var total_VideoCount = 0
    var likeVideoCount : Int = 0
    var flagForProfile1Video = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
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
        
//        user_img.layer.masksToBounds = false
//        user_img.layer.cornerRadius = user_img.frame.height/2
//        user_img.clipsToBounds = true
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        user_img.isUserInteractionEnabled = true
        user_img.addGestureRecognizer(tapGestureRecognizer)
        
//        btn_follow.layer.cornerRadius = 15.0
//        btn_follow.clipsToBounds = true
//        btn_follow.layer.masksToBounds = false
        
        UserDefaults.standard.set(StaticData.obj.other_id, forKey: "fb_Id")
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
       
        
        let bottomRefreshController = UIRefreshControl()
        bottomRefreshController.triggerVerticalOffset = 50
        bottomRefreshController.addTarget(self, action: #selector(self.refreshBottom), for: .valueChanged)
        collectionview.bottomRefreshControl = bottomRefreshController
        collectionview.isPagingEnabled =  true
        let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
        self.btn_follow.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
        
        viewReport.layer.masksToBounds = false
        viewReport.layer.cornerRadius = viewReport.frame.height/2
        viewReport.clipsToBounds = true
    }
    
    //MARK: Refresher bottom
    @objc func refreshBottom() {
        print("refresh")
        if total_VideoCount == allVideos.count{
            
            self.collectionview.bottomRefreshControl?.endRefreshing()

        }else{
            if btnMyVideos.tag == 1{
                updateNextSet()
            }else if btnLikeVideos.tag == 1{
                updateNextSetLike()
            }
           
           
        }
    }

    
    //MARK: On user image tap action
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        user_Profile_View.isHidden = false
        // Your action
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = true
        UIApplication.shared.statusBarStyle = .default
       
      //  self.tabBarController?.tabBar.backgroundColor = .black
//        self.tabBarController?.tabBar.tintColor = UIColor.white
//        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor(red: 205, green: 205, blue: 205, alpha: 1)
        
        
        if(UserDefaults.standard.string(forKey: "uid") == ""){
            
            self.inner_view.alpha = 1
            
            self.navigationItem.title = "Login"
          //  self.tabBarController?.tabBar.isHidden = true
        }else{
            self.inner_view.alpha = 0
            self.navigationItem.title = "Profile"

            if flagForProfile1Video == true{
                self.allVideos = []
                self.getAllVideos(offset: self.offset!)
            }else{
                self.allVideos = []
                self.getLikeVideos(offset: self.offset!)
            }
           
        }
    }
    
    //MARK: Cancel view profile button clicked
    
    @IBAction func cancel_View_Profil(_ sender: Any) {
        
        user_Profile_View.isHidden = true
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
    
    //MARK: GET fb user data
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
    
    //MARK: get All videos api
    func getAllVideos(offset:Int?){
        
        flagForProfile1Video = true
        
        let id = UserDefaults.standard.string(forKey: "fb_Id")
        print("id",id)
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.showMyAllVideos!
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        let parameter :[String: Any]? = ["my_fb_id": UserDefaults.standard.string(forKey: "uid") ?? "", "fb_id": UserDefaults.standard.string(forKey: "fb_Id") ?? "", "middle_name": self.appDelegate.middle_name, "offset": String(offset ?? 0)]
        
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
                self.collectionview.bottomRefreshControl?.endRefreshing()
              //  self.allVideos = []
              //  print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
               
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        
                        
                        if  let sectionData = myCountry[0] as? NSDictionary{
                            
                            self.total_VideoCount = sectionData["total_video_count"] as? Int ?? 0
                            self.likeVideoCount = sectionData["total_like_count"] as? Int ?? 0

                            var tempProductList = ItemVideo()

                            let user_info = sectionData["user_info"] as? NSDictionary
                            let str1:String! = (user_info!["first_name"] as! String)
                            let str2:String! = (user_info!["last_name"] as! String)
                            self.my_id = user_info!["fb_id"] as? String
                            self.user_fb_id = user_info!["fb_id"] as? String
                            self.profile_pic = user_info!["profile_pic"] as? String
                            self.profile_name.text = str1+" "+str2
                            self.lbl_Desc.text = user_info!["username"] as? String
                            self.user_img.sd_setImage(with: URL(string:user_info!["profile_pic"] as! String), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
                            self.view_UserProfile.sd_setImage(with: URL(string:user_info!["profile_pic"] as! String), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
                            
                            self.lbl_follow.text = sectionData["total_following"] as? String
                            self.lbl_fan.text = sectionData["total_fans"] as? String
                            self.lbl_heart.text = String(sectionData["total_heart"] as? Int ?? 0)
//                            var count : Int = 0
//                            count = sectionData["total_video_count"] as! Int
                         //   self.lbl_video.text = String(count) + " Videos"
                            let follow_Status = sectionData["follow_Status"] as? NSDictionary
                            
                            self.follow = follow_Status!["follow"] as? String
                            
                            self.btn_follow.setTitle(follow_Status!["follow_status_button"] as? String, for: .normal)
                            
//                            if(self.btn_follow.title(for: .normal) == "Follow"){
//
//                                self.btn_send.alpha = 0
//                                self.message_icon.alpha = 0
//                            }else{
//
//                                self.btn_send.alpha = 1
//                                self.message_icon.alpha = 1
//                            }
                            self.follow = follow_Status!["follow"] as? String
                            
                            if(self.follow == "0"){
                                
                                self.status = "1"
                            }else{
                                self.status = "0"
                            }
                            
                            if let  myCountry1 = (sectionData["user_videos"] as? [[String:Any]]){
                                
                                if myCountry1.isEmpty || myCountry1.count == 0 || myCountry1 == nil{
                                    
                                }else{
                                for Dict in myCountry1 {
                                    
                                    
                                    
                                    let count = Dict["count"] as! NSDictionary
                                    let view = count["view"] as! String
                                    let thum = Dict["thum"] as! String
                                 
                                    let v_id = Dict["id"] as! String
                                    
                                    let first_name = user_info?["first_name"] as! String
                                    let last_name = user_info?["last_name"] as! String
                                    let profile_pic = user_info?["profile_pic"] as! String
                                    
                                    let follow_Status = sectionData["follow_Status"] as? NSDictionary
                                    
                                    self.follow = follow_Status!["follow"] as? String
                                    
                                  //  self.btn_follow.setTitle(follow_Status!["follow_status_button"] as? String, for: .normal)
                                    self.follow = follow_Status!["follow"] as? String
                                    
                                    if(self.follow == "0"){
                                        
                                        self.status = "1"
                                    }else{
                                        self.status = "0"
                                    }
                                    
                                    let u_id = user_info?["fb_id"] as! String

                                    let obj = Videos(thum: thum,first_name: first_name, last_name: last_name, profile_pic: profile_pic,v_id: v_id, view: view,u_id:u_id, approve_status: "0", video: "")
                                    
                                    if self.total_VideoCount == self.allVideos.count{
                                        
                                    }else{
                                        self.allVideos.append(obj)
                                    }
                                    
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
                       
                        self.btnMyVideos.setTitle("My Videos (\(String(self.total_VideoCount)))", for: .normal)
                        self.btnLikeVideos.setTitle("Like Videos (\(String(self.likeVideoCount)))", for: .normal)
                        
                        self.outer_view.alpha = 0
                        
                        self.collectionview.delegate = self
                        self.collectionview.dataSource = self
                        self.collectionview.reloadData()
                    }
                    
                }else{
                    
                    self.alertModule(title:"Error", msg:dic["msg"] as? String ?? "Some Thing Went Wrong")
                }
                
                
                
            case .failure(let error):
                print(error)
                HomeViewController.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
        
    }
    
    // get Like videos api
    func getLikeVideos(offset:Int?){
    
        flagForProfile1Video = false
        
        let id = UserDefaults.standard.string(forKey: "fb_Id")
        print("id",id)
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.my_liked_video!
    let  sv = HomeViewController.displaySpinner(onView: self.view)
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "fb_Id") ?? "", "middle_name": self.appDelegate.middle_name, "offset": String(offset ?? 0)]

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
               // print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? NSArray{
                        
                        
                        if  let sectionData = myCountry[0] as? NSDictionary{
                            self.likeVideoCount = sectionData["total_video_count"] as? Int ?? 0
//                            self.btnMyVideos.setTitle("My Videos (\(String(self.total_VideoCount)))", for: .normal)
//                            self.btnLikeVideos.setTitle("Like Videos (\(String(self.likeVideoCount)))", for: .normal)
                            
                            let user_info = sectionData["user_info"] as? NSDictionary
                            let str1:String! = (user_info!["first_name"] as! String)
                            let str2:String! = (user_info!["last_name"] as! String)
                            self.navigationItem.title = str1+" "+str2
                            
                            self.user_img.sd_setImage(with: URL(string:user_info!["profile_pic"] as! String), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
                            self.view_UserProfile.sd_setImage(with: URL(string:user_info!["profile_pic"] as! String), placeholderImage: UIImage(named: "nobody_m.1024x1024"))                            //  self.lbl_follow.text = sectionData["total_following"] as? String
                            //  self.lbl_fan.text = sectionData["total_fans"] as? String
                            //  self.lbl_heart.text = sectionData["total_heart"] as? String
                            
                            if let myCountry1 = sectionData["user_videos"] as? [[String:Any]]{
                                
                                if myCountry1.isEmpty || myCountry1.count == 0 || myCountry1 == nil{
                                    
                                }else{
                              
                                for Dict in myCountry1 {
                                    
                                    let count = Dict["count"] as! NSDictionary
                             
                                    let view = count["view"] as? String
                                    let thum = Dict["thum"] as? String
                                 
                                    let v_id = Dict["id"] as? String
                                    let u_id = Dict["fbid"] as? String ?? ""
            
                                    let obj = Videos(thum: thum, first_name: "", last_name: "", profile_pic: "",v_id: v_id, view: view, u_id: u_id, approve_status: "0", video: "")
                                    
                                    self.allVideos.append(obj)
                                }
                               }
                            }
                        }
                    }
                    
                    if(self.allVideos.count == 0){
                    
                        self.btnMyVideos.setTitle("My Videos (\(String(self.total_VideoCount)))", for: .normal)
                        self.btnLikeVideos.setTitle("Like Videos (0)", for: .normal)
                        
                        self.outer_view.alpha = 1
                        self.collectionview.delegate = self
                        self.collectionview.dataSource = self
                        self.collectionview.reloadData()
                        
                    }else{
                        
                        self.btnMyVideos.setTitle("My Videos (\(String(self.total_VideoCount)))", for: .normal)
                        self.btnLikeVideos.setTitle("Like Videos (\(String(self.likeVideoCount)))", for: .normal)
                        
                        self.outer_view.alpha = 0
                        self.collectionview.delegate = self
                        self.collectionview.dataSource = self
                        self.collectionview.reloadData()
                    }
                    
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
    
    // Collection View Delegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.allVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:ProfileCell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "cellProfile", for: indexPath) as! ProfileCell
        let obj = self.allVideos[indexPath.item]
        cell.lbl_seen.text = obj.view
//        cell.contentView.setGradientBackgroundImage(colorTop: UIColor.clear, colorBottom: UIColor(displayP3Red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1))
//        cell.video_image.setGradientBackgroundImage(colorTop: UIColor.clear, colorBottom: UIColor(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1))

        cell.video_image.sd_setImage(with: URL(string:obj.thum), placeholderImage: UIImage(named:"placeholderImg"))
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // let obj = self.allVideos as! Videos
         
         let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         let vc: DiscoverVideoViewController = storyboard.instantiateViewController(withIdentifier: "DiscoverVideoViewController") as! DiscoverVideoViewController
 //        if indexPath.row > 0{
 //            let range = 0...(indexPath.row - 1)
 //            self.allVideos.removeSubrange(range)
 //        }
 //        vc.friends_array = self.allVideos
        vc.fbId = self.allVideos[indexPath.row].u_id
         vc.videoId = self.allVideos[indexPath.row].v_id
        vc.position = indexPath.row
        if flagForProfile1Video == true{
            
            vc.type = "profile"
        }else{

            vc.type = "mylikevideos"
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row > allVideos.count {  //numberofitem count
            updateNextSet()
        }
    }

   func updateNextSet(){
        self.offset =  self.offset! + 15
        self.getAllVideos(offset: self.offset)
           //requests another set of data (20 more items) from the server.
    }

    func updateNextSetLike(){
         self.offset =  self.offset! + 10
        self.getLikeVideos(offset: self.offset!)
            //requests another set of data (20 more items) from the server.
     }
    
    //MARK: Video change
    @IBAction func videoChange(_ sender: Any) {
        self.getAllVideos(offset: self.offset)
        self.btnMyVideos.titleLabel?.font =  UIFont(name: "Poppins-Medium", size: 13)
        self.btnLikeVideos.titleLabel?.font =  UIFont(name: "Poppins-Regular", size: 13)
        self.btnMyVideos.setTitleColor(UIColor.white, for: .normal)
        self.btnLikeVideos.setTitleColor(UIColor.gray, for: .normal)
       
    }
    
    @IBAction func likeChange(_ sender: Any) {
        
        self.getLikeVideos(offset: self.offset!)
        self.btnLikeVideos.titleLabel?.font =  UIFont(name: "Poppins-Medium", size: 13)
        self.btnMyVideos.titleLabel?.font =  UIFont(name: "Poppins-Regular", size: 13)
        self.btnMyVideos.setTitleColor(UIColor.gray, for: .normal)
        self.btnLikeVideos.setTitleColor(UIColor.white, for: .normal)
    
    }
    
    @IBAction func options(_ sender: Any) {
        
        let actionSheet =  UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Edit Profile", style: .default, handler: {
            (_:UIAlertAction)in
            
            
            
            self.performSegue(withIdentifier:"gotoedit", sender: self)
            
        })
        
        let gallery = UIAlertAction(title: "Logout", style: .destructive, handler: {
            (_:UIAlertAction)in
            
            UserDefaults.standard.set("", forKey: "uid")
            self.navigationItem.title = "Profile"
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.tabBarController?.selectedIndex = 1
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (_:UIAlertAction)in
            
        })
        actionSheet.addAction(camera)
        
        actionSheet.addAction(gallery)
        //actionSheet.addAction(Giphy)
        actionSheet.addAction(cancel)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    // Gmail Login Api
    
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
    
    func SignUpApi(){
        
        
        
        let  sv = HomeViewController.displaySpinner(onView: self.view)
        
        var VersionString:String! = ""
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            VersionString = version
        }
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.signUp!
        
        let parameter:[String:Any]?  = ["fb_id":self.my_id!,"first_name":self.first_name!,"last_name":self.last_name!,"profile_pic":self.profile_pic!,"gender":"m","signup_type":self.signUPType!,"version":VersionString!,"device":"iOS", "latitude" : UserDefaults.standard.value(forKey: "Latitude") ?? "", "longitude" : UserDefaults.standard.value(forKey: "Longitude") ?? "", "referral_fb_id": UserDefaults.standard.value(forKey: "referral_fb_id") ?? ""]
        
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
                        
                        
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.inner_view.alpha = 0
                        
                        self.btn_menu.tintColor = UIColor.white
                        
                        self.getAllVideos(offset: self.offset)
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
    
    @IBAction func phoneNologin(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: LoginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    @IBAction func close(_ sender: Any) {
        
        self.allVideos = []
        
        if isNotification == true{
            self.dismiss(animated: true, completion: nil)
        }else{
      //  flagForProfile1Video = false
        navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func follow(_ sender: Any) {
        
        self.FollowApi()
    }
    
    // Follow Api
    
    func FollowApi(){
        
        let sv = HomeViewController.displaySpinner(onView: self.view)
        
        self.view.isUserInteractionEnabled = false
        let url : String = appDelegate.baseUrl!+appDelegate.follow_users!
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey:"uid")!,"followed_fb_id":UserDefaults.standard.string(forKey: "fb_Id")!,"status":status!, "middle_name": self.appDelegate.middle_name]
        
//        print(url)
//        print(parameter!)
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
            
        ]
        
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                self.view.isUserInteractionEnabled = true
                HomeViewController.removeSpinner(spinner: sv)
                let json  = value
                
                
              //  print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    let myCountry = dic["msg"] as? NSArray
                    if let data = myCountry![0] as? NSDictionary{
                        print(data)
                        
                        
                        if(self.status == "0"){
                            
                            self.btn_follow.setTitle("Follow", for: .normal)
                            self.status = "1"
                           
                        }else{
                            self.status = "0"
                            self.btn_follow.setTitle("UnFollow", for: .normal)
                          
                        }
                    
                    }
                    
                }else{
                    
                    self.alertModule(title: "Error", msg: dic["msg"] as? String ?? "error occured.")
                    
                }
                
                
                
            case .failure(let error):
                
                self.view.isUserInteractionEnabled = true
                HomeViewController.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
        
        
        
    }
    
    
    @IBAction func report(_ sender: Any) {
        
        let actionSheet =  UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Report "+profile_name.text!, style: .default, handler: {
            (_:UIAlertAction)in
            
        })
        
        let gallery = UIAlertAction(title: "Block", style: .destructive, handler: {
            (_:UIAlertAction)in
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (_:UIAlertAction)in
            
        })
        actionSheet.addAction(camera)
        
        //actionSheet.addAction(gallery) // hide for temp
        //actionSheet.addAction(Giphy)
        actionSheet.addAction(cancel)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        
        StaticData.obj.receiver_id = self.my_id
        StaticData.obj.receiver_name =  self.profile_name.text
        StaticData.obj.receiver_img = self.profile_pic
        UserDefaults.standard.set(self.profile_name.text!, forKey: "Username")
        UserDefaults.standard.set(self.profile_pic, forKey: "image_url")
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        //self.view.window!.layer.add(transition, forKey: kCATransition)
        
        present(vc, animated: false)
    }
    
    @IBAction func onTapFollowers(_ sender: Any) {
           
         let vc = self.storyboard?.instantiateViewController(withIdentifier: "Following1ViewController") as! Following1ViewController
           vc.fbId = self.my_id
           self.navigationController?.pushViewController(vc, animated: true)
       }
    
    @IBAction func onTapFollowing(_ sender: Any) {
             
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowingViewController") as! FollowingViewController
            vc.fbId = self.my_id
           self.navigationController?.pushViewController(vc, animated: true)
         }
    
    @IBAction func onTapBlock(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Alert", message: "Are you sure you want to block this user?", preferredStyle: .alert)
        
        let okalertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
          
            
            let url : String = self.appDelegate.baseUrl!+self.appDelegate.blockUser
            let  sv = HomeViewController.displaySpinner(onView: self.view)
            let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid") ?? "", "middle_name": self.appDelegate.middle_name, "user_id": self.my_id!, "block":"1"]

//            print(url)
//            print(parameter!)
            
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
                        let alertController = UIAlertController(title: "Blocked!!", message: "User blocked successfully.", preferredStyle: .alert)
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
            
        })
        let cancelalertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            
        })
        alertController.addAction(okalertAction)
        alertController.addAction(cancelalertAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension Profile1ViewController: ASAuthorizationControllerDelegate {
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
extension Profile1ViewController: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
