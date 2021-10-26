//
//  DiscoverCategoriesVC.swift
//  TIK TIK
//
//  Created by Apple on 12/10/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit
import Alamofire
import VersaPlayer
import AVKit
import DSGradientProgressView
import SDWebImage
import MarqueeLabel
import Photos
import CCBottomRefreshControl
import MediaWatermark

class DiscoverCategoriesVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSourcePrefetching,UIGestureRecognizerDelegate,UITextViewDelegate{
    
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var out_view: UIView!
    @IBOutlet weak var txt_comment: UITextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var observer:Any?
    var selectedIndex:Int! = 0
    var index:Int! = 0
    var video_id:String! = "0"
    var video_type:String! = "related"
    var avplayer:AVPlayer?
    var friends_array:[ItemVideo] = []
    var comments_array:NSMutableArray = []
    var sound_array:NSMutableArray = []
    private var indexOfCellBeforeDragging = 0
    var descripton = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        hideKeyboardWhenTappedAround()
        // self.view.setGradientBackground(colorOne: .darkGray, colorTwo: .lightGray)
        self.collectionview.isPagingEnabled = true
        
    UserDefaults.standard.set("0", forKey: "sid")
        
        if(UserDefaults.standard.string(forKey: "uid") == nil){
            
            UserDefaults.standard.set("", forKey: "uid")
        }
        
