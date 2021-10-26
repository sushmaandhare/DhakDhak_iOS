//
//  InstructionVC.swift
//  TIK TIK
//
//  Created by MacBook Air on 19/05/1943 Saka.
//  Copyright © 1943 Rao Mudassar. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class InstructionVC: UIViewController {

    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var btnGotIt: UIButton!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    
    var videoUrl:URL?
    var base64videoUrl:String!
    var mediaType = ""
    var videoId : String? = ""
    var fromDraftVC = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.videoId)
        let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
        self.btnGotIt.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)

        if let urldata = videoUrl
        {
            if let thumbnailImage = getThumbnailImage(forUrl: urldata) {
                bgImgView.image = thumbnailImage
            }
            
        }
        
        // Do any additional setup after loading the view.
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
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapGotIt(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: VideoUploadViewController = storyboard.instantiateViewController(withIdentifier: "VideoUploadViewController") as! VideoUploadViewController
        //vc.delegate = self
        vc.videoUrl = self.videoUrl
        if fromDraftVC == true{
            vc.fromDraftVC = true
        }
        vc.videoId = self.videoId
        var imageData11: Data? = nil
        //let url = URL(fileURLWithPath: url)
        imageData11 = try? Data(contentsOf: self.videoUrl!)
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

}
