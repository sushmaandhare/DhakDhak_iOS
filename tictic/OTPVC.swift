//
//  OTPVC.swift
//  TIK TIK
//
//  Created by Apple on 31/08/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import AuthenticationServices
import FirebaseAuth
import Alamofire

class OTPVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var lblMobileNo: UILabel!
    @IBOutlet weak var TF1: UITextField!
    @IBOutlet weak var TF2: UITextField!
    @IBOutlet weak var TF3: UITextField!
    @IBOutlet weak var TF4: UITextField!
    @IBOutlet weak var TF5: UITextField!
    @IBOutlet weak var TF6: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!

    @IBOutlet weak var resend_Again_Lbl: UILabel!
    
    var mobNo : String!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var fb_Id = ""
    var maxLen:Int = 1;  // set max text count for textfeild

    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
        
        mobNo = UserDefaults.standard.string(forKey: "MoblieNumber")
        lblMobileNo.text = "We have sent OTP on \(mobNo ?? "")"
        
        TF1.delegate = self
        TF2.delegate = self
        TF3.delegate = self
        TF4.delegate = self
        TF5.delegate = self
        TF6.delegate = self
        
        
        TF1.becomeFirstResponder()
        TF1.layer.borderColor = UIColor.blue.cgColor
        
    }
    
    
    func SignUpApi(){
        
        
        var VersionString:String! = ""
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            VersionString = version
        }
        
        let url : String = appDelegate.baseUrl!+appDelegate.signUp!
        
        let parameter:[String:Any]?  = ["fb_id":self.fb_Id,"first_name":"User","last_name":"","profile_pic":"","gender":"m","signup_type":"Mobile","version":VersionString!,"device":"iOS","latitude" : UserDefaults.standard.value(forKey: "Latitude") ?? "", "longitude" : UserDefaults.standard.value(forKey: "Longitude") ?? "", "referral_fb_id": UserDefaults.standard.value(forKey: "referral_fb_id") ?? ""]
        
        // print(url)
        // print(parameter!)
        
        let headers: HTTPHeaders = [
            "api-key": "4444-3333-2222-1111"
            
        ]
        
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
            
            respones in
            
            switch respones.result {
            case .success( let value):
                
                let json  = value
                //print(json)
                let dic = json as! NSDictionary
                let code = dic["code"] as! NSString
                if(code == "200"){
                    
                    let myCountry = dic["msg"] as? NSArray
                    if let data = myCountry![0] as? NSDictionary{
                        
                        // print(data)
                        let uid = data["fb_id"] as! String
                        
                        UserDefaults.standard.set(uid, forKey: "uid")
                        
                        self.navigationController?.navigationBar.isHidden = false
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                }else{
                    //  self.alertModule(title:"Error", msg:dic["msg"] as! String)
                    
                }
                
            case .failure(let error):
                
                print(error)
                
            }
        })
        
    }
    
    @IBAction func onTapSubmit(_ sender: Any) {
       
        if (TF1.text == nil || TF2.text == nil || TF3.text == nil || TF4.text == nil || TF5.text == nil || TF6.text == nil){
            
            let alert = UIAlertController(title: "", message: "Please Enter Valid OTP", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }else if (TF1.text == "" || TF2.text == "" || TF3.text == "" || TF4.text == "" || TF5.text == "" || TF6.text == ""){
            
            let alert = UIAlertController(title: "", message: "Please Enter Valid OTP", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else{
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
            let verificationCode1 = TF1.text! + TF2.text! + TF3.text!
        let code2 =  TF4.text! + TF5.text! + TF6.text!
            //TF1.text + TF2.text + TF3.text + TF4.text + TF5.text + Tf6.text
        let code = verificationCode1 + code2
         print(code2)
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: code)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            self.loader.isHidden = false
            self.loader.isLoadable = true
            //print(user?.user)
            //print(error)
            
            if let error = error {
                self.loader.isHidden = true
                self.loader.isLoadable = false
                print(error.localizedDescription)
                return
                
            }else if error == nil{
                self.loader.isHidden = true
                self.loader.isLoadable = false
                if let id = user?.user.uid{
                self.fb_Id = id
            }
                self.SignUpApi()
            }
          }
        }
    }
    
    //MARK: Resend  OTP button Clicked
    @IBAction func resendOTP(_ sender: Any) {
        self.loader.isHidden = false
        self.loader.isLoadable = true
        Auth.auth().settings?.isAppVerificationDisabledForTesting = false
        
        PhoneAuthProvider.provider().verifyPhoneNumber(mobNo, uiDelegate: nil) { (verificationId, error) in
            
            if error == nil{
                self.loader.isHidden = true
                self.loader.isLoadable = false
                print(verificationId)
                let alert = UIAlertController(title: "", message: "OTP sent successfully on your Phone Number", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                UserDefaults.standard.set(verificationId, forKey: "authVerificationID")
                
            }else{
                self.loader.isHidden = true
                self.loader.isLoadable = false
                let alert = UIAlertController(title: "", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                      self.present(alert, animated: true, completion: nil)
                print("Unable to get secret verification code", error?.localizedDescription)
            }
        }
    }
    //    func textFieldDidBeginEditing(_ textField: UITextField) {
    //        textField.layer.borderColor = UIColor.blue.cgColor
    //    }
    
    //MARK: Text Feild Delegates Method
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if((textField.text?.count)! < 1) && (string.count > 0) {
            
            if textField == TF1 {
                TF2.becomeFirstResponder()
                TF1.layer.borderColor = UIColor.white.cgColor
                TF3.layer.borderColor = UIColor.white.cgColor
                TF4.layer.borderColor = UIColor.white.cgColor
                TF5.layer.borderColor = UIColor.white.cgColor
                TF6.layer.borderColor = UIColor.white.cgColor
                
                TF2.layer.borderColor = UIColor.blue.cgColor
            }
            
            if textField == TF2 {
                TF3.becomeFirstResponder()
                TF2.layer.borderColor = UIColor.white.cgColor
                TF1.layer.borderColor = UIColor.white.cgColor
                TF4.layer.borderColor = UIColor.white.cgColor
                TF5.layer.borderColor = UIColor.white.cgColor
                TF6.layer.borderColor = UIColor.white.cgColor
                
                TF3.layer.borderColor = UIColor.blue.cgColor
            }
            
            if textField == TF3 {
                TF4.becomeFirstResponder()
                TF3.layer.borderColor = UIColor.white.cgColor
                TF1.layer.borderColor = UIColor.white.cgColor
                TF2.layer.borderColor = UIColor.white.cgColor
                TF5.layer.borderColor = UIColor.white.cgColor
                TF6.layer.borderColor = UIColor.white.cgColor
                
                TF4.layer.borderColor = UIColor.blue.cgColor
            }
            
            if textField == TF4 {
                TF5.becomeFirstResponder()
                TF4.layer.borderColor = UIColor.white.cgColor
                TF3.layer.borderColor = UIColor.white.cgColor
                TF1.layer.borderColor = UIColor.white.cgColor
                TF2.layer.borderColor = UIColor.white.cgColor
                TF6.layer.borderColor = UIColor.white.cgColor
                
                TF5.layer.borderColor = UIColor.blue.cgColor
            }
            
            if textField == TF5 {
                TF6.becomeFirstResponder()
                TF5.layer.borderColor = UIColor.white.cgColor
                TF4.layer.borderColor = UIColor.white.cgColor
                TF3.layer.borderColor = UIColor.white.cgColor
                TF1.layer.borderColor = UIColor.white.cgColor
                TF2.layer.borderColor = UIColor.white.cgColor
                
                TF6.layer.borderColor = UIColor.blue.cgColor
            }
            
            textField.text = string
            return false
        }
            
        else if ((textField.text?.count)! >= 1) && (string.count == 0) {
            
            if textField == TF1 {
                TF1.becomeFirstResponder()
                TF6.layer.borderColor = UIColor.white.cgColor
                TF5.layer.borderColor = UIColor.white.cgColor
                TF4.layer.borderColor = UIColor.white.cgColor
                TF3.layer.borderColor = UIColor.white.cgColor
                TF2.layer.borderColor = UIColor.white.cgColor
                
                TF1.layer.borderColor = UIColor.blue.cgColor
            }
            
            if textField == TF2 {
                TF1.becomeFirstResponder()
                TF6.layer.borderColor = UIColor.white.cgColor
                TF5.layer.borderColor = UIColor.white.cgColor
                TF4.layer.borderColor = UIColor.white.cgColor
                TF3.layer.borderColor = UIColor.white.cgColor
                TF2.layer.borderColor = UIColor.white.cgColor
                
                TF1.layer.borderColor = UIColor.blue.cgColor
            }
            
            if textField == TF3 {
                TF2.becomeFirstResponder()
                TF6.layer.borderColor = UIColor.white.cgColor
                TF5.layer.borderColor = UIColor.white.cgColor
                TF4.layer.borderColor = UIColor.white.cgColor
                TF3.layer.borderColor = UIColor.white.cgColor
                TF1.layer.borderColor = UIColor.white.cgColor
                
                TF2.layer.borderColor = UIColor.blue.cgColor
            }
            
            if textField == TF4 {
                TF3.becomeFirstResponder()
                TF6.layer.borderColor = UIColor.white.cgColor
                TF5.layer.borderColor = UIColor.white.cgColor
                TF4.layer.borderColor = UIColor.white.cgColor
                TF1.layer.borderColor = UIColor.white.cgColor
                TF2.layer.borderColor = UIColor.white.cgColor
                
                TF3.layer.borderColor = UIColor.blue.cgColor
            }
            
            if textField == TF5 {
                TF4.becomeFirstResponder()
                TF6.layer.borderColor = UIColor.white.cgColor
                TF5.layer.borderColor = UIColor.white.cgColor
                TF1.layer.borderColor = UIColor.white.cgColor
                TF3.layer.borderColor = UIColor.white.cgColor
                TF2.layer.borderColor = UIColor.white.cgColor
                
                TF4.layer.borderColor = UIColor.blue.cgColor
            }
            
            if textField == TF6 {
                TF5.becomeFirstResponder()
                TF1.layer.borderColor = UIColor.white.cgColor
                TF6.layer.borderColor = UIColor.white.cgColor
                TF4.layer.borderColor = UIColor.white.cgColor
                TF3.layer.borderColor = UIColor.white.cgColor
                TF2.layer.borderColor = UIColor.white.cgColor
                
                TF5.layer.borderColor = UIColor.blue.cgColor
            }
            
            textField.text = ""
            return false
        }
            
            
        else if ((textField.text?.count)! >= 1) {
            
            textField.text = string
            return false
        }
        return true
    }


}