        let layout = UICollectionViewFlowLayout()
        // let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionview.showsVerticalScrollIndicator = false
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0)
        self.collectionview.contentInset = UIEdgeInsets(top:-20, left: 0, bottom:0, right: 0)
        
        self.collectionview.collectionViewLayout = layout
        
        self.tableview.tableFooterView = UIView()
    
     
    }

        @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }

        @objc func keyboardWillHide(notification: NSNotification) {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    
    @objc func videoDidEnd(notification: NSNotification) {
   
        let visiblePaths = self.collectionview.indexPathsForVisibleItems
        
        for i in visiblePaths  {
            let cell = collectionview.cellForItem(at: i) as? homecollCell
            cell!.player!.seek(to: CMTime.zero)
            cell!.player?.play()
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
      return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
        flag = false
        UIApplication.shared.isStatusBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = true
//        self.tabBarController?.tabBar.tintColor = UIColor.white
//        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor(red: 205, green: 205, blue: 205, alpha: 1)
        NotificationCenter.default.addObserver(self, selector: #selector(DiscoverCategoriesVC.videoDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

    }
 
    
    override func viewWillDisappear(_ animated: Bool) {
        
        UIApplication.shared.isStatusBarHidden = false
        
        let visiblePaths = self.collectionview.indexPathsForVisibleItems
        for i in visiblePaths  {
            let cell = collectionview.cellForItem(at: i) as? homecollCell
            cell!.player!.pause()
            
            cell!.playBtn.setImage(UIImage(named:"ic_play_icon"), for: .normal)
            cell!.playBtn.isHidden = false
            
            
            
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avplayer?.currentItem)

    }
    
    // Collection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.friends_array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:homecollCell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "homecollCell", for: indexPath) as! homecollCell
        //cell.player?.pause()
        
        let obj = self.friends_array[indexPath.row]
       
        let url = URL.init(string: obj.video)

        let screenSize: CGRect = UIScreen.main.bounds
        cell.playerItem = AVPlayerItem(url: url!)
        //cell.player!.replaceCurrentItem(with: cell.playerItem)
//        if let profileUrl = URL(string: obj.profile_pic) {
//            let data = try? Data(contentsOf: profileUrl) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//            if let profData = data{
//                cell.cdProfileImg.image = UIImage(data: profData)
//            }
//        }
        
        
       // cell.cdProfileImg.image = UIImage(named: obj.profile_pic)
        cell.cdProfileImg.layer.cornerRadius = cell.cdProfileImg.layer.frame.height / 2
        cell.cdProfileImg.clipsToBounds = true
        cell.btnCD.tag = indexPath.item
        cell.btnCD.addTarget(self, action: #selector(DiscoverCategoriesVC.onTapCD(_:)), for:.touchUpInside)
       
        cell.player = AVPlayer(playerItem: cell.playerItem!)
        cell.playerLayer = AVPlayerLayer(player: cell.player!)
        cell.playerLayer!.frame = CGRect(x:0,y:0,width:screenSize.width,height: screenSize.height)
        cell.playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cell.playerView.layer.addSublayer(cell.playerLayer!)
      
        cell.playerView.layer.backgroundColor = UIColor.black.cgColor
        cell.playBtn.tag = indexPath.item
         cell.btnshare.tag = indexPath.item
        cell.playBtn.addTarget(self, action: #selector(DiscoverCategoriesVC.connected(_:)), for:.touchUpInside)
        
        cell.btn_like.tag = indexPath.item
        cell.btn_like.addTarget(self, action: #selector(DiscoverCategoriesVC.connected2(_:)), for:.touchUpInside)
        
        cell.btn_comments.tag = indexPath.item
        cell.btn_comments.addTarget(self, action: #selector(DiscoverCategoriesVC.connected3(_:)), for:.touchUpInside)
        
        cell.btnshare.addTarget(self, action: #selector(DiscoverCategoriesVC.connected1(_:)), for:.touchUpInside)
        
       cell.btnView.tag = indexPath.item
       cell.btnView.addTarget(self, action: #selector(DiscoverCategoriesVC.onTapViewCount(_:)), for:.touchUpInside)
        
        cell.other_profile.tag = indexPath.item
        cell.other_profile.addTarget(self, action: #selector(DiscoverCategoriesVC.connected4(_:)), for:.touchUpInside)
        
        var des = obj.description
        print("des",des)
        cell.txtDesc.text = des
        cell.user_name.tag = indexPath.item
        cell.btnUserName.addTarget(self, action: #selector(DiscoverCategoriesVC.connected4(_:)), for:.touchUpInside)
        cell.txtDesc.resolveHashTags()
        cell.txtDesc.delegate = self
//        cell.btn_foryou.tag = indexPath.item
//         cell.btn_foryou.addTarget(self, action: #selector(DiscoverCategoriesVC.connected5(_:)), for:.touchUpInside)
//
//        cell.btn_following.tag = indexPath.item
//        cell.btn_following.addTarget(self, action: #selector(DiscoverCategoriesVC.connected6(_:)), for:.touchUpInside)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        
        cell.inner_view.addGestureRecognizer(tap)
        
        cell.inner_view.isUserInteractionEnabled = true
        
        cell.inner_view.tag = indexPath.item
        
//        if(self.video_type == "following"){
//
//            cell.btn_foryou.setTitleColor(UIColor.lightGray, for: .normal)
//            cell.btn_following.setTitleColor(UIColor.white, for: .normal)
//        }else{
//
//            cell.btn_foryou.setTitleColor(UIColor.white, for: .normal)
//           cell.btn_following.setTitleColor(UIColor.lightGray, for: .normal)
//        }
        
       // cell.user_view.layer.cornerRadius = 5.0
        //cell.user_view.clipsToBounds = true
        
        if(obj.first_name != nil || obj.last_name != nil){
        
        cell.user_name.text = obj.first_name
        }
        cell.user_name.textDropShadow()
        if(obj.profile_pic != nil){
        cell.user_img.sd_setImage(with: URL(string:obj.profile_pic), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
        cell.cdProfileImg.sd_setImage(with: URL(string:obj.profile_pic), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
        }
        //cell.user_img.layer.masksToBounds = false
        cell.user_img.layer.cornerRadius = cell.user_img.frame.height/2
        cell.user_img.clipsToBounds = true
        cell.user_img.layer.borderColor = UIColor.white.cgColor
        cell.user_img.layer.borderWidth = 1.0
       // cell.other_profile.layer.masksToBounds = false
        //cell.other_profile.layer.cornerRadius = cell.user_img.frame.height/2
       // cell.other_profile.clipsToBounds = true
        
        if(obj.sound_name != nil){
            
            cell.music_name.text = "original sound - " + obj.sound_name
        }
        cell.lblLikeCount.text = String(obj.like_count)
        cell.lblCommentCount.text = obj.video_comment_count
        cell.lblViewCount.text = obj.view_count
        cell.lblShareCount.text = obj.share
       // cell.img.sd_setImage(with: URL(string:self.appDelegate.imgbaseUrl!+obj.thum), placeholderImage: UIImage(named: ""))
        
        if(obj.liked == "0"){
            
            cell.btn_like.setBackgroundImage(UIImage(named:"ic_like"), for: .normal)
        }else{
            cell.btn_like.setBackgroundImage(UIImage(named:"ic_like_fill"), for: .normal)
        }
        
     //   print("is follow",obj.isFollow)
        if (obj.is_follow == "1"){
          //  print("is follow",obj.is_follow)
            cell.btnVerification.isHidden = true
        }else{
         //   print("is follow",obj.is_follow)
            cell.btnVerification.isHidden = false
        }
    
        cell.btnVerification.tag = indexPath.item
        cell.btnVerification.addTarget(self, action: #selector(HomeViewController.onTapVerification(_:)), for:.touchUpInside)
        
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
           
           longPressedGesture.delegate = self
           cell.addGestureRecognizer(longPressedGesture)
        
        return cell
        
    }
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        let p = gesture.location(in: self.collectionview)
        if let indexPath : NSIndexPath = self.collectionview.indexPathForItem(at:p) as NSIndexPath?{
          //do whatever you need to do
          if (gesture.state == .began) {
            let actionSheet = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title:"Save Video", style: .default, handler: {
              (_:UIAlertAction)in
              let url : String = self.appDelegate.baseUrl!+self.appDelegate.downloadFile!
                let obj = self.friends_array[indexPath.row]
              let sv = DiscoverCategoriesVC.displaySpinner(onView: self.view)
              let parameter :[String:Any]? = ["video_id":obj.v_id!,"middle_name": self.appDelegate.middle_name]
             // print(url)
              //print(parameter!)
              let headers: HTTPHeaders = [
               "api-key":"4444-3333-2222-1111"
              ]
              AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
                respones in
                switch respones.result {
                case .success( let value):
                  let json = value
                  // self.Follow_Array = []
                 // print(json)
                  let dic = json as! NSDictionary
                  let code = dic["code"] as! NSString
                  if(code == "200"){
                    if let myCountry = dic["msg"] as? [[String:Any]]{
                      for Dict in myCountry {
                        if let my_id =  Dict["download_url"] as? String{
                          let url = URL.init(string: my_id)
                          let date = Date()
                          let formatter = DateFormatter()
                          formatter.dateFormat = "dd.MM.yyyy"
                          let result = formatter.string(from: date)
                          DispatchQueue.global(qos: .background).async {
                            if let url = URL(string: my_id), let urlData = NSData(contentsOf: url) {
                              let galleryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                              let filePath = "\(galleryPath)/dhakdhak.mp4"
                              DispatchQueue.main.async {
                                urlData.write(toFile: filePath, atomically: true)
                                PHPhotoLibrary.shared().performChanges({
                                  PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:
                                    URL(fileURLWithPath: filePath))
                                }) {
                                  success, error in
                                  if success {
                                    DiscoverCategoriesVC.removeSpinner(spinner: sv)
                                   // print("Succesfully Saved")
                                  } else {
                                    DiscoverCategoriesVC.removeSpinner(spinner: sv)
                                    self.alertModule(title:"Error", msg: error!.localizedDescription)
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }else{
                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                  }
                case .failure(let error):
                 // print(error)
                  DiscoverCategoriesVC.removeSpinner(spinner: sv)
                  self.alertModule(title:"Error",msg:error.localizedDescription)
                }
              })
            })
           
            let cancel = UIAlertAction(title:"Cancel", style: .cancel, handler: {
              (_:UIAlertAction)in
            })
            let obj = self.friends_array[indexPath.row]
            actionSheet.addAction(camera)
            if UserDefaults.standard.string(forKey: "uid")! == obj.u_id{
            
            }
            actionSheet.addAction(cancel)
            self.present(actionSheet, animated: true, completion: nil)
          }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let obj = friends_array[indexPath.item]
        if let comedyCell = cell as? homecollCell {

            index = indexPath.row
            
            comedyCell.playBtn.isHidden = true
            
            comedyCell.player?.play()
        
            comedyCell.player!.addObserver(self, forKeyPath:"timeControlStatus", options: [.old, .new], context: nil)
            
           // print(obj.video_url!)

        }

    }
    

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let visiblePaths = self.collectionview.indexPathsForVisibleItems
        for i in visiblePaths  {
            let cell = collectionview.cellForItem(at: i) as? homecollCell
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
           
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
         
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                 
                    if newStatus == .playing || oldStatus == .paused  {
                      
                        cell?.progressView.signal()
                        cell?.progressView.isHidden = true
                       
                    } else {
                         cell?.progressView.wait()
                        cell?.progressView.isHidden = false
                    }
                }
            }
        }
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let comedyCell = cell as? homecollCell {
            index = indexPath.row
            comedyCell.player!.pause()
          
            
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        return CGSize(width: screenSize.width, height: screenSize.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]){
        
        for indexPath in indexPaths {
            /*
             Updating upcoming CollectionView's data source. Not assiging any direct value
             */
            
            let tempObj = self.friends_array[indexPath.row]
            self.friends_array[indexPath.row] = tempObj
           
        }
    }
    
    // indexPaths that previously were considered as candidates for pre-fetching, but were not actually used; may be a subset of the previous call to -collectionView:prefetchItemsAtIndexPaths:
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]){
      
        
        for indexPath in indexPaths {
            self.friends_array.remove(at: indexPath.row)
        }
    }
    
    
    //MARK: Scroll view delegates
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.collectionview.visibleCells.forEach { cell in
            if let indexPath = collectionview.indexPathsForVisibleItems.first {
                print("current index pTH",indexPath.item)
               
                let obj = friends_array[indexPath.item]
                  if let cell = cell as? homecollCell {
                    index = indexPath.row
                    cell.playBtn.isHidden = true
                    cell.player?.rate = 1.0
                    cell.img.image = UIImage(named: obj.thum)
                    cell.player?.pause()
                    cell.player!.addObserver(self, forKeyPath:"timeControlStatus", options: [.old, .new], context: nil)
        
                  }

            print("collection brgin scroll")
            }
            // TODO: write logic to stop the video before it begins scrolling
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.collectionview.visibleCells.forEach { cell in
            print("collection did end scroll")
            
            if let indexPath = collectionview.indexPathsForVisibleItems.first {
                
                print("current index end  pTH",indexPath.row)
                
                let obj = friends_array[indexPath.item]
                    if let cell = cell as? homecollCell {
                            index = indexPath.row
                            cell.playBtn.isHidden = true
                            cell.player?.rate = 1.0
                            cell.img.image = UIImage(named: obj.thum)
                            cell.player?.play()
                            cell.player!.addObserver(self, forKeyPath:"timeControlStatus", options: [.old, .new], context: nil)
                          }
                }
            // TODO: write logic to start the video after it ends scrolling
        }
    }
    
    @objc func onTapCD(_ sender: UIButton) {
        if(UserDefaults.standard.string(forKey: "uid") == ""){
            
            self.alertModule(title:"", msg: "Please login into the app.")
            
        }else{
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: UseSoundVC = storyboard.instantiateViewController(withIdentifier: "UseSoundVC") as! UseSoundVC
            let obj = self.friends_array[sender.tag]
            
            vc.audioTitle = obj.f_name + "" + obj.last_name
            vc.audioString = obj.audio_url
            vc.soundName = obj.sound_name
            vc.soundId = obj.s_id ?? "null"
            vc.videoImg = obj.thum
            vc.desc = obj.description
            vc.videoId = obj.v_id
            //        vc.modalPresentationStyle = .fullScreen
            //        self.present(vc, animated: true, completion: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func connected1(_ sender : UIButton)
    {
        /* //print(sender.tag)
         
         let text1 = "Don't be a miser when it comes to Talent, Spend your talent like a Millionaire!! Hit the share button and share your post with your social handles!! Download from below:"
         
         let objectsToShare:URL = URL(string: "https://bit.ly/dhakdhak")!
         let sharedObjects:[AnyObject] = [text1 as AnyObject,objectsToShare as AnyObject]
         let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
         //  activityViewController.popoverPresentationController?.sourceView = self.view
         
         //  activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail]
         
         self.present(activityViewController, animated: true, completion: {
         self.shareApi(id: obj.v_id)
         })*/
        if(UserDefaults.standard.string(forKey: "uid") == ""){
            
             self.alertModule(title:"", msg: "Please login into the app.")
            
        }else{
        let buttonTag = sender.tag
         //   self.view.showLoading()
           // let outputURL = NSURL.fileURL(withPath: "TempPath")
            let sv = HomeViewController.displaySpinner(onView: self.view)
            let obj = self.friends_array[buttonTag]
            //saveVideo(id: obj.v_id, isShare : true)
                if let item = MediaItem(url: URL(string: obj.video)!) {
                    let logoImage = UIImage(named: "trademark")
                            
                    let firstElement = MediaElement(image: logoImage!)
                    firstElement.frame = CGRect(x: 10, y: 100, width: logoImage!.size.width, height: logoImage!.size.height)
                            
                    let testStr = obj.first_name
                    let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25) ]
                    let attrStr = NSAttributedString(string: testStr, attributes: attributes)
                            
                    let secondElement = MediaElement(text: attrStr)
                    secondElement.frame = CGRect(x:10, y: 60, width: 300, height: 30)
                            
                    item.add(elements: [firstElement, secondElement])
                            
                    let mediaProcessor = MediaProcessor()
                    mediaProcessor.processElements(item: item) { [weak self] (result, error) in
    //                    self?.videoPlayer.url = result.processedUrl
    //                    self?.videoPlayer.playFromBeginning()
                        DispatchQueue.main.async {
                            
                        let objectsToShare = [result.processedUrl] //comment!, imageData!, myWebsite!]
                        let activityVC = UIActivityViewController(activityItems: objectsToShare as [Any], applicationActivities: nil)
                       

                        activityVC.setValue("Video", forKey: "subject")
                            ////                                        activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                            ////                                            if !completed {
                            ////                                                // User canceled
                            ////                                                return
                            ////                                            }
                            ////                                            var sharetypestr = ""
                            ////                                            // User completed activity
                            ////                                            switch activityType! {  // See UIActivity.ActivityType
                            ////                                            case .postToTwitter:
                            ////                                                 sharetypestr = "11"
                            ////                                            case .airDrop:
                            ////                                                sharetypestr = "11"
                            ////                                            case .mail:
                            ////                                                sharetypestr = "2"
                            ////                                            case .postToFacebook:
                            ////                                                sharetypestr = "5"
                            ////                                            case .message :
                            ////                                                sharetypestr = "4"
                            ////                                            default:
                            ////                                                sharetypestr = "11"
                            ////                                            }
                            ////                                            print(activityType?.rawValue)
                            ////                                            self.shareApi(id: id, type: sharetypestr)
                            ////
                            ////                                        }
                         HomeViewController.removeSpinner(spinner: sv)
                        //New Excluded Activities Code
                        if #available(iOS 9.0, *) {
                         activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print]
                        } else {
                            // Fallback on earlier versions
                         activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print ]
                        }

                        //    self?.view.stopLoading()
                        self?.present(activityVC, animated: true, completion: nil)
                        //    self?.shareApi(id: obj.v_id, type: <#String#>)
                    }
                }
            }
        }
    }

    @objc func connected(_ sender : UIButton) {
       // print(sender.tag)
        
        let buttonTag = sender.tag
        
        let indexPath = IndexPath(row: buttonTag, section: 0)
        let cell = collectionview.cellForItem(at: indexPath) as! homecollCell
        if(cell.playBtn.currentImage == UIImage(named: "ic_play_icon")){
            cell.playBtn.setImage(UIImage(named:"ic_pause_icon"), for: .normal)
           // cell.playBtn.setBackgroundImage(UIImage(named:"ic_pause_icon"), for: .normal)
            cell.player?.play()
            cell.playBtn.isHidden = true
            
        }
        
    }
    
    @objc func connected3(_ sender : UIButton) {
        
        if(UserDefaults.standard.string(forKey: "uid") == ""){
            
             self.alertModule(title:"", msg: "Please login into the app.")
            
        }else{
        //print(sender.tag)
        
        self.out_view.alpha = 1
        
        UIView.animate(withDuration: 0.5, animations: {
            //print(self.out_view.frame.origin.y)
            
            
            
            self.out_view.frame = CGRect(x: 0, y:UIScreen.main.bounds.height-340 , width: self.view.frame.width, height: self.view.frame.height)
            
            
            
        },  completion: { (finished: Bool) in
        
        let buttonTag = sender.tag
            
            
       
            let obj = self.friends_array[buttonTag]
        self.video_id = obj.v_id
        
            self.getComents()
        })
        
        }
    }
    
    //MARK: Connected 4 action
    @objc func connected4(_ sender : UIButton) {
       // print(sender.tag)
        
        let buttonTag = sender.tag
        let obj = self.friends_array[buttonTag]
     
        
        let actionSheet =  UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        let camera1 = UIAlertAction(title: "View Profile", style: .default, handler: {
                          (_:UIAlertAction)in
            
            if(obj.u_id != UserDefaults.standard.string(forKey: "uid")!){
                    
                     StaticData.obj.other_id = obj.u_id
                     let storyboard = UIStoryboard(name: "Main", bundle: nil)
                     let yourVC: Profile1ViewController = storyboard.instantiateViewController(withIdentifier: "Profile1ViewController") as! Profile1ViewController
                yourVC.status = "1"
                     // self.present(yourVC, animated: true, completion: nil)
                     self.navigationController?.pushViewController(yourVC, animated: true)
                     //self.present(yourVC , animated: true, completion: nil)
                
                 }else{
                     self.tabBarController?.selectedIndex = 3
                 }
            })
        
            let camera = UIAlertAction(title: "Report "+obj.first_name, style: .default, handler: {
                     (_:UIAlertAction)in
            
                let videoId = obj.v_id
                print("videoId",videoId)
                self.popUpController(videoiD: videoId ?? "0")
            
            })
                 
                 let gallery = UIAlertAction(title: "Block", style: .destructive, handler: {
                     (_:UIAlertAction)in
                     
                 })
                 
                 let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                     (_:UIAlertAction)in
                     
                 })
        
                 actionSheet.addAction(camera1)
                 actionSheet.addAction(camera)
                // actionSheet.addAction(gallery)
                 //actionSheet.addAction(Giphy)
                 actionSheet.addAction(cancel)
                 self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func onTapVerification(_ sender: UIButton) {
       if(UserDefaults.standard.string(forKey: "uid") == ""){
           
           self.alertModule(title:"", msg: "Please login into the app.")
           
       }else{
        let buttonTag = sender.tag
        let obj = self.friends_array[buttonTag]
        StaticData.obj.other_id = obj.u_id
        UserDefaults.standard.set(StaticData.obj.other_id, forKey: "fb_Id")
        let indexPath = IndexPath(row: buttonTag, section: 0)
        let cell = collectionview.cellForItem(at: indexPath) as! homecollCell
        
        let sv = DiscoverCategoriesVC.displaySpinner(onView: self.view)
        
        self.view.isUserInteractionEnabled = false
        let url : String = appDelegate.baseUrl!+appDelegate.follow_users!
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey:"uid")!,"followed_fb_id":UserDefaults.standard.string(forKey: "fb_Id")!,"status":"1", "middle_name": self.appDelegate.middle_name]
        
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
                DiscoverCategoriesVC.removeSpinner(spinner: sv)
                let json  = value
                
                
              //  print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    let myCountry = dic["msg"] as? NSArray
                    if let data = myCountry![0] as? NSDictionary{
                        print(data)
                        
                        cell.btnVerification.isHidden = true
                        self.alertModule(title: "", msg: "User has been followed successfully.")
                    }
                    
                }else{
                    
                    self.alertModule(title: "Error", msg: dic["msg"] as? String ?? "error occured.")
                    
                }
                
                
                
            case .failure(let error):
                
                self.view.isUserInteractionEnabled = true
                DiscoverCategoriesVC.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
        
        }
        
    }
    
    //MARK: POPUpcontroller
    func popUpController(videoiD:String)
        {
            let alertController = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertController.Style.alert)

            let margin:CGFloat = 8.0
            let rect = CGRect(x: margin, y: margin, width: alertController.view.bounds.size.width - margin * 4.0, height: 100.0)
            let customView = UITextView(frame: rect)
            
            customView.text = "Write your report here"
            customView.textColor = UIColor.lightGray
            customView.delegate = self
            customView.backgroundColor = UIColor.clear
            customView.textColor = UIColor.white
            customView.font = UIFont(name: "Helvetica", size: 15)
            //  customView.backgroundColor = UIColor.greenColor()
            alertController.view.addSubview(customView)

            let somethingAction = UIAlertAction(title: "Report", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in
                
                print("something")
                print(customView.text)
                self.reportUser_API(reportText: customView.text, videoId: videoiD)
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {(alert: UIAlertAction!) in print("cancel")})

            alertController.addAction(somethingAction)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion:{})
        }
    
    
    //MARK:  get Like videos api
    func reportUser_API(reportText:String,videoId:String){
           
           let id = UserDefaults.standard.string(forKey: "fb_Id")
           print("id",id)
           
           let url : String = self.appDelegate.baseUrl!+self.appDelegate.reportUser
           
           let  sv = DiscoverCategoriesVC.displaySpinner(onView: self.view)
           let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "fb_Id") ?? "","video_id": videoId,"comment":reportText]

//           print(url)
//           print(parameter!)
           
           let headers: HTTPHeaders = [
               "api-key": "4444-3333-2222-1111"
           ]
           
           AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
               
               respones in
               print(respones)
               
               switch respones.result {
               case .success( let value):
                
                   
                   let json  = value
                   DiscoverCategoriesVC.removeSpinner(spinner: sv)
                 //  print(json)
                   
                   let dic = json as! NSDictionary
                   let code = dic["code"] as! NSString
                   
                   if(code == "200"){
                     
                      print("Report User Done")
                      let msg = dic["msg"] as! String
                      self.alertModule(title: "", msg: "\(msg)")
                       
                   }else{
                       
                       self.alertModule(title:"Error", msg:dic["msg"] as? String ?? "error occured")
                   }
               case .failure(let error):
                   print(error)
                   DiscoverCategoriesVC.removeSpinner(spinner: sv)
                   self.alertModule(title:"Error",msg:error.localizedDescription)
               }
           })
       }
    
    
    //MARK: Texi view delegates method
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write your report here"
            textView.textColor = UIColor.lightGray
        }
    }
    
    @objc func connected2(_ sender : UIButton) {
        //print(sender.tag)
        
        var action:String! = ""
        
        
        if(UserDefaults.standard.string(forKey: "uid") == ""){
                  
            self.alertModule(title:"", msg: "Please login into the app.")
                  
    }else{
        let buttonTag = sender.tag
        let indexPath = IndexPath(row: buttonTag, section: 0)
        let cell = collectionview.cellForItem(at: indexPath) as? homecollCell
            var obj = self.friends_array[buttonTag]
        
        if(obj.liked == "0"){
            
            action = "1"
            
            cell?.btn_like.setBackgroundImage(UIImage(named:"ic_like"), for: .normal)
         
        }else{
            
          
            cell?.btn_like.setBackgroundImage(UIImage(named:"ic_like_fill"), for: .normal)
            action = "0"
        }
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.likeDislikeVideo!
        
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"video_id":obj.v_id!,"action":action!, "middle_name": self.appDelegate.middle_name]
        
//        print(url)
//        print(parameter!)

        let headers: HTTPHeaders = [
                "api-key": "4444-3333-2222-1111"
            ]
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:nil).validate().responseString(completionHandler: {
                
            respones in

           // print(respones)
                
            let jsondata = respones.data
            //print("jsondata",jsondata)
                
            switch respones.result {
                
            case .success (let value):
                
                let json  = value
        
             //   print(json)
               
             //   let dic = json as! NSDictionary
                
            //    let code = dic["code"] as! NSString
              //  if(code == "200"){
             
                   obj.liked = action
                   
                    
                    if(obj.liked == "0"){
                    
                        
                        cell?.btn_like.setBackgroundImage(UIImage(named:"ic_like"), for: .normal)
                        
                        if(Int(obj.like_count)! > 0){
                            
                            let str:Int! = Int(obj.like_count)! - 1
                            obj.like_count = String(str)
                            
                            cell?.lblLikeCount.text = String(obj.like_count)
                            
                        }
                        
                    }else{
                        
                        let str:Int! = Int(obj.like_count)! + 1
                        obj.like_count = String(str)
                        
                       cell?.lblLikeCount.text = String(obj.like_count)
                        cell?.btn_like.setBackgroundImage(UIImage(named:"ic_like_fill"), for: .normal)
                    }
                    
                    
              //  }else{
                    
                    
                    
             //   }
                
            case .failure(let error):
                print("error",error)
            }
        })
        }
        
    }
       
    @objc func onTapViewCount(_ sender : UIButton) {
        
    }
    
    func parseJSON(_ data: Data) -> [String: Any]? {

                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let body = json["data"] as? [String: Any] {
                            return body
                        }
                    } catch {
                        print("Error deserializing JSON: \n\(error)")
                        return nil
                    }
                    return nil
                }//    @objc func connected5(_ sender : UIButton) {
