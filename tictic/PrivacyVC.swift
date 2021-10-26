//
//  PrivacyVC.swift
//  TIK TIK
//
//  Created by Apple on 09/10/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit

protocol PrivacyVCDelegate {
    func sendString(val:String)
}

class PrivacyVC: UIViewController {
    
    var delegate : PrivacyVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
    }
    
    @IBAction func publicSelected(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.sendString(val: "Public")
        })
    }
    
    @IBAction func friendSelected(_ sender: Any) {
       self.dismiss(animated: true, completion: {
           self.delegate?.sendString(val: "Friend")
       })
    }
    
    @IBAction func privateSelected(_ sender: Any) {
      self.dismiss(animated: true, completion: {
           self.delegate?.sendString(val: "Private")
       })
    }
    
    @IBAction func onTapDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
