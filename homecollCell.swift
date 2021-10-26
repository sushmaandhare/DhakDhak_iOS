//
//  homecollCell.swift
//  TIK TIK
//
//  Created by Rao Mudassar on 25/04/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.
//

import UIKit
import VersaPlayer
import AVKit
import DSGradientProgressView
import MarqueeLabel
import ActiveLabel
import KILabel
import SwiftResponsiveLabel
import DTGradientButton

class homecollCell: UICollectionViewCell {
    
    @IBOutlet weak var btnRequestVerification: UIButton!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var lblViewCount: UILabel!
    @IBOutlet weak var lblShareCount: UILabel!
    @IBOutlet weak var lblCommentCount: UILabel!
       
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var cdView: UIView!
    @IBOutlet weak var cdProfileImg: UIImageView!
    @IBOutlet weak var btnCD: UIButton!
    
    @IBOutlet weak var cdImgView: UIImageView!
    
    @IBOutlet weak var progressView: DSGradientProgressView!
    @IBOutlet weak var playerView: UIView!
    var player:AVPlayer? = nil
    var playerItem:AVPlayerItem? = nil
    var playerLayer:AVPlayerLayer? = nil
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var other_profile: UIButton!
    
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var inner_view: UIView!
    
    @IBOutlet weak var btn_like: UIButton!
    
    @IBOutlet weak var btnshare: UIButton!
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var btn_comments: UIButton!
    
    @IBOutlet weak var user_view: UIView!
    
    @IBOutlet weak var user_img: UIImageView!
    
    @IBOutlet weak var user_name: UILabel!
    
    @IBOutlet weak var music_name: MarqueeLabel!
    
    @IBOutlet weak var btnVerification: UIButton!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var commentView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        player?.automaticallyWaitsToMinimizeStalling = false
        // Attach a block to be called when the user taps a hashtag
        self.rotate(imageView: cdImgView, aCircleTime: 4.0)
        self.rotate(imageView: cdProfileImg, aCircleTime: 4.0)
     //   let colors = [UIColor(red: 255, green: 81, blue: 47, alpha: 1), UIColor(red: 221, green: 36, blue: 181, alpha: 1)]
        let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
        self.btnVerification.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
//        self.btnRequestVerification.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)

//        if #available(iOS 13.0, *) {
//            let blurEff = UIBlurEffect(style: .systemThinMaterialDark)
//            let visualEffectView = UIVisualEffectView(effect: blurEff)
//            self.gradientView.addSubview(visualEffectView)
//            visualEffectView.frame = self.gradientView.frame
//        } else {
//            // Fallback on earlier versions
//        }
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        self.playerItem = nil
        self.playerLayer?.removeFromSuperlayer()
    
    }

    
    func rotate(imageView: UIImageView, aCircleTime: Double) { //UIView
            
            UIView.animate(withDuration: aCircleTime/2, delay: 0.0, options: .curveLinear, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            }, completion: { finished in
                UIView.animate(withDuration: aCircleTime/2, delay: 0.0, options: .curveLinear, animations: {
                    imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi*2))
                }, completion: { finished in
                    self.rotate(imageView: imageView, aCircleTime: aCircleTime)
                })
            })
    }
    
    
}