//
//        let buttonTag = sender.tag
//        let indexPath = IndexPath(row: buttonTag, section: 0)
//        let cell = collectionview.cellForItem(at: indexPath) as! homecollCell
//        cell.btn_following.setTitleColor(UIColor.lightGray, for: .normal)
//        cell.btn_foryou.setTitleColor(UIColor.white, for: .normal)
//        self.video_type = "for you"
//        self.showAllVideos()
//    }
//
//    @objc func connected6(_ sender : UIButton) {
//
//          let buttonTag = sender.tag
//          let indexPath = IndexPath(row: buttonTag, section: 0)
//          let cell = collectionview.cellForItem(at: indexPath) as! homecollCell
//          cell.btn_foryou.setTitleColor(UIColor.lightGray, for: .normal)
//          cell.btn_following.setTitleColor(UIColor.white, for: .normal)
//        self.video_type = "following"
//
//        self.showAllVideos()
//
//      }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
    
        
        let myview = sender.view
        let buttonTag = myview?.tag
        let indexPath = IndexPath(row: buttonTag!, section: 0)
        let cell = collectionview.cellForItem(at: indexPath) as! homecollCell
        if(cell.playBtn.currentImage == UIImage(named: "ic_pause_icon")){
  
            
            cell.playBtn.setImage( UIImage(named: "ic_play_icon"), for: .normal)
            cell.playBtn.isHidden = false
            cell.player?.pause()
        }
    }
    
  
    
    
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//
//        let visiblePaths = self.collectionview.indexPathsForVisibleItems
//        for i in visiblePaths  {
//            let cell = collectionview.cellForItem(at: i) as? homecollCell
//
//            if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
//                let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
//                let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
//                if newStatus != oldStatus {
//                    DispatchQueue.main.async {[weak self] in
//                        if newStatus == .playing || newStatus == .paused {
//
//                            cell?.progressView.signal()
//                            cell?.progressView.alpha = 0
//                        } else {
//                            cell?.progressView.alpha = 1
//                           cell?.progressView.wait()
//                        }
//                    }
//                }
//            }
//        }
//
//    }
    
   
    
    @IBAction func cross(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // Get All comments Api
    
    func getComents() {
        
        
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.showVideoComments!
        let  sv = DiscoverCategoriesVC.displaySpinner(onView: self.out_view)
        
        
        let parameter :[String:Any]? = ["video_id":self.video_id!, "middle_name": self.appDelegate.middle_name]
        
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
                
                DiscoverCategoriesVC.removeSpinner(spinner: sv)
                
                self.comments_array = []
               // print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    let myCountry = (dic["msg"] as? [[String:Any]])!
                    for Dict in myCountry {
                        
                        let myRestaurant = Dict as NSDictionary
                        var comments:String! = ""
                        var v_id:String! = ""
                        var first_name:String! = ""
                        var last_name:String! = ""
                        var profile_pic:String! = ""
                        var c_time:String! = ""
                        if let comm =  myRestaurant["comments"] as? String{
                            
                            comments = comm
                        }
                        if let created =  myRestaurant["created"] as? String{
                                                                              
                                                                              c_time = created
                                                                          }
                        if let myID =  myRestaurant["video_id"] as? String{
                            
                            v_id = myID
                        }
                        if let u_info = myRestaurant["user_info"] as? NSDictionary{
                        if let myFirest =  u_info["first_name"] as? String{
                            
                            first_name = myFirest
                        }
                        if let myLast =  u_info["last_name"] as? String{
                            
                            last_name = myLast
                        }
                        if let myPic =  u_info["profile_pic"] as? String{
                            
                            profile_pic = myPic
                        }
                           
                        }
                      
                      
                        
                        let obj = Comment(comments: comments, first_name: first_name, last_name: last_name,profile_pic: profile_pic, v_id: v_id, c_time: c_time)
                        
                        self.comments_array.add(obj)
                        
                        
                        
                    }
                    
                    self.comments_array = NSMutableArray(array: self.comments_array.reversed())
                    
                    //obj.video_comment_count = String(str)
                   // cell.btn_comments.setTitle(obj.video_comment_count, for: .normal)                    self.tableview.delegate = self
                    self.tableview.dataSource = self
                    self.tableview.reloadData()
                    if(self.comments_array.count > 0){
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: self.comments_array.count-1, section: 0)
                        self.tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                    }
                    
                }else{
                    
                    self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
                
                
            case .failure(let error):
               // print(error)
                DiscoverCategoriesVC.removeSpinner(spinner: sv)
                self.alertModule(title:"Network Issue",msg:"Please try after some time.")
            }
        })
    }
    
    
    // Send Comment Api
    @IBAction func sendComment(_ sender: Any) {
       
        
        if(txt_comment.text != ""){
            
            
             let obj = friends_array[index]
            
            let url : String = self.appDelegate.baseUrl!+self.appDelegate.postComment!
            
            let  sv = DiscoverCategoriesVC.displaySpinner(onView: self.out_view)
            
            let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"video_id":self.video_id!,"comment":self.txt_comment.text!, "middle_name": self.appDelegate.middle_name]
            
//            print(url)
//            print(parameter!)
            
            let headers: HTTPHeaders = [
                "api-key": "4444-3333-2222-1111"
                
            ]
            
            AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseString(completionHandler: {
                
                respones in
                
                switch respones.result {
                case .success( let value):
                    
                    let json  = value
                    DiscoverCategoriesVC.removeSpinner(spinner: sv)
               //     print(json)
                //    let dic = json as! NSDictionary
                //    let code = dic["code"] as! NSString
                //    if(code == "200"){
                      self.txt_comment.text = ""
    
                  //  .btn_comments.setTitle(obj.video_comment_count, for: .normal)
                        self.getComents()
                      //  }else{
                       // self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    //}
                    
                case .failure(let error):
                   // print(error)
                    DiscoverCategoriesVC.removeSpinner(spinner: sv)
                    self.alertModule(title:"Error",msg:error.localizedDescription)
                }
            })
        }
        
    }
    
    // Tableview Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CommentTableViewCell = self.tableview.dequeueReusableCell(withIdentifier: "cell01", for: indexPath) as! CommentTableViewCell
        
        let obj = self.comments_array[indexPath.row] as! Comment
        
        cell.comment_title.text = obj.first_name+" "+obj.last_name
        
        cell.comment_name.text = obj.comments
        
        cell.comment_img.sd_setImage(with: URL(string:obj.profile_pic), placeholderImage: UIImage(named: "nobody_m.1024x1024"))
        
        
