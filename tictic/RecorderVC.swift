//
//  RecorderVC.swift
//  TIK TIK
//
//  Created by Apple on 30/07/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import Foundation
import UIKit
import CameraManager
import CoreServices
import AVKit
import AVFoundation
import SwiftVideoGenerator
//protocol RecorderVCDelegate {
//    func DismissUseSoundVC()
//}

class RecorderVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TimerVCDelegate {
    func NotifyDismiss(videoUrl: URL) {
        viewSound.isUserInteractionEnabled = false
        if videoUrl.fileSize <= 60000000{
            self.btnUpload.isUserInteractionEnabled = true
            self.btnUpload.setImage(UIImage(named: "ic_upload"), for: .normal)
            let audioUrl = UserDefaults.standard.string(forKey: "audioUrl")
            if audioUrl != "" {
                mergeFilesWithUrl(videoUrl: videoUrl, audioUrl: URL(string: audioUrl!)!)
            }else if audioPath != nil{
                mergeFilesWithUrl(videoUrl: videoUrl, audioUrl: audioPath!)
            }else{
                myVideoURL = videoUrl
            }
            
        }else{
            let alertController = UIAlertController(title: "Alert", message: "Please upload file less than 60Mb", preferredStyle: .alert)
            let okalertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(okalertAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func sendTimerValue(timeVal: Float) {
        self.time = 0
        self.lblCounter.text = "0"
     counter = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        blurredView.isHidden = false
        lblCounter.isHidden = false
        counterTime = timeVal
    }
    
    @objc func updateTimer() {
        self.time = self.time + 1
        print(self.time)
        lblCounter.text = String(self.time)
        if self.time == 5 {
            counter?.invalidate()
           blurredView.isHidden = true
            lblCounter.isHidden = true
            self.onTapRecordBtn(btnCamera)
            
        }
       
    }
    
    let cameraManager = CameraManager()
//    var delegate : RecorderVCDelegate?
    @IBOutlet weak var lblSoundName: UILabel!
    var time = 0
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var blurredView: UIView!
    @IBOutlet weak var speedView: UIView!
    @IBOutlet weak var btnSlowThreeX: UIButton!
    @IBOutlet weak var btnSlowTwoX: UIButton!
    @IBOutlet weak var btnOneX: UIButton!
    @IBOutlet weak var btnFastThreeX: UIButton!
    @IBOutlet weak var btnFastTwoX: UIButton!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var flashModeImageView: UIImageView!
    @IBOutlet var dismissImageView: UIImageView!
    @IBOutlet var cameraTypeImageView: UIImageView!
    @IBOutlet var timerImageView: UIImageView!
    @IBOutlet var qualityLabel: UILabel!
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet var btnGallary: UIButton!
    @IBOutlet weak var viewSound: UIView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var btnUpload: UIButton!
    
    @IBOutlet weak var speedImgView: UIImageView!
    @IBOutlet weak var qualityImgView: UIImageView!
    @IBOutlet var cameraLabel: UILabel!
    @IBOutlet var flashLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet weak var btnSound: UIButton!
    @IBOutlet var reverseImgView: UIImageView!
    @IBOutlet var lblReverse: UILabel!
    
  //  var fromUseSound = false
    var videoAndImageReview = UIImagePickerController()
    var myVideoURL: URL!
    var timer: Timer?
    var player:AVPlayer?
    var audioPath:URL? = nil
    var audioName:String? = ""
    var counter: Timer?
    var counterTime : Float = 0.0
    var videoSpeed : Double = 1.0
    var videosArr : [URL] = []
    var isReverse = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // print(audioPath)
        self.tabBarController?.tabBar.isHidden = true
        btnGallary.setImage(UIImage(named: "ic_gallary"), for: .normal)
        UserDefaults.standard.set("", forKey: "audioUrl")
        UserDefaults.standard.set("", forKey: "soundId")
         UserDefaults.standard.set("", forKey: "sound_name")
       UserDefaults.standard.set(nil, forKey: "finalVideo")
        UserDefaults.standard.set(nil, forKey: "finalReverseVideo")
        if cameraManager.hasFlash {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeFlashMode))
            flashModeImageView.addGestureRecognizer(tapGesture)
        }
        
        let outputGesture = UITapGestureRecognizer(target: self, action: #selector(timerButtonTapped))
        timerImageView.addGestureRecognizer(outputGesture)
        
        let cameraTypeGesture = UITapGestureRecognizer(target: self, action: #selector(changeCameraDevice))
        cameraTypeImageView.addGestureRecognizer(cameraTypeGesture)
        
        qualityLabel.isUserInteractionEnabled = true
        let qualityGesture = UITapGestureRecognizer(target: self, action: #selector(changeCameraQuality))
        qualityLabel.addGestureRecognizer(qualityGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseTap(_:)))
        dismissImageView.addGestureRecognizer(tap)
       
        let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
        self.btnSound.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videosArr = []
        if UserDefaults.standard.bool(forKey: "Upload") == true {
            myVideoURL = nil
            UserDefaults.standard.set("", forKey: "audioUrl")
            UserDefaults.standard.set("", forKey: "soundId")
            UserDefaults.standard.set(nil, forKey: "finalVideo")
            UserDefaults.standard.set("", forKey: "sound_name")
            UserDefaults.standard.set(nil, forKey: "mergedVideo")
            UserDefaults.standard.set(nil, forKey: "finalReverseVideo")
            
            self.tabBarController?.selectedIndex = 0
        }else if UserDefaults.standard.bool(forKey: "DraftSave") == true{
            self.tabBarController?.selectedIndex = 4
        }
        
        if(UserDefaults.standard.string(forKey: "uid") == ""){
            let alertController = UIAlertController(title: "DhakDhak", message: "Please login from profile to upload video!", preferredStyle: .alert)
            let okalertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
                self.tabBarController?.selectedIndex = 4
                
            })
            alertController.addAction(okalertAction)
            present(alertController, animated: true, completion: nil)
        }else{
            setupCameraManager()
            let currentCameraState = cameraManager.currentCameraStatus()
           // print(currentCameraState)
            if currentCameraState == .notDetermined {
                askForCameraPermissions()
            } else if currentCameraState == .ready {
                addCameraToView()
            } else {
                askForCameraPermissions()
            }
        }
        
        timer?.invalidate()
        self.btnCamera.setImage(UIImage(named: "ic_no_recording"), for: .normal)
        progressBar.isHidden = true
        progressBar.setProgress(0.0, animated: true)
        if myVideoURL != nil{
         btnUpload.isUserInteractionEnabled = true
        }else{
            btnUpload.isUserInteractionEnabled = false
            self.btnUpload.setImage(UIImage(named: "ic_no_upload"), for: .normal)
            self.viewSound.isUserInteractionEnabled = true
            self.flashModeImageView.isHidden = false
            self.timerImageView.isHidden = false
            self.cameraTypeImageView.isHidden = false
            self.qualityLabel.isHidden = false
            self.cameraLabel.isHidden = false
            self.qualityImgView.isHidden = false
            self.timerLabel.isHidden = false
            self.flashLabel.isHidden = false
            self.speedLabel.isHidden = false
            self.speedImgView.isHidden = false
            speedView.isHidden = true
            btnSlowTwoX.isHidden = true
            btnSlowThreeX.isHidden = true
            btnOneX.isHidden = true
            btnFastTwoX.isHidden = true
            btnFastThreeX.isHidden = true
        
        }
        
        if UserDefaults.standard.string(forKey: "sound_name") != "" {
            lblSoundName.text = UserDefaults.standard.string(forKey: "sound_name")
        }else if audioName != ""{
            lblSoundName.text = audioName
        }else{
             lblSoundName.text = "Add Sound"
        }
        navigationController?.navigationBar.isHidden = true
        cameraManager.resumeCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopCaptureSession()
    }
    
