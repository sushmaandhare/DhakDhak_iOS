//  LoginVC.swift
//  TIK TIK
//  Created by Apple on 31/08/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.


import UIKit
import FlagPhoneNumber
import AuthenticationServices
import FirebaseAuth

class LoginVC: UIViewController {

    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var mobileNoTF: UITextField!
    @IBOutlet weak var countryTF: FPNTextField!
    @IBOutlet weak var btnSend: UIButton!
    
    var listController: FPNCountryListViewController = FPNCountryListViewController(style: .grouped)
    var countryCode : String = ""
    
    
    override func viewDidLoad() {
            super.viewDidLoad()

        loader.isHidden = true
        //self.navigationController?.navigationBar.isHidden = false
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tap)
            countryTF.borderStyle = .roundedRect
    //        countryTF.pickerView.showPhoneNumbers = false
            countryTF.text = countryCode
            countryTF.displayMode = .picker // .picker by default

            listController.setup(repository: countryTF.countryRepository)

            listController.didSelect = { [weak self] country in
                self?.countryTF.setFlag(countryCode: country.code)
            }

            countryTF.delegate = self
            countryTF.font = UIFont.systemFont(ofSize: 14)

        // The placeholder is an example phone number of the selected country by default. You can add your own placeholder :
        countryTF.hasPhoneNumberExample = false
        countryTF.placeholder = ""
        
            // Custom the size/edgeInsets of the flag button
            countryTF.flagButtonSize = CGSize(width: 35, height: 35)
            countryTF.flagButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
            // Set the flag image with a region code
        countryTF.setFlag(countryCode: .IN)

        }
    
    //MARK: On tap send OTP
    @IBAction func onTapSendOTP(_ sender: Any) {
        loader.isHidden = false
        loader.isLoadable = true
        btnSend.isEnabled = false
        
        guard let mobile = mobileNoTF.text else {
            
            return alertModule(title: "Error", msg: "Mobile number is incorrect")
        }
        
        let mobNo = countryCode + " " + mobile
        //print(mobNo)
        
        UserDefaults.standard.set(mobNo, forKey: "MoblieNumber")
        
        Auth.auth().settings?.isAppVerificationDisabledForTesting = false
        
        PhoneAuthProvider.provider().verifyPhoneNumber(mobNo, uiDelegate: nil) { (verificationId, error) in
         
            if error == nil{
                self.loader.isHidden = true
                self.loader.isLoadable = false
               // print("verificationId",verificationId)
                UserDefaults.standard.set(verificationId, forKey: "authVerificationID")
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc: OTPVC = storyboard.instantiateViewController(withIdentifier: "OTPVC") as! OTPVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                self.loader.isHidden = true
                self.loader.isLoadable = false
                self.btnSend.isEnabled = true
                let alert = UIAlertController(title: "", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                      self.present(alert, animated: true, completion: nil)
                print("Unable to get secret verification code", error?.localizedDescription)
            }
        }
    }

     @IBAction func dismissView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissCountries() {
        listController.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "OTPVC" {
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: OTPVC = storyboard.instantiateViewController(withIdentifier: "OTPVC") as! OTPVC
            vc.mobNo = countryCode + " " + mobileNoTF.text!
        }
        
    }
    
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
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

extension LoginVC: FPNTextFieldDelegate {

    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        textField.rightViewMode = .always
       // textField.rightView = UIImageView(image: isValid ? #imageLiteral(resourceName: "success") : #imageLiteral(resourceName: "error"))

        print(
            isValid,
            textField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil",
            textField.getFormattedPhoneNumber(format: .International) ?? "International: nil",
            textField.getFormattedPhoneNumber(format: .National) ?? "National: nil",
            textField.getFormattedPhoneNumber(format: .RFC3966) ?? "RFC3966: nil",
            textField.getRawPhoneNumber() ?? "Raw: nil"
        )
    }

    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
      //  print(name, dialCode, code)
        countryCode = dialCode
    }

    func fpnDisplayCountryList() {
        let navigationViewController = UINavigationController(rootViewController: listController)

        listController.title = "Countries"
        listController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissCountries))

        self.present(navigationViewController, animated: true, completion: nil)
    }
}

