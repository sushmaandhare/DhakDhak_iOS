//
//  DuetVC.swift
//  TIK TIK
//
//  Created by Apple on 29/09/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import Foundation
import UIKit
import CameraManager
import CoreServices
import AVKit
import AVFoundation

class DuetVC: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate, TimerVCDelegate {
func NotifyDismiss(videoUrl: URL) {
    
    if videoUrl.fileSize <= 60000000{
        self.btnUpload.isUserInteractionEnabled = true
        self.btnUpload.setImage(UIImage(named: "ic_upload"), for: .normal)
        myVideoURL = videoUrl
        
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
    
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var blurredView: UIView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var flashModeImageView: UIImageView!
    @IBOutlet var btnDismiss: UIButton!
    @IBOutlet var cameraTypeImageView: UIImageView!
    @IBOutlet var timerImageView: UIImageView!
    @IBOutlet var qualityLabel: UILabel!
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet var playerView: UIView!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var btnCamera: UIButton!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var btnUpload: UIButton!
    
    @IBOutlet weak var qualityImgView: UIImageView!
    @IBOutlet var cameraLabel: UILabel!
    @IBOutlet var flashLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!
    
    let cameraManager = CameraManager()
    var time = 0
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
    var duetVideoUrl : String! = ""
    var playerItem:AVPlayerItem?
    var durationTime: Float64 = 0.0
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // print(audioPath)
       
        let asset = AVAsset(url: URL(string: duetVideoUrl)!)
        
        let duration = asset.duration
        durationTime = CMTimeGetSeconds(duration)
        
        playerItem = AVPlayerItem(url: URL.init(string: duetVideoUrl!)!)
        //cell.player!.replaceCurrentItem(with: cell.playerItem)
        player = AVPlayer(playerItem: playerItem!)
        let playerLayer = AVPlayerLayer(player: player!)
        playerLayer.frame = CGRect(x:0,y:0,width:playerView.frame.width,height: playerView.frame.height)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.addSublayer(playerLayer)
        
        self.tabBarController?.tabBar.isHidden = true
       
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
        
    }
    
    
   override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            videosArr = []
            if UserDefaults.standard.bool(forKey: "Upload") == true{
                myVideoURL = nil
               
                UserDefaults.standard.set(nil, forKey: "mergedVideo")
                self.tabBarController?.selectedIndex = 0
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
                self.flashModeImageView.isHidden = false
                self.timerImageView.isHidden = false
                self.cameraTypeImageView.isHidden = false
                self.qualityLabel.isHidden = false
                self.cameraLabel.isHidden = false
                self.qualityImgView.isHidden = false
                self.timerLabel.isHidden = false
                self.flashLabel.isHidden = false
    
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
      @IBAction func handleCloseTap(_ sender: UIButton) {
            let alertController = UIAlertController(title: "Alert", message: "Are you Sure? If you go back you can't undo this action", preferredStyle: .alert)
            let okalertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
                self.player?.pause()
                self.myVideoURL = nil
                self.navigationController?.popViewController(animated: true)
               // self.dismiss(animated: true, completion: nil)
                
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
               
                if sender.isSelected {
                    cameraManager.startRecordingVideo()
                    player!.play()
                    self.flashModeImageView.isHidden = true
                    self.timerImageView.isHidden = true
                    self.cameraTypeImageView.isHidden = true
                    self.qualityLabel.isHidden = true
                    self.cameraLabel.isHidden = true
                    self.qualityImgView.isHidden = true
                    self.timerLabel.isHidden = true
                    self.flashLabel.isHidden = true
                    
                    progressBar.isHidden = false
                    timer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgressBar), userInfo: nil, repeats: true)
                    
                } else {
                    UserDefaults.standard.set(nil, forKey: "mergedVideo")
                    myVideoURL = nil
                    player!.pause()
                    self.flashModeImageView.isHidden = false
                    self.timerImageView.isHidden = false
                    self.cameraTypeImageView.isHidden = false
                    self.qualityLabel.isHidden = false
                    self.cameraLabel.isHidden = false
                    self.qualityImgView.isHidden = false
                    self.timerLabel.isHidden = false
                    self.flashLabel.isHidden = false
                    
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
                                
                                self.myVideoURL = UserDefaults.standard.url(forKey: "mergedVideo")
                                
                            })
                  
                        }
                    })
                }
            }
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
            vc.duration =  durationTime
            vc.fromDuet = true
           vc.delegate = self
           vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
        
        
        @objc func updateProgressBar() {
            
            progressBar.startLoading()
            DispatchQueue.main.async {
                if self.counterTime != 0.0{
                    self.progressBar.progress += 1.0/self.counterTime
                }else{
                    self.progressBar.progress += Float(1.0/self.durationTime)
                }
                
                //print(self.progressBar.progress)
                if self.progressBar.progress == 1.0 {
                    self.timer!.invalidate()
                    self.player!.pause()
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
                                
                                self.myVideoURL = UserDefaults.standard.url(forKey: "mergedVideo")
                                
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
        if let videoURL = self.myVideoURL{
              self.mergeVideosFilesWithUrl(savedVideoUrl: URL(string: self.duetVideoUrl)!, newVideoUrl: videoURL)
//            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc: VideoUploadViewController = storyboard.instantiateViewController(withIdentifier: "VideoUploadViewController") as! VideoUploadViewController
//            vc.videoUrl = videoURL
           // vc.fromDuetView = true
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
        
    func mergeVideosFilesWithUrl(savedVideoUrl: URL, newVideoUrl: URL)
    {
        print(savedVideoUrl)
        print(newVideoUrl)
        let savePathUrl : NSURL = NSURL(fileURLWithPath: NSHomeDirectory() + "/Documents/duetVideo.mp4")
        do { // delete old video
            try FileManager.default.removeItem(at: savePathUrl as URL)
        } catch { print(error.localizedDescription) }

        var mutableVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
        var mixComposition : AVMutableComposition = AVMutableComposition()

        let aNewVideoAsset : AVAsset = AVAsset(url: newVideoUrl)
        let asavedVideoAsset : AVAsset = AVAsset(url: savedVideoUrl)

        let aNewVideoTrack : AVAssetTrack = aNewVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let aSavedVideoTrack : AVAssetTrack = asavedVideoAsset.tracks(withMediaType: AVMediaType.video)[0]

        let mutableCompositionNewVideoTrack : AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        do{
            try mutableCompositionNewVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aNewVideoAsset.duration), of: aNewVideoTrack, at: CMTime.zero)
        }catch {  print("Mutable Error") }

        let mutableCompositionSavedVideoTrack : AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        do{
            try mutableCompositionSavedVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asavedVideoAsset.duration), of: aSavedVideoTrack , at: CMTime.zero)
        }catch{ print("Mutable Error") }

        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: CMTimeMaximum(aNewVideoAsset.duration, asavedVideoAsset.duration) )

        let newVideoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: mutableCompositionNewVideoTrack)