//        let date = Date()
//               let formatter = DateFormatter()
//               formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//               let result = formatter.string(from: date)
//        let str = self.timeCalculate(dateString:result , dateString1: obj.c_time)
//        print(str)
//        cell.comment_time.text = str
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func timeCalculate(dateString:String,dateString1:String) -> String{
           
           let calendar = Calendar.current
           
           // Get input(date) from textfield
           
           let isoDate = dateString
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           let date = dateFormatter.date(from:isoDate)!
           
           let isoDate1 = dateString1
           let dateFormatter1 = DateFormatter()
           dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
           let date1 = dateFormatter1.date(from:isoDate1)!
           
           let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
           let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: date1);
           
           let seconds = "\(difference.second ?? 0)s"
           let minutes = "\(difference.minute ?? 0)m"
           let hours = "\(difference.hour ?? 0)h" + " " + minutes
           let days = "\(difference.day ?? 0)d" + " " + hours
           
           if let day = difference.day, day          > 0 { return days }
           if let hour = difference.hour, hour       > 0 { return hours }
           if let minute = difference.minute, minute > 0 { return minutes }
           if let second = difference.second, second > 0 { return seconds }
           return ""
           
    }
    
    @IBAction func onTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension DiscoverCategoriesVC {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView(frame: UIScreen.main.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            
            UIApplication.shared.keyWindow!.addSubview(spinnerView)
            UIApplication.shared.keyWindow!.bringSubviewToFront(spinnerView)
            onView.bringSubviewToFront(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    
    
    
    
    
}
