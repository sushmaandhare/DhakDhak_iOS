//
//  ViewController.swift
//  tictic
//
//  Created by Rao Mudassar on 24/04/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PreviewViewController: AVPlayerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        NotificationCenter.default.addObserver(self, selector: #selector(PreviewViewController.videoDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
//        self.player?.play()
        
    }
    
    @objc func videoDidEnd(notification: NSNotification) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: VideoUploadViewController = storyboard.instantiateViewController(withIdentifier: "VideoUploadViewController") as! VideoUploadViewController
//        vc.delegate = self
//        vc.videoUrl = self.myVideoURL
        vc.mediaType = "public.movie"
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
}

