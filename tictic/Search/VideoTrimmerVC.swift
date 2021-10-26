//
//  VideoTrimmerVC.swift
//  TIK TIK
//
//  Created by Apple on 09/09/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import CoreMedia
import AssetsLibrary
import Photos
import SwiftVideoGenerator

class VideoTrimmerVC: UIViewController,AddSoundViewControllerDelegate {
    func dismiss() {
        let audioUrl = UserDefaults.standard.string(forKey: "audioUrl")
        self.mergeFilesWithUrl(videoUrl: self.url as URL, audioUrl: URL(string: audioUrl!)!)
    }
    
    var isReverse = false
    var isPlaying = true
    var isSliderEnd = true
    var playbackTimeCheckerTimer: Timer! = nil
    let playerObserver: Any? = nil
    
    let exportSession: AVAssetExportSession! = nil
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var playerLayer: AVPlayerLayer!
    var asset: AVAsset!
    
    var url:NSURL! = nil
    var startTime: CGFloat = 0.0
    var thumbTime: CMTime!
    var thumbtimeSeconds: Int! = 16
    var speed : Double = 1.0
    var videoPlaybackPosition: CGFloat = 0.0
    var cache:NSCache<AnyObject, AnyObject>!
    var rangSlider: RangeSlider! = nil
    
