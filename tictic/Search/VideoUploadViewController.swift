//
//  VideoUploadViewController.swift
//  TIK TIK
//
//  Created by Apple on 18/07/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import NextLevel
import AVKit
import Alamofire
import Regift
import MobileCoreServices

//protocol VideoUploadVCDelegate {
//    func DismissVC()
//}

class VideoUploadViewController: UIViewController ,PrivacyVCDelegate, HashTagListVCDelegate {
    
    
    func sendList(val: String) {
        print(val)
        self.discTextField.textColor = .white
        if discTextField.text == "  Add Description"{
            self.discTextField.text = ""
            self.discTextField.text =  val
        }else{
            self.discTextField.text = self.discTextField.text + val
        }
    }
    
    
    func sendString(val: String) {
        lblPrivacy.text = val
    }
    
    //  var delegate : VideoUploadVCDelegate?
    var videoUrl:URL?
    var base64videoUrl:String!
    var mediaType = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var allowComment = true
    var allowDuet = "1"
    var descText :String = ""
    var videoId : String? = ""
    
    @IBOutlet weak var bgView: UIView!
    
   // @IBOutlet weak var discTextField: UITextField!
    @IBOutlet weak var discTextField: UITextView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var saveVideoBtn: UIButton!
    @IBOutlet weak var videoPostBtn: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    @IBOutlet weak var commentSwitch: UISwitch!
    @IBOutlet weak var duetSwitch: UISwitch!
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var draftArr : [URL] = []
    var fromDraftVC = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(self.videoId)
        self.navigationController?.navigationBar.isHidden = true
        discTextField.text = "  Add Description"
        discTextField.textColor = UIColor.gray
        discTextField.delegate = self
        let placesData = UserDefaults.standard.object(forKey: "Draft") as? NSData

        if let placesData = placesData {
            draftArr = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as! [URL]
            print(draftArr)
        }
        let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
        self.videoPostBtn.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("VideoUrl ----\(videoUrl)")
        print("mediaType ----\(mediaType)")
        
        if fromDraftVC == true{
            
            saveVideoBtn.isHidden = true
        }
        
