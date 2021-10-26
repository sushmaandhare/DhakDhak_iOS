//
//  ViewController.swift
//  IOS-Swift-VideoRecorder01
//
//  Created by Pooya on 2018-03-12.
//  Copyright © 2018 Pooya Hatami. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices

class ViewController1
: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    internal var flipButton: UIButton?
    internal var flashButton: UIButton?
    
     var cameraView: UIView!
    
    @IBOutlet weak var RecordButton: UIButton!
    var SaveVideo = 0
    var videoAndImageReview = UIImagePickerController()
    var videoURL: URL?
    
     let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func RecordAction(_ sender: UIButton) {
        
        SaveVideo = 1
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            print("Camera Available")
            
            cameraView = UIView()
           
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.allowsEditing = true
            imagePicker.videoMaximumDuration = 16
            imagePicker.cameraOverlayView = self.addOverlay()
            
           
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            print("Camera UnAvaialable")
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
      
        
        
        
        dismiss(animated: true, completion: nil)
        
//        guard
//            let mediaType = info[UIImagePickerController] as? String,
//            mediaType == (kUTTypeMovie as String),
//            let url = info[UIImagePickerControllerMediaURL] as? URL,
//            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
//            else {
//                return
//        }
//
         
        
        
        // Handle a movie capture
     
//        UISaveVideoAtPathToSavedPhotosAlbum(
//            url.path,
//            self,
//            #selector(video(_:didFinishSavingWithError:contextInfo:)),
//            nil)
       // }
    }
    
    func addOverlay() -> UIView? {
       // self.addSilhouette(cameraView)
        self.addCameraButton(cameraView)
       // self.addSkipButton(imagePicker)
       // cameraView.frame = self.view.frame
       // cameraView.tag = 101
        return cameraView
    }
    
    func addCameraButton(_ cameraView: UIView){
           let button = UIButton(type: .custom)
         // button.setImage(UIImage(named: "camera"), for: .normal)
        button.setTitle("Add Sound", for: .normal)
           button.isUserInteractionEnabled = true
       // button.frame = CGRect(x: self.view.frame.size.width - 100, y: 50, width: 40, height: 40)
        button.frame =  CGRect(x: view.frame.size.width - 110, y: 5, width: 100, height: 30)
        //button.backgroundColor = .red
        button.addTarget(self, action: #selector(self.didPressShootButton), for: .touchUpInside)
           cameraView.addSubview(button)
       }
    
    @IBAction func didPressShootButton(){
        //myCamera.takePicture()
        
        print("sound btn clicked -----")
        
        
    }
    
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"
        
        print("video path ------\(videoPath)")
        
        var imageData11: Data? = nil
       let url = URL(fileURLWithPath: videoPath)
        
           imageData11 = try? Data(contentsOf: url)
           //}
           
           let base64NewData = imageData11?.base64EncodedString()
        
        print("base64data -----------\(base64NewData)")
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
  
    @IBAction func openImgVideoPicker() {
        
         SaveVideo = 0
        
        videoAndImageReview.sourceType = .savedPhotosAlbum
        videoAndImageReview.delegate = self
        videoAndImageReview.mediaTypes = ["public.movie"]
        present(videoAndImageReview, animated: true, completion: nil)
    }
    
    func videoAndImageReview(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
       // videoURL = info[UIImagePickerControllerMediaURL] as? URL
       // print("videoURL:\(String(describing: videoURL))")
        self.dismiss(animated: true, completion: nil)
    }

}
