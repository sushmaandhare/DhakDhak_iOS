//
//  UseSoundVC.swift
//  TIK TIK
//
//  Created by Apple on 27/08/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import Photos


class UseSoundVC: UIViewController {
//    func DismissUseSoundVC() {
//        self.dismiss(animated: true, completion: nil)
//        self.tabBarController?.selectedIndex = 4
//    }

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var videoImgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
//    @IBOutlet weak var saveView: UIView!
//    @IBOutlet weak var creatView: UIView!
    @IBOutlet weak var btnCreate: UIButton!
    
    var audioString = ""
    var videoUrl = ""
    var videoImg = ""
    var audioTitle = ""
    var desc = ""
    var videoId = ""
    var soundId = ""
    var soundName = ""
    var player:AVPlayer?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var audioUrl : URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        // Do any additional setup after loading the view.
        //
        let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
        self.btnCreate.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
        self.btnCreate.layer.cornerRadius = 15.0
        self.btnCreate.clipsToBounds = true
        
       let url = URL(string: videoImg)
       let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        videoImgView.image = UIImage(data: data!)
        //videoImgView.image = UIImage(named: videoImg)
        lblTitle.text = audioTitle
        lblDesc.text = desc
        
//        saveView.layer.borderColor = UIColor.white.cgColor
//
//        saveView.layer.cornerRadius = 10.0
//        creatView.layer.cornerRadius = 10.0
//
//        saveView.layer.borderWidth = 0.5
       
        if let url = URL(string:audioString) {
            let  sv = UseSoundVC.displaySpinner(onView: self.view)
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
           // print(destinationUrl)
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                do {
                    try FileManager.default.removeItem(at: destinationUrl)
                    print("The file deleted from existing path")
                } catch let error as NSError {
                    print("Error: \(error.domain)")
                }
                UseSoundVC.removeSpinner(spinner: sv)
                // if the file doesn't exist
            }
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                     UseSoundVC.removeSpinner(spinner: sv)
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                        
                    } catch let error as NSError {
                     UseSoundVC.removeSpinner(spinner: sv)
                        print(error.localizedDescription)
                    }
                }).resume()
                self.audioUrl = destinationUrl
            
        }
    }
    
    @IBAction func onTapDismiss(_ sender: UIButton) {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapPlay(_ sender: UIButton) {
        if let audioUrl = audioUrl{
            let playerItem = AVPlayerItem( url: audioUrl)
            player = AVPlayer(playerItem:playerItem)
            player!.rate = 1.0;
            if sender.tag == 0{
                sender.tag = 1
                sender.setImage(UIImage(named: "ic_pause_icon"), for: .normal)
                player?.play()
            }else if sender.tag == 1{
                sender.tag = 0
                sender.setImage(UIImage(named: "ic_play_icon"), for: .normal)
                player?.pause()
            }
        }else{
            sender.isHidden = true
        }
        
    }
    
    @IBAction func onTapSave(_ sender: UITapGestureRecognizer) {
        let url : String = self.appDelegate.baseUrl!+self.appDelegate.downloadFile!
        
        let  sv = UseSoundVC.displaySpinner(onView: self.view)
        let parameter :[String:Any]? = ["video_id": videoId, "middle_name": self.appDelegate.middle_name]
        
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
                
                
                
                // self.Follow_Array = []
               // print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    if let myCountry = dic["msg"] as? [[String:Any]]{
                        
                        for Dict in myCountry {
                            if  let my_id =   Dict["download_url"] as? String{
                                
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
                                                    UseSoundVC.removeSpinner(spinner: sv)
                                                    print("Succesfully Saved")
                                                } else {
                                                    UseSoundVC.removeSpinner(spinner: sv)
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
                print(error)
                UseSoundVC.removeSpinner(spinner: sv)
                self.alertModule(title:"Error",msg:error.localizedDescription)
            }
        })
        
    }
    
    @IBAction func onTapCreate(_ sender: Any) {
       let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: RecorderVC = storyboard.instantiateViewController(withIdentifier: "RecorderVC") as! RecorderVC
        player?.pause()
        vc.audioPath = self.audioUrl
        vc.audioName = self.soundName
      //  vc.fromUseSound = true
        UserDefaults.standard.set(soundId, forKey: "sid")
        //self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    
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

extension UseSoundVC {
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

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