        if let urldata = videoUrl
        {
            if let thumbnailImage = getThumbnailImage(forUrl: urldata) {
                videoImageView.image = thumbnailImage
            }
            
        }
    }
    
    //MARK: Video post
    @IBAction func videoPostBtnAction(_ sender: Any) {
        if draftArr.isEmpty == false{
        if let index = draftArr.firstIndex(of: videoUrl!) {
            draftArr.remove(at: index)
        }
            let draftData = NSKeyedArchiver.archivedData(withRootObject: draftArr)
            UserDefaults.standard.set(draftData, forKey: "Draft")
        }
        self.loader.isHidden = false
        self.loader.startAnimating()
        videoPostBtn.isEnabled = false
        print("videoUrl",videoUrl!)
        
        //        if let url = videoUrl
        //        {
        //        var imageData11: Data? = nil
        //         //let url = URL(fileURLWithPath: url)
        //         imageData11 = try? Data(contentsOf: videoUrl!)
        //         let base64NewData = imageData11?.base64EncodedString()
        
        self.sendDataToServer()
        //        }
        
    }
    
    
    @IBAction func saveVideoBtnAction(_ sender: Any) {
        
        if let url = videoUrl
            
        {
            UISaveVideoAtPathToSavedPhotosAlbum(
                url.path,
                self,
                #selector(video(_:didFinishSavingWithError:contextInfo:)),
                nil)
        }
        
    }
    
    @IBAction func onTapDraft(_ sender: Any) {
        
        draftArr.append(videoUrl!)
        let draftData = NSKeyedArchiver.archivedData(withRootObject: draftArr)
        UserDefaults.standard.set(draftData, forKey: "Draft")
        
        let placesData = UserDefaults.standard.object(forKey: "Draft") as? NSData

        if let placesData = placesData {
            draftArr = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as! [URL]
            print(draftArr)
        }
        
        UserDefaults.standard.set(true, forKey: "DraftSave")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        print("video path ------\(videoPath)")
        
        showAlertMethod(title: title, message: message, response: "Video")
        
        //        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        //        present(alert, animated: true, completion: nil)
        
        
        
        
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
    
    func json(from object:Any) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return ""
        }
        return String(data: data, encoding: String.Encoding.utf8)!
    }
    
    
    
    func sendDataToServer()
    {
        // let sv = HomeViewController.displaySpinner(onView: self.view)
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.uploadVideo!
        var parameter :[String:Any] = [:]
        
        var hashArr : [String] = discTextField.text.findMentionText()
       //  print(discTextField.text.findMentionText())
        var strArr : [String] = []
        for str in hashArr{
            strArr.append(str)
        }
        
       // print(strArr)
        
        var hashtags_json : [[String:String]] = []
        for a in strArr{
            var vc = a.replacingOccurrences(of: "#", with: "")
           // print(vc)
            hashtags_json.append(["name": vc])
        }
        
    //    print(hashtags_json)
        
       var json_Arra = self.json(from: hashtags_json)
      //  print(json_Arra)
        
        
        if discTextField.text == "  Add Description"{
            discTextField.text = ""
        }else{
//            let string = discTextField.text!
//            discTextField.text = string.replacingOccurrences(of: "#(?:\\S+)\\s?", with: " ", options: .regularExpression, range: nil)
        }
        
    
        if UserDefaults.standard.string(forKey: "audioUrl") == ""{
            parameter = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"sound_id":"null","description":discTextField.text ?? "" , "middle_name": self.appDelegate.middle_name, "privacy_type" : lblPrivacy.text ?? "Public", "allow_comments" : allowComment, "allow_duet" : allowDuet, "hashtags_json" : json_Arra, "duet": 0, "old_video_id" : self.videoId ?? ""]
        }else{
            parameter = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"sound_id":UserDefaults.standard.string(forKey: "sid")!,"description":discTextField.text ?? "", "middle_name": self.appDelegate.middle_name, "privacy_type" : lblPrivacy.text ?? "Public", "allow_comments" : allowComment, "allow_duet" : allowDuet, "hashtags_json" : json_Arra, "duet": 0, "old_video_id": self.videoId ?? ""]
        }
        print(url)
        print(parameter)
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111",
            "Content-type": "multipart/form-data"
        ]
        
        AF.upload(
            multipartFormData: { multipartFormData in
                
                multipartFormData.append(try! Data(contentsOf: self.videoUrl!), withName: "uploaded_file" , fileName: "uploaded_file", mimeType: "video/mp4")
                
                for (key, value) in parameter{
                    
                    multipartFormData.append((value as? String ?? "").data(using: .utf8 )!  , withName: key)
                }
                
            },
            to: url, method: .post , headers: headers)
            .response { resp in
                self.loader.stopAnimating()
                print("resp",resp)
                if resp.error == nil{
                    self.convertdataintojson(data: resp.data!)
                }else{
                    self.showAlertMethod(title: "Error", message: "Please wait or try again later!", response: "Not")
                }
                
                
            }
    }
    
    func convertdataintojson(data:Data){
        
        let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
       // print("json",json)
        let dic = json as! NSDictionary
        let code = dic["code"] as! NSString
        if(code == "200"){
            if let myCountry = dic["msg"] as? NSArray{
                
                
                if  let sectionData = myCountry[0] as? NSDictionary{
                    
                    let success = sectionData["response"] as? String ?? ""
                    self.showAlertMethod(title: "", message: success, response: "upload")
                }
            }
        }
        
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    func showAlertMethod(title:String,message:String, response:String)
    {
        
        // Create the alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            NSLog("OK Pressed")
            if response == "Not"
            {
                
            }else if response == "upload"{
                UserDefaults.standard.set(true, forKey: "Upload")
                self.navigationController?.popToRootViewController(animated: true)
                
                //            self.dismiss(animated: true, completion: {
                //            self.delegate?.DismissVC()
                //         })
            }else{
                self.navigationController?.popViewController(animated: true)
                
            }
        }
        //        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
        //            UIAlertAction in
        //            NSLog("Cancel Pressed")
        //        }
        
        // Add the actions
        alertController.addAction(okAction)
        //alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    //
    @IBAction func onTapCancel(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func videoRekognisation_Api(param:[String:Any])
    {
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.videoRekog!
        
        // print("BASE: \(baseStr)")
        print(url)
        //print(parameter)
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
        ]
        AF.request(url, method: .post, parameters: param, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            respones in
        })
    }
    
    @IBAction func onTapPrivacyBtn(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: PrivacyVC = storyboard.instantiateViewController(withIdentifier: "PrivacyVC") as! PrivacyVC
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func commentValueChanges(_ sender: UISwitch) {
        if sender.isOn{
            allowComment = true
        }else{
            allowComment = false
        }
    }
    
    @IBAction func duetValueChanged(_ sender: UISwitch) {
        if sender.isOn{
            allowDuet = "1"
        }else{
            allowDuet = "0"
        }
    }
    
    //MARK: On tap HashTag Button clicked
    @IBAction func onTapHashtags(_ sender: UIButton) {
        
            discTextField.resignFirstResponder()
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: HashTagListVC = storyboard.instantiateViewController(withIdentifier: "HashTagListVC") as! HashTagListVC
            vc.delegate = self
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        
    }
    
//    MARK: On tap friends Tag Button Clicked
    @IBAction func onTapFriendsTag(_ sender: UIButton) {
        

    }
    
}


extension VideoUploadViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "  Add Description"{
            textView.text = ""
        }
        textView.textColor = .white
        return true
    }
}

extension String {
    func findMentionText() -> [String] {
        var arr_hasStrings:[String] = []
        let regex = try? NSRegularExpression(pattern: "(#[a-zA-Z0-9_\\p{Arabic}\\p{N}]*)", options: [])
        if let matches = regex?.matches(in: self, options:[], range:NSMakeRange(0, self.count)) {
            for match in matches {
                arr_hasStrings.append(NSString(string: self).substring(with: NSRange(location:match.range.location, length: match.range.length )))
            }
        }
        return arr_hasStrings
    }
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

