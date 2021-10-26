//
//  TimerVC.swift
//  TIK TIK
//
//  Created by Apple on 08/09/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//


import UIKit

protocol TimerVCDelegate {
    func sendTimerValue(timeVal:Float)
}

class TimerVC: UIViewController {

    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var seconds = 0
    var timer = Timer()
    var delegate : TimerVCDelegate?
    var duration = 0.0
    var fromDuet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        if fromDuet == true{
            
            seconds = Int(duration.rounded())
            lblTime.text = "\(seconds)s/\(Int(duration.rounded()))s"
        }else{
           seconds = 15
            lblTime.text = "\(seconds)s/15s"
        }
      
    }
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        seconds = Int(sender.value)
        if fromDuet == true{
            lblTime.text = "\(seconds)s/\(Int(duration.rounded()))s"
        }else{
            lblTime.text = "\(seconds)s/15s"
        }
       
        
    }
    
    @IBAction func onTapStartShooting(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.sendTimerValue(timeVal: self.slider.value)
        })
    }
    
    @IBAction func onTapDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