    @IBOutlet weak var lblDifference: UILabel!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var frameContainerView: UIView!
    @IBOutlet weak var imageFrameView: UIView!
    @IBOutlet weak var viewSound: UIView!
    @IBOutlet weak var btnSound: UIButton!
    @IBOutlet weak var lblSoundName: UILabel!
    
    
    var startTimestr = ""
    var endTimestr = ""
    var fromCopyRight = false
    var videoId : String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.videoId)
        if fromCopyRight == true{
            UserDefaults.standard.set("", forKey: "audioUrl")
            UserDefaults.standard.set("", forKey: "soundId")
             UserDefaults.standard.set("", forKey: "sound_name")
           
            self.frameContainerView.isHidden = true
            self.lblDifference.isHidden = true
            //self.player.volume = 0.0
        }else{
            self.btnSound.isHidden = true
            self.viewSound.isHidden = true
        }
        self.navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.loadViews()
       
        if let assets = asset
        {
            thumbTime = asset.duration
            thumbtimeSeconds      = Int(CMTimeGetSeconds(thumbTime))
            lblDifference.text = String(thumbtimeSeconds)
            self.viewAfterVideoIsPicked()
            
            let item:AVPlayerItem = AVPlayerItem(asset: asset)
            player                = AVPlayer(playerItem: item)
            playerLayer           = AVPlayerLayer(player: player)
            playerLayer.frame     = videoPlayerView.bounds
            
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            player.actionAtItemEnd   = AVPlayer.ActionAtItemEnd.none
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapOnvideoPlayerView))
            self.videoPlayerView.addGestureRecognizer(tap)
            self.tapOnvideoPlayerView(tap: tap)
            
            videoPlayerView.layer.addSublayer(playerLayer)
            player.play()
            if fromCopyRight == true{
                self.player.volume = 0.0
            }
        }
            
        let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
        self.saveButton.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
        self.btnSound.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.string(forKey: "sound_name") != ""{
            lblSoundName.text = UserDefaults.standard.string(forKey: "sound_name")
        }else{
            lblSoundName.text = "Add Sound"
        }
    }
    //Loading Views
    func loadViews()
    {
        //Whole layout view
        
        saveButton.layer.cornerRadius   = 5.0
        
        //Hiding buttons and view on load
        saveButton.isHidden         = false
        frameContainerView.isHidden = true
        
        
        imageFrameView.layer.cornerRadius = 5.0
        imageFrameView.layer.borderWidth  = 1.0
        imageFrameView.layer.borderColor  = UIColor.white.cgColor
        imageFrameView.layer.masksToBounds = true
        
        player = AVPlayer()
        
        
        //Allocating NsCahe for temp storage
        self.cache = NSCache()
    }
    
    
    //Action for crop video
    @IBAction func cropVideo(_ sender: Any)
    {
        let start = Float(startTimestr)
        let end   = Float(endTimestr)
        if (end! - start!) > 16.0{
           alertModule(title: "Alert", msg: "You can trim video upto 15 sec")
        }else if (end! - start!) < 5.0{
           alertModule(title: "Alert", msg: "You must have to trim video upto 5 sec")
        }else{
          self.cropVideo(sourceURL1: url, startTime: start!, endTime: end!)
        }
    }
    
    @IBAction func addSoundButtonTapped(_ sender: UITapGestureRecognizer) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: AddSoundViewController = storyboard.instantiateViewController(withIdentifier: "AddSoundViewController") as! AddSoundViewController
        vc.delegate = self
        vc.isCopyright = true
        self.present(vc, animated: true, completion: nil)
    }
    
    func applySpeed(url:URL){
        UserDefaults.standard.set(nil, forKey: "finalVideo")
        switch speed {
        case 0.3:
            VSVideoSpeeder.shared.scaleAsset(fromURL: url, by: 3, withMode: SpeedoMode.Slower) { (exporter) in
                if let exporter = exporter {
                    switch exporter.status {
                    case .failed: do {
                        print(exporter.error?.localizedDescription ?? "Error in exporting..")
                        }
                    case .completed: do {
                        print("Scaled video has been generated successfully!")
                        self.upload(url: url)
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
                        self.upload(url: url)
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
                        self.upload(url: url)
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
                        self.upload(url: url)
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
                        self.upload(url: url)
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
                        self.upload(url: url)
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
    
    func upload(url:URL){
      DispatchQueue.main.async {
            self.player.pause()
            let myplayer = AVPlayer(url: url)
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: PlayerVC = storyboard.instantiateViewController(withIdentifier: "PlayerVC") as! PlayerVC
            if UserDefaults.standard.url(forKey: "finalVideo") != nil{
               vc.myVideoURL = UserDefaults.standard.url(forKey: "finalVideo")
                if self.fromCopyRight == true{
                    vc.videoId = self.videoId
                    vc.fromCopyRight = true
                }
            }else{
                
              vc.myVideoURL = url
                
            }
            vc.myPlayer = myplayer
            //vc.isReverse = self.isReverse
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func onTapCross(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//Subclass of VideoMainViewController
extension VideoTrimmerVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    
    func viewAfterVideoIsPicked()
    {
        //Rmoving player if alredy exists
        if(playerLayer != nil)
        {
            playerLayer.removeFromSuperlayer()
        }
        
        self.createImageFrames()
        
        //unhide buttons and view after video selection
        saveButton.isHidden         = false
        frameContainerView.isHidden = false
        
        
        isSliderEnd = true
        startTimestr = "\(0.0)"
        endTimestr   = "\(thumbtimeSeconds!)"
        self.createrangSlider()
    }
    
    //Tap action on video player
    @objc func tapOnvideoPlayerView(tap: UITapGestureRecognizer)
    {
        if isPlaying
        {
            self.player.play()
        }
        else
        {
            self.player.pause()
        }
        isPlaying = !isPlaying
    }
    
    
    
    //MARK: CreatingFrameImages
    func createImageFrames()
    {
        //creating assets
        let assetImgGenerate : AVAssetImageGenerator    = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter    = CMTime.zero;
        assetImgGenerate.requestedTimeToleranceBefore   = CMTime.zero;
        
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        let thumbTime: CMTime = asset.duration
        let thumbtimeSeconds  = Int(CMTimeGetSeconds(thumbTime))
        let maxLength         = "\(thumbtimeSeconds)" as NSString
        
        let thumbAvg  = thumbtimeSeconds/6
        var startTime = 1
        var startXPosition:CGFloat = 0.0
        
        //loop for 6 number of frames
        for _ in 0...5
        {
            
            let imageButton = UIButton()
            let xPositionForEach = CGFloat(self.imageFrameView.frame.width)/6
            imageButton.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height: CGFloat(self.imageFrameView.frame.height))
            do {
                let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),preferredTimescale: Int32(maxLength.length))
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: img)
                imageButton.setImage(image, for: .normal)
            }
            catch
                _ as NSError
            {
                print("Image generation failed with error (error)")
            }
            
            startXPosition = startXPosition + xPositionForEach
            startTime = startTime + thumbAvg
            imageButton.isUserInteractionEnabled = false
            imageFrameView.addSubview(imageButton)
        }
        
    }
    
    //Create range slider
    func createrangSlider()
    {
        //Remove slider if already present
        let subViews = self.frameContainerView.subviews
        for subview in subViews{
            if subview.tag == 1000 {
                subview.removeFromSuperview()
            }
        }
        
        rangSlider = RangeSlider(frame: frameContainerView.bounds)
        frameContainerView.addSubview(rangSlider)
        rangSlider.tag = 1000
        
        //Range slider action
        rangSlider.addTarget(self, action: #selector(VideoTrimmerVC.rangSliderValueChanged(_:)), for: .valueChanged)
        
        let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.rangSlider.trackHighlightTintColor = UIColor.clear
            self.rangSlider.curvaceousness = 1.0
        }
        
    }
    
    //MARK: rangSlider Delegate
    @objc func rangSliderValueChanged(_ rangSlider: RangeSlider) {
//        self.player.pause()
        
        if(isSliderEnd == true)
        {
            rangSlider.minimumValue = 0.0
            rangSlider.maximumValue = Double(thumbtimeSeconds)
            
            rangSlider.upperValue = Double(thumbtimeSeconds)
            isSliderEnd = !isSliderEnd
            
        }
        
        startTimestr = "\(rangSlider.lowerValue)"
        endTimestr   = "\(rangSlider.upperValue)"
        var diff = round(rangSlider.upperValue - rangSlider.lowerValue)
        lblDifference.text = String(diff)
       // print(rangSlider.lowerLayerSelected)
        if(rangSlider.lowerLayerSelected)
        {
            self.seekVideo(toPos: CGFloat(rangSlider.lowerValue))
            
        }
        else
        {
            self.seekVideo(toPos: CGFloat(rangSlider.upperValue))
            
        }
        
      //  print(startTime)
    }
    //Seek video when slide
    func seekVideo(toPos pos: CGFloat) {
        self.videoPlaybackPosition = pos
        let time: CMTime = CMTimeMakeWithSeconds(Float64(self.videoPlaybackPosition), preferredTimescale: self.player.currentTime().timescale)
        self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        if(pos == CGFloat(thumbtimeSeconds))
        {
            self.player.pause()
        }
    }
    
    //Trim Video Function
    func cropVideo(sourceURL1: NSURL, startTime:Float, endTime:Float)
    {
        let manager                 = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {return}
        guard let mediaType         = "mp4" as? String else {return}
        guard (sourceURL1 as? NSURL) != nil else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String
        {
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
           // print("video length: \(length) seconds")
            
            let start = startTime
            let end = endTime
           // print(documentDirectory)
            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                //let name = hostent.newName()
                outputURL = outputURL.appendingPathComponent("1.mp4")
            }catch let error {
                print(error)
            }
            
            //Remove existing file
            _ = try? manager.removeItem(at: outputURL)
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            
            let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                    print("exported at \(outputURL)")
                   // self.saveToCameraRoll(URL: outputURL as NSURL?)
                    
                    let audioUrl = UserDefaults.standard.string(forKey: "audioUrl")
                    if audioUrl != ""{
                     self.mergeFilesWithUrl(videoUrl: outputURL, audioUrl: URL(string: audioUrl!)!)
                    }else if self.isReverse == true{
                        
                        
                         // LoadingView.lockView()
                          VideoGenerator.fileName = "ReversedMovieFileName"
                            VideoGenerator.current.reverseVideo(fromVideo: outputURL ) { result in
                                
                                print(result)
                                
                                switch result{
                                case .success(let reverseVideo):
                                    print(reverseVideo)
                                    
                                  //  if UserDefaults.standard.setValue(reverseVideo, forKey: "finalVideo") != nil{
                                    self.upload(url: reverseVideo)
                                  //  }
                                case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                            }
                            
                        
                        
                    }else{
                        self.applySpeed(url: outputURL)
                    }
                    
                   
                    
                    
                case .failed:
                    print("failed \(exportSession.error)")
                    
                case .cancelled:
                    print("cancelled \(String(describing: exportSession.error))")
                    
                default: break
                }}}}
    
    //Save Video to Photos Library
    func saveToCameraRoll(URL: NSURL!) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL as URL)
        }) { saved, error in
            if saved {
                let alertController = UIAlertController(title: "Cropped video was saved successfully", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }}}
    
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
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
        let savePathUrl : NSURL = NSURL(fileURLWithPath: NSHomeDirectory() + "/Documents/dhakdhakVideo\(Date()).mp4")
        do { // delete old video
            try FileManager.default.removeItem(at: savePathUrl as URL)
        } catch { print(error.localizedDescription) }
        
        //myVideoURL = savePathUrl as URL
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
}

