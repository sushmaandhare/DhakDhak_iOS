//
//  LaunchVC.swift
//  TIK TIK
//
//  Created by MacBook Air on 06/02/1943 Saka.
//  Copyright © 1943 Rao Mudassar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class LaunchVC: UIViewController {

    @IBOutlet weak var newView: UIView!
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadVideo()
        // Do any additional setup after loading the view.
    }
    

    private func loadVideo() {

        //this line is important to prevent background music stop
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        } catch { }

        let path = Bundle.main.path(forResource: "phone_720-3", ofType:"mp4")

        player = AVPlayer(url: NSURL(fileURLWithPath: path!) as URL)
        let playerLayer = AVPlayerLayer(player: player)

        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.zPosition = -1

        self.view.layer.addSublayer(playerLayer)

        player?.seek(to: CMTime.zero)
        player?.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let yourVC: TabbarViewController = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
          //  yourVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(yourVC, animated: true)
        })
       
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