//        let newScale : CGAffineTransform = CGAffineTransform.init(scaleX: 0.0, y: 0.0)
//        let newMove : CGAffineTransform = CGAffineTransform.init(translationX: 50, y: 50)
//        newVideoLayerInstruction.setTransform(newScale.concatenating(newMove), at: CMTime.zero)
//
        let savedVideoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: mutableCompositionSavedVideoTrack)
        let savedScale : CGAffineTransform = CGAffineTransform.init(scaleX: 0.0, y: 0.0)
        let savedMove : CGAffineTransform = CGAffineTransform.init(translationX: 50, y: 50)
        savedVideoLayerInstruction.setTransform(savedScale.concatenating(savedMove), at: CMTime.zero)
//
        mainInstruction.layerInstructions = [newVideoLayerInstruction, savedVideoLayerInstruction]
//
//
        mutableVideoComposition.instructions = [mainInstruction]
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mutableVideoComposition.renderSize = CGSize(width: 500 , height: 300)

        
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.videoComposition = mutableVideoComposition
        assetExport.outputFileType = AVFileType.mov

        assetExport.outputURL = savePathUrl as URL
        assetExport.shouldOptimizeForNetworkUse = true

        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {

            case AVAssetExportSession.Status.completed:
                print("success")
                DispatchQueue.main.async {

                    let player = AVPlayer(url: savePathUrl as URL)
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc: PlayerVC = storyboard.instantiateViewController(withIdentifier: "PlayerVC") as! PlayerVC
                    vc.myPlayer = player
                    vc.myVideoURL = savePathUrl as URL
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case  AVAssetExportSession.Status.failed:
                print("failed \(assetExport.error)")
            case AVAssetExportSession.Status.cancelled:
                print("cancelled \(assetExport.error)")
            default:
                print("complete")
            }
        }

    }
    }