    // MARK: - ViewController
    fileprivate func setupCameraManager() {
        cameraManager.shouldEnableExposure = true
        
        cameraManager.writeFilesToPhoneLibrary = false
        
        cameraManager.shouldFlipFrontCameraImage = false
        cameraManager.showAccessPermissionPopupAutomatically = false
    }
    
    fileprivate func addCameraToView() {
        cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: CameraOutputMode.videoWithMic)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (_) -> Void in }))
            
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - @IBActions
    // function which is triggered when handleTap is called
    @objc func handleCloseTap(_ sender: UITapGestureRecognizer) {
        let alertController = UIAlertController(title: "Alert", message: "Are you Sure? If you go back you can't undo this action", preferredStyle: .alert)
        let okalertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            self.player?.pause()
            UserDefaults.standard.set("", forKey: "audioUrl")
            UserDefaults.standard.set("", forKey: "soundId")
            UserDefaults.standard.set("", forKey: "sound_name")
            self.myVideoURL = nil
            self.navigationController?.popViewController(animated: true)
           // self.dismiss(animated: true, completion: nil)
            self.tabBarController?.selectedIndex = 0
            
        })
        let cancelalertAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            
        })
        alertController.addAction(okalertAction)
        alertController.addAction(cancelalertAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeFlashMode(_ sender: UITapGestureRecognizer) {
        switch cameraManager.changeFlashMode() {
        case .off:
            flashModeImageView.image = UIImage(named: "ic_flash_off")
        case .on:
            flashModeImageView.image = UIImage(named: "ic_flash_on")
        case .auto:
            flashModeImageView.image = UIImage(named: "ic_flash_off")
        }
    }
    
    @IBAction func onTapRecordBtn(_ sender: UIButton) {
        switch cameraManager.cameraOutputMode {
        case .stillImage:
            cameraManager.capturePictureWithCompletion { result in
                switch result {
                case .failure:
                    self.cameraManager.showErrorBlock("Error occurred", "Cannot save picture.")
                case .success(let content):
                    print("Success")
                }
            }
        case .videoWithMic, .videoOnly:
            
            btnCamera.isSelected = !btnCamera.isSelected
            if btnCamera.isSelected{
              self.btnCamera.setImage(UIImage(named: "ic_recording"), for: .normal)
            }else{
              self.btnCamera.setImage(UIImage(named: "ic_no_recording"), for: .normal)
            }
           
            let url = UserDefaults.standard.value(forKey: "audioUrl")
            if sender.isSelected {
                cameraManager.startRecordingVideo()
                
                self.viewSound.isUserInteractionEnabled = false
                self.flashModeImageView.isHidden = true
                self.timerImageView.isHidden = true
                self.cameraTypeImageView.isHidden = true
                self.qualityLabel.isHidden = true
                self.cameraLabel.isHidden = true
                self.qualityImgView.isHidden = true
                self.timerLabel.isHidden = true
                self.flashLabel.isHidden = true
                self.speedImgView.isHidden = true
                self.speedLabel.isHidden = true
                self.reverseImgView.isHidden = true
                self.lblReverse.isHidden = true
                if url != nil{
                    let playerItem = AVPlayerItem( url:NSURL( string:url as! String )! as URL )
                    player = AVPlayer(playerItem:playerItem)
                    player?.rate = 1.0;
                    player?.play()
                }
                
                if audioPath != nil{
                    let playerItem = AVPlayerItem( url: audioPath!)
                    player = AVPlayer(playerItem:playerItem)
                    player?.rate = 1.0;
                    player?.play()
                }
                
                progressBar.isHidden = false
                timer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)
                
            } else {
                UserDefaults.standard.set(nil, forKey: "mergedVideo")
                myVideoURL = nil
                self.viewSound.isUserInteractionEnabled = true
                self.flashModeImageView.isHidden = false
                self.timerImageView.isHidden = false
                self.cameraTypeImageView.isHidden = false
                self.qualityLabel.isHidden = false
                self.cameraLabel.isHidden = false
                self.qualityImgView.isHidden = false
                self.timerLabel.isHidden = false
                self.flashLabel.isHidden = false
                self.speedLabel.isHidden = false
                self.speedImgView.isHidden = false
                self.reverseImgView.isHidden = false
                self.lblReverse.isHidden = false
                timer?.invalidate()
                player?.pause()
                self.btnUpload.isUserInteractionEnabled = true
                self.btnUpload.setImage(UIImage(named: "ic_upload"), for: .normal)
                cameraManager.stopVideoRecording({ (videoURL, recordError) -> Void in
                    guard let videoURL = videoURL else {
                        //Handle error of no recorded video URL
                        return
                    }
                    do {
                        
                        print(videoURL)
                        self.videosArr.append(videoURL)
                        print(self.videosArr)
                        AVMutableComposition().mergeVideo(self.videosArr, completion: {_,_ in
                            let audioUrl = UserDefaults.standard.string(forKey: "audioUrl")
                            if audioUrl != ""{
                                self.mergeFilesWithUrl(videoUrl: UserDefaults.standard.url(forKey: "mergedVideo")!, audioUrl: URL(string: audioUrl!)!)
                            }else{
                                self.myVideoURL = UserDefaults.standard.url(forKey: "mergedVideo")
                                self.applySpeed(url: UserDefaults.standard.url(forKey: "mergedVideo")!)
                            }
                        })
                        

                       
                    }
                })
            }
        }
    }
    
    
    @IBAction func gallryButtonTapped(_ sender: Any) {
        videoAndImageReview.sourceType = .savedPhotosAlbum
        videoAndImageReview.delegate = self
        videoAndImageReview.mediaTypes = ["public.movie"]
        
        present(videoAndImageReview, animated: true, completion: nil)
        
    }
    
    @IBAction func addSoundButtonTapped(_ sender: UITapGestureRecognizer) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "AddSoundViewController") as! AddSoundViewController
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func changeCameraDevice() {
        cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.front ? CameraDevice.back : CameraDevice.front
    }
    
    
    func askForCameraPermissions() {
        cameraManager.askUserForCameraPermission { permissionGranted in
            
            if permissionGranted {
                self.addCameraToView()
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    @IBAction func changeCameraQuality() {
        switch cameraManager.cameraOutputQuality {
        case .high:
            qualityLabel.text = "Medium"
            qualityImgView.image = UIImage(named: "ic_medium_quality")
            cameraManager.cameraOutputQuality = .medium
        case .medium:
            qualityLabel.text = "Low"
            qualityImgView.image = UIImage(named: "ic_low_quality")
            cameraManager.cameraOutputQuality = .low
        case .low:
            qualityLabel.text = "High"
            qualityImgView.image = UIImage(named: "ic_high_quality")
            cameraManager.cameraOutputQuality = .high
        default:
            qualityLabel.text = "High"
            qualityImgView.image = UIImage(named: "ic_high_quality")
            cameraManager.cameraOutputQuality = .high
        }
    }
    
    @IBAction func timerButtonTapped(_ sender: UITapGestureRecognizer)
    {
       let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
       let vc: TimerVC = storyboard.instantiateViewController(withIdentifier: "TimerVC") as! TimerVC
       vc.delegate = self
       vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func speedButtonTapped(_ sender: UITapGestureRecognizer)
    {
//        if myVideoURL == nil{
//            let alertController = UIAlertController(title: "", message: "Please record video first and then apply speed.", preferredStyle: .alert)
//            let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
//                alertController.dismiss(animated: true, completion: nil)
//            })
//            alertController.addAction(alertAction)
//            present(alertController, animated: true, completion: nil)
//        }else{
            speedView.isHidden = false
            btnSlowTwoX.isHidden = false
            btnSlowThreeX.isHidden = false
            btnOneX.isHidden = false
            btnFastTwoX.isHidden = false
            btnFastThreeX.isHidden = false
 //       }
        
    }
    
    @IBAction func reverseButtonTapped(_ sender: UITapGestureRecognizer)
    {
        self.isReverse = true
        if let videoURL1 = self.myVideoURL {
         // LoadingView.lockView()
          VideoGenerator.fileName = "ReversedMovieFileName"
            VideoGenerator.current.reverseVideo(fromVideo: videoURL1 ) { result in
                
                print(result)
                
                switch result{
                case .success(let reverseVideo):
                    print(reverseVideo)
                    //UserDefaults.standard.setValue(reverseVideo, forKey: "finalVideo")
                case .failure(let error):
                        print(error.localizedDescription)
                    }
            }
            
        } 
    }
    
    
    @objc func updateProgressBar() {
        
        progressBar.startLoading()
        DispatchQueue.main.async {
            if self.counterTime != 0.0{
                self.progressBar.progress += 1.0/self.counterTime
            }else{
                self.progressBar.progress += 1.0/15.0
            }
            
            //print(self.progressBar.progress)
            if self.progressBar.progress == 1.0 {
                self.timer!.invalidate()
                self.btnCamera.isSelected = false
                self.btnUpload.isUserInteractionEnabled = true
                self.btnUpload.setImage(UIImage(named: "ic_upload"), for: .normal)
                self.cameraManager.stopVideoRecording({ (videoURL, recordError) -> Void in
                    guard let videoURL = videoURL else {
                        //Handle error of no recorded video URL
                        return
                    }
                    do {
                        UserDefaults.standard.set(nil, forKey: "mergedVideo")
                        self.myVideoURL = nil
                        
                        self.videosArr.append(videoURL)
                        AVMutableComposition().mergeVideo(self.videosArr, completion: {_,_ in
                            let audioUrl = UserDefaults.standard.string(forKey: "audioUrl")
                            if audioUrl != ""{
                                self.mergeFilesWithUrl(videoUrl: UserDefaults.standard.url(forKey: "mergedVideo")!, audioUrl: URL(string: audioUrl!)!)
                            }else{
                                self.myVideoURL = UserDefaults.standard.url(forKey: "mergedVideo")
                                self.applySpeed(url: UserDefaults.standard.url(forKey: "mergedVideo")!)
                            }
                        })
                        
                    }
                })
                //self.btnCamera.backgroundColor = .white
                self.btnCamera.setImage(UIImage(named: "ic_no_recording"), for: .normal)
                self.player?.pause()
            }
        }
    }
    
    @IBAction func onTapUpload(_ sender: UIButton) {
        
     //   DispatchQueue.main.async {

            if let videoURL = self.myVideoURL{
                let player = AVPlayer(url: videoURL)
                
               let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc: PlayerVC = storyboard.instantiateViewController(withIdentifier: "PlayerVC") as! PlayerVC
                vc.myPlayer = player
                
                if UserDefaults.standard.url(forKey: "finalVideo") != nil{
                   vc.myVideoURL = UserDefaults.standard.url(forKey: "finalVideo")
                }else{
                    vc.myVideoURL = self.myVideoURL
                }
                
                
                //vc.modalPresentationStyle = .fullScreen
               // vc.delegate = self
               // self.present(vc, animated: true, completion: nil)
                self.navigationController?.pushViewController(vc, animated: true)
                    
            }
//        }
    }
    
      //MARK: PICKER DELEGATE METHOD
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        dismiss(animated: false, completion: nil)
        if #available(iOS 11.0, *) {
            picker.videoExportPreset = AVAssetExportPresetPassthrough
        }
        guard
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
            UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
            else {
                return
        }
        let asset   = AVURLAsset.init(url: url as URL)
//        print("mediaType 11----\(mediaType)")
        print("url 11----\(url)")
        
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: VideoTrimmerVC = storyboard.instantiateViewController(withIdentifier: "VideoTrimmerVC") as! VideoTrimmerVC
        vc.url = url as NSURL
        vc.asset = asset
        vc.speed = videoSpeed
        vc.isReverse = self.isReverse
        self.navigationController?.pushViewController(vc, animated: true)

    }

    func mergeFilesWithUrl(videoUrl:URL, audioUrl:URL)
    {
        let mixComposition : AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()


        //start merge

        let aVideoAsset : AVAsset = AVAsset(url: videoUrl)
        let aAudioAsset : AVAsset = AVAsset(url: audioUrl)

        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionAudioTrack.append( mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)

        let aVideoAssetTrack : AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]



        do{
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)

            //In my case my audio file is longer then video file so i took videoAsset duration
            //instead of audioAsset duration

            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)

            //Use this instead above line if your audiofile and video file's playing durations are same

            //            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), ofTrack: aAudioAssetTrack, atTime: kCMTimeZero)

        }catch{

        }

        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero,duration: aVideoAssetTrack.timeRange.duration )

        let mutableVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

        mutableVideoComposition.renderSize = CGSize(width: 1280.0, height: 720.0)

        //        playerItem = AVPlayerItem(asset: mixComposition)
        //        player = AVPlayer(playerItem: playerItem!)
        //
        //
        //        AVPlayerVC.player = player



        //find your video on this URl
    
      //  let savePathUrl : NSURL = NSURL(fileURLWithPath: NSHomeDirectory() + "/Documents/dhakdhakVideo.mp4")
         let savePathUrl : NSURL = NSURL(fileURLWithPath: NSHomeDirectory() + "/Documents/dhakdhakVideo\(Date()).mp4")
        do { // delete old video
            try FileManager.default.removeItem(at: savePathUrl as URL)
        } catch { print(error.localizedDescription) }
        
        myVideoURL = savePathUrl as URL
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = savePathUrl as URL
        assetExport.shouldOptimizeForNetworkUse = true

        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {

            case AVAssetExportSession.Status.completed:

                //Uncomment this if u want to store your video in asset

                //let assetsLib = ALAssetsLibrary()
                //assetsLib.writeVideoAtPathToSavedPhotosAlbum(savePathUrl, completionBlock: nil)
                DispatchQueue.main.async {
                    self.applySpeed(url: savePathUrl as URL)
                    
                }
                print("success")
            case  AVAssetExportSession.Status.failed:
                print("failed \(assetExport.error)")
            case AVAssetExportSession.Status.cancelled:
                print("cancelled \(assetExport.error)")
            default:
                print("complete")
            }
        }

        
    }

    @IBAction func onTapSlowThreeX(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: "finalVideo")
        
        self.btnSlowThreeX.backgroundColor = .white
        self.btnSlowThreeX.layer.cornerRadius = 5
        self.btnSlowThreeX.setTitleColor(.black, for: .normal)
        self.btnSlowTwoX.backgroundColor = .black
        self.btnSlowTwoX.layer.cornerRadius = 0
        self.btnSlowTwoX.setTitleColor(.white, for: .normal)
        self.btnOneX.backgroundColor = .black
        self.btnOneX.layer.cornerRadius = 0
        self.btnOneX.setTitleColor(.white, for: .normal)
        self.btnFastTwoX.backgroundColor = .black
        self.btnFastTwoX.layer.cornerRadius = 0
        self.btnFastTwoX.setTitleColor(.white, for: .normal)
        self.btnFastThreeX.backgroundColor = .black
        self.btnFastThreeX.layer.cornerRadius = 0
        self.btnFastThreeX.setTitleColor(.white, for: .normal)
        if myVideoURL != nil{
        VSVideoSpeeder.shared.scaleAsset(fromURL: myVideoURL, by: 3, withMode: SpeedoMode.Slower) { (exporter) in
             if let exporter = exporter {
                 switch exporter.status {
                        case .failed: do {
                              print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        }
                        case .completed: do {
                              print("Scaled video has been generated successfully!")
                        }
                        case .unknown: break
                        case .waiting: break
                        case .exporting: break
                        case .cancelled: break
                   }
              }
              else {
                   /// Error
                   print("Exporter is not initialized.")
              }
        }
        }
            videoSpeed = 0.3
    }
    
    @IBAction func onTapSlowTwoX(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: "finalVideo")
        
        self.btnSlowThreeX.backgroundColor = .black
        self.btnSlowThreeX.layer.cornerRadius = 0
        self.btnSlowThreeX.setTitleColor(.white, for: .normal)
        self.btnSlowTwoX.backgroundColor = .white
        self.btnSlowTwoX.layer.cornerRadius = 5
        self.btnSlowTwoX.setTitleColor(.black, for: .normal)
        self.btnOneX.backgroundColor = .black
        self.btnOneX.layer.cornerRadius = 0
        self.btnOneX.setTitleColor(.white, for: .normal)
        self.btnFastTwoX.backgroundColor = .black
        self.btnFastTwoX.layer.cornerRadius = 0
        self.btnFastTwoX.setTitleColor(.white, for: .normal)
        self.btnFastThreeX.backgroundColor = .black
        self.btnFastThreeX.layer.cornerRadius = 0
        self.btnFastThreeX.setTitleColor(.white, for: .normal)
        
        if myVideoURL != nil{
        VSVideoSpeeder.shared.scaleAsset(fromURL: myVideoURL, by: 2, withMode: SpeedoMode.Slower) { (exporter) in
             if let exporter = exporter {
                 switch exporter.status {
                        case .failed: do {
                              print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        }
                        case .completed: do {
                              print("Scaled video has been generated successfully!")
                        }
                        case .unknown: break
                        case .waiting: break
                        case .exporting: break
                        case .cancelled: break
                   }
              }
              else {
                   /// Error
                   print("Exporter is not initialized.")
              }
            }}
            videoSpeed = 0.2
    }
    
    @IBAction func onTapOneX(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: "finalVideo")
        
              self.btnSlowThreeX.backgroundColor = .black
              self.btnSlowThreeX.layer.cornerRadius = 0
              self.btnSlowThreeX.setTitleColor(.white, for: .normal)
              self.btnSlowTwoX.backgroundColor = .black
              self.btnSlowTwoX.layer.cornerRadius = 0
              self.btnSlowTwoX.setTitleColor(.white, for: .normal)
              self.btnOneX.backgroundColor = .white
              self.btnOneX.layer.cornerRadius = 5
              self.btnOneX.setTitleColor(.black, for: .normal)
              self.btnFastTwoX.backgroundColor = .black
              self.btnFastTwoX.layer.cornerRadius = 0
              self.btnFastTwoX.setTitleColor(.white, for: .normal)
              self.btnFastThreeX.backgroundColor = .black
              self.btnFastThreeX.layer.cornerRadius = 0
              self.btnFastThreeX.setTitleColor(.white, for: .normal)
              
        if myVideoURL != nil{
        VSVideoSpeeder.shared.scaleAsset(fromURL: myVideoURL, by: 1, withMode: SpeedoMode.Faster) { (exporter) in
             if let exporter = exporter {
                 switch exporter.status {
                        case .failed: do {
                              print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        }
                        case .completed: do {
                              print("Scaled video has been generated successfully!")
                        }
                        case .unknown: break
                        case .waiting: break
                        case .exporting: break
                        case .cancelled: break
                   }
              }
              else {
                   /// Error
                   print("Exporter is not initialized.")
              }
            }}
            videoSpeed = 1.0
       }
    
    @IBAction func onTapFastTwoX(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: "finalVideo")
        
        self.btnSlowThreeX.backgroundColor = .black
              self.btnSlowThreeX.layer.cornerRadius = 0
              self.btnSlowThreeX.setTitleColor(.white, for: .normal)
              self.btnSlowTwoX.backgroundColor = .black
              self.btnSlowTwoX.layer.cornerRadius = 0
              self.btnSlowTwoX.setTitleColor(.white, for: .normal)
              self.btnOneX.backgroundColor = .black
              self.btnOneX.layer.cornerRadius = 0
              self.btnOneX.setTitleColor(.white, for: .normal)
              self.btnFastTwoX.backgroundColor = .white
              self.btnFastTwoX.layer.cornerRadius = 5
              self.btnFastTwoX.setTitleColor(.black, for: .normal)
              self.btnFastThreeX.backgroundColor = .black
              self.btnFastThreeX.layer.cornerRadius = 0
              self.btnFastThreeX.setTitleColor(.white, for: .normal)
              
        if myVideoURL != nil{
        VSVideoSpeeder.shared.scaleAsset(fromURL: myVideoURL, by: 2, withMode: SpeedoMode.Faster) { (exporter) in
             if let exporter = exporter {
                 switch exporter.status {
                        case .failed: do {
                              print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        }
                        case .completed: do {
                              print("Scaled video has been generated successfully!")
                        }
                        case .unknown: break
                        case .waiting: break
                        case .exporting: break
                        case .cancelled: break
                   }
              }
              else {
                   /// Error
                   print("Exporter is not initialized.")
              }
            }}
            videoSpeed = 2.0
       }
    
    @IBAction func onTapFastThreeX(_ sender: Any) {
        UserDefaults.standard.set(nil, forKey: "finalVideo")
        self.btnSlowThreeX.backgroundColor = .black
              self.btnSlowThreeX.layer.cornerRadius = 0
        self.btnSlowThreeX.setTitleColor(.white, for: .normal)
              self.btnSlowTwoX.backgroundColor = .black
              self.btnSlowTwoX.layer.cornerRadius = 0
              self.btnSlowTwoX.setTitleColor(.white, for: .normal)
              self.btnOneX.backgroundColor = .black
              self.btnOneX.layer.cornerRadius = 0
              self.btnOneX.setTitleColor(.white, for: .normal)
              self.btnFastTwoX.backgroundColor = .black
              self.btnFastTwoX.layer.cornerRadius = 0
              self.btnFastTwoX.setTitleColor(.white, for: .normal)
              self.btnFastThreeX.backgroundColor = .white
              self.btnFastThreeX.layer.cornerRadius = 5
              self.btnFastThreeX.setTitleColor(.black, for: .normal)
              
        if myVideoURL != nil{
        VSVideoSpeeder.shared.scaleAsset(fromURL: myVideoURL, by: 3, withMode: SpeedoMode.Faster) { (exporter) in
             if let exporter = exporter {
                 switch exporter.status {
                        case .failed: do {
                              print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        }
                        case .completed: do {
                              print("Scaled video has been generated successfully!")
                        }
                        case .unknown: break
                        case .waiting: break
                        case .exporting: break
                        case .cancelled: break
                   }
              }
              else {
                   /// Error
                   print("Exporter is not initialized.")
              }
            }}
            videoSpeed = 3.0
       }

    func applySpeed(url:URL){
        UserDefaults.standard.set(nil, forKey: "finalVideo")
        switch videoSpeed {
        case 0.3:
            VSVideoSpeeder.shared.scaleAsset(fromURL: url, by: 3, withMode: SpeedoMode.Slower) { (exporter) in
                if let exporter = exporter {
                    switch exporter.status {
                    case .failed: do {
                        print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        }
                    case .completed: do {
                        print("Scaled video has been generated successfully!")
                        // self.upload(url: url)
                        }
                    case .unknown: break
                    case .waiting: break
                    case .exporting: break
                    case .cancelled: break
                    }
                }
                else {
                    /// Error
                    print("Exporter is not initialized.")
                }
            }
        case 0.2:
            VSVideoSpeeder.shared.scaleAsset(fromURL: url, by: 2, withMode: SpeedoMode.Slower) { (exporter) in
                if let exporter = exporter {
                    switch exporter.status {
                    case .failed: do {
                        print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        }
                    case .completed: do {
                        print("Scaled video has been generated successfully!")
                        //self.upload(url: url)
                        }
                    case .unknown: break
                    case .waiting: break
                    case .exporting: break
                    case .cancelled: break
                    }
                }
                else {
                    /// Error
                    print("Exporter is not initialized.")
                }
            }
        case 1.0 :
            VSVideoSpeeder.shared.scaleAsset(fromURL: url, by: 1, withMode: SpeedoMode.Faster) { (exporter) in
                if let exporter = exporter {
                    switch exporter.status {
                    case .failed: do {
                        print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        }
                    case .completed: do {
                        print("Scaled video has been generated successfully!")
                        // self.upload(url: url)
                        }
                    case .unknown: break
                    case .waiting: break
                    case .exporting: break
                    case .cancelled: break
                    }
                }
                else {
                    /// Error
                    print("Exporter is not initialized.")
                }
            }
        case 2.0:
            VSVideoSpeeder.shared.scaleAsset(fromURL: url, by: 2, withMode: SpeedoMode.Faster) { (exporter) in
                if let exporter = exporter {
                    switch exporter.status {
                    case .failed: do {
                        print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        }
                    case .completed: do {
                        print("Scaled video has been generated successfully!")
                        // self.upload(url: url)
                        }
                    case .unknown: break
                    case .waiting: break
                    case .exporting: break
                    case .cancelled: break
                    }
                }
                else {
                    /// Error
                    print("Exporter is not initialized.")
                }
            }
        case 3.0:
            VSVideoSpeeder.shared.scaleAsset(fromURL: url, by: 3, withMode: SpeedoMode.Faster) { (exporter) in
                if let exporter = exporter {
                    switch exporter.status {
                    case .failed: do {
                        print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        }
                    case .completed: do {
                        print("Scaled video has been generated successfully!")
                        // self.upload(url: url)
                        }
                    case .unknown: break
                    case .waiting: break
                    case .exporting: break
                    case .cancelled: break
                    }
                }
                else {
                    /// Error
                    print("Exporter is not initialized.")
                }
            }
        default:
            VSVideoSpeeder.shared.scaleAsset(fromURL: url, by: 1, withMode: SpeedoMode.Faster) { (exporter) in
                if let exporter = exporter {
                    switch exporter.status {
                    case .failed: do {
                        print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        
                        }
                    case .completed: do {
                        print("Scaled video has been generated successfully!")
                        //  self.upload(url: url)
                        }
                    case .unknown: break
                    case .waiting: break
                    case .exporting: break
                    case .cancelled: break
                    }
                }
                else {
                    /// Error
                    print("Exporter is not initialized.")
                }
            }
        }
        
        
    }
    
}

public extension Data {
    func printExifData() {
        let cfdata: CFData = self as CFData
        let imageSourceRef = CGImageSourceCreateWithData(cfdata, nil)
        let imageProperties = CGImageSourceCopyMetadataAtIndex(imageSourceRef!, 0, nil)!
        
        let mutableMetadata = CGImageMetadataCreateMutableCopy(imageProperties)!
        
        CGImageMetadataEnumerateTagsUsingBlock(mutableMetadata, nil, nil) { _, tag in
            print(CGImageMetadataTagCopyName(tag)!, ":", CGImageMetadataTagCopyValue(tag)!)
            return true
        }
    }
}


extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }
    
    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }
    
    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }
    
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}

