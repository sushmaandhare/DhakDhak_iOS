//
//  PlayerVC.swift
//  TIK TIK
//
//  Created by Apple on 20/08/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

//protocol PlayerVCDelegate {
//    func DismissPlayerVC()
//}

class PlayerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    
    //    func DismissVC() {
    //        UserDefaults.standard.set("", forKey: "audioUrl")
    //        UserDefaults.standard.set("", forKey: "soundId")
    //
    //        self.dismiss(animated: true, completion: {
    //            self.delegate?.DismissPlayerVC()
    //        })
    //    }
    
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var newView: UIView!
    @IBOutlet weak var effect_CollVw: UICollectionView!
    @IBOutlet weak var effect_Vw: UIView!
    
    var isReverse = false
    var fromCopyRight = false
    var videoId : String? = ""
    
    var strSelectedEffect = ""
    var filterSelcted = 100
    var myVideoURL: URL!
    var myPlayer: AVPlayer!
    let avPlayerViewController = PreviewViewController()
    // var delegate : PlayerVCDelegate?
    var fromDraftVC = false
    var thumImg: UIImage?
    var CIFilterNames = [
        "CISharpenLuminance",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone",
        "CIColorClamp",
        "CIColorInvert",
        "CIColorMonochrome",
        "CISpotLight",
        "CIColorPosterize",
        "CIBoxBlur",
        "CIDiscBlur",
        "CIGaussianBlur",
        "CIMaskedVariableBlur",
        "CIMedianFilter",
        "CIMotionBlur",
        "CINoiseReduction"
    ]
    
    var filterNames = ["Luminance","Chrome","Fade","Instant","Noir","Process","Tonal","Transfer","SepiaTone","ColorClamp","ColorInvert","ColorMonochrome","SpotLight","ColorPosterize","BoxBlur","DiscBlur","GaussianBlur","MaskedVariableBlur","MedianFilter","MotionBlur","NoiseReduction"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        print(self.videoId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          //
            self.myPlayer = AVPlayer(url: self.myVideoURL)
            
//            if self.isReverse == true{
//                let duratTime: CMTime = (self.myPlayer.currentItem?.asset.duration)!
//                    if CMTIME_IS_VALID(duratTime) {
//                        self.myPlayer.seek(to: duratTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
//                     //   self.myPlayer.rate = -1
//                     //   self.myPlayer.play()
//                    }
//                    else {
//                        print("In valid time")
//                    }
//            }
            
            self.avPlayerViewController.view.frame.size.height = self.newView.frame.size.height
            self.avPlayerViewController.view.frame.size.width = self.newView.frame.size.width
            self.avPlayerViewController.player = self.myPlayer
            
            //  let playerLayer = AVPlayerLayer(player: myPlayer)
            // playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            //  avPlayerViewController.view.frame = self.view.frame
            self.newView.addSubview(self.avPlayerViewController.view)
                self.addChild(self.avPlayerViewController)
                self.avPlayerViewController.didMove(toParent: self)
            self.myPlayer.play()
         //   self.thumImg = Helper().generateThumbnail(path: self.myVideoURL)
        }
        let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
        self.btnNext.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
        //effect_CollVw.register(UINib(nibName: "EffectCollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "EffectCollectionCell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
   
    @IBAction func dismissButtonTapped(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        self.myPlayer?.pause()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        /*let vc: InstructionVC = storyboard.instantiateViewController(withIdentifier: "InstructionVC") as! InstructionVC
        vc.videoUrl = self.myVideoURL
        if fromDraftVC == true{
            vc.fromDraftVC = true
        }else if fromCopyRight{
            vc.videoId = self.videoId
        }
        
        var imageData11: Data? = nil
        imageData11 = try? Data(contentsOf: self.myVideoURL!)
        let base64NewData = imageData11?.base64EncodedString()
        vc.base64videoUrl = base64NewData
        vc.mediaType = "public.movie"
        self.navigationController?.pushViewController(vc, animated: true)*/
        
        
        let vc: VideoUploadViewController = storyboard.instantiateViewController(withIdentifier: "VideoUploadViewController") as! VideoUploadViewController
        //vc.delegate = self
        vc.videoUrl = self.myVideoURL
        if fromDraftVC == true{
            vc.fromDraftVC = true
        }
        vc.videoId = self.videoId
        var imageData11: Data? = nil
        //let url = URL(fileURLWithPath: url)
        imageData11 = try? Data(contentsOf: self.myVideoURL!)
        let base64NewData = imageData11?.base64EncodedString()
        vc.base64videoUrl = base64NewData
        vc.mediaType = "public.movie"
        // vc.modalPresentationStyle = .fullScreen
        // self.present(vc, animated: true, completion: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: EffectCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectCollectionCell", for: indexPath) as! EffectCollectionCell
    
        cell.lbl_effectName.text = filterNames[indexPath.row]
        if let convertImage = UIImage(named: "filter") {
            cell.effect_Imgvw.image = Helper().convertImageToBW(filterName: CIFilterNames[indexPath.row], image: convertImage)
        }
        cell.effect_Imgvw.layer.borderWidth = 2
        
        if self.filterSelcted == indexPath.row {
            cell.effect_Imgvw.layer.borderColor = UIColor.white.cgColor
        } else {
            cell.effect_Imgvw.layer.borderColor = UIColor.clear.cgColor
        }
        cell.effect_Imgvw.layer.cornerRadius = 12
        cell.effect_Imgvw.layer.masksToBounds = true
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        CGSize(width: effect_CollVw.layer.frame.width / 4, height:  effect_CollVw.layer.frame.width / 4)
    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    //    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        //effect view
        if effect_Vw.isHidden == false {
            
            self.filterSelcted = indexPath.row
            self.strSelectedEffect = CIFilterNames[indexPath.row]
            self.effect_CollVw.reloadData()
            myPlayer?.pause()
            Helper().addfiltertoVideo(strfiltername: strSelectedEffect, strUrl: myVideoURL, success: { (url) in
                DispatchQueue.main.async {
                    self.addVideoPlayer(videoUrl: url, to: self.newView)
                    
                }
            }) { (error) in
                DispatchQueue.main.async {
                    print("error")
                }
            }
        }
        
    }
    
    func addVideoPlayer(videoUrl: URL, to view: UIView) {
        self.myVideoURL = videoUrl
        self.myPlayer = AVPlayer(url: videoUrl)
        avPlayerViewController.player = self.myPlayer
        self.addChild(avPlayerViewController)
        view.addSubview(avPlayerViewController.view)
        avPlayerViewController.view.frame = view.bounds
//        avPlayerViewController.view.layer.compositingFilter = "Tonal"
        avPlayerViewController.showsPlaybackControls = true
        self.myPlayer?.play()
    }
}


class EffectCollectionCell: UICollectionViewCell {

    @IBOutlet weak var effect_Imgvw: UIImageView!
    @IBOutlet weak var lbl_effectName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

