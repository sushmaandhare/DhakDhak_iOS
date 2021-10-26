//
//  ReportDetailsVC.swift
//  TIK TIK
//
//  Created by MacBook Air on 04/04/1943 Saka.
//  Copyright © 1943 Rao Mudassar. All rights reserved.
//

import UIKit
import Alamofire

class ReportDetailsVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var lblReport: UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var txtView: UITextView!
    
    var reason : String!
    var videoId : String!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtView.delegate = self
        self.lblReport.text = self.reason

        let colors = [UIColor(red: 255/255, green: 81/255, blue: 47/255, alpha: 1.0), UIColor(red: 221/255, green: 36/255, blue: 181/255, alpha: 1.0)]
        self.btnSubmit.setGradientBackgroundColors(colors, direction: .toBottom, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func onTapSubmit(_ sender: UIButton) {
        self.reportUser_API(reportText: txtView.text, videoId: videoId)
    }
    
    func reportUser_API(reportText:String,videoId:String){
           
           let id = UserDefaults.standard.string(forKey: "fb_Id")
         //  print("id",id)
           
           let url : String = self.appDelegate.baseUrl!+self.appDelegate.reportUser
           
           let  sv = HomeViewController.displaySpinner(onView: self.view)
        let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "fb_Id") ?? "","video_id": videoId,"comment":reportText, "type" : self.reason]

        //   print(url)
        //   print(parameter!)
           
           let headers: HTTPHeaders = [
               "api-key": "4444-3333-2222-1111"
           ]
           
           AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
               
               respones in
          //     print(respones)
               
               switch respones.result {
               case .success( let value):
                
                   
                   let json  = value
                   HomeViewController.removeSpinner(spinner: sv)
                   //print(json)
                   
                   let dic = json as! NSDictionary
                   let code = dic["code"] as! NSString
                   
                   if(code == "200"){
                     
                    //  print("Report User Done")
                      let msg = dic["msg"] as! String
                      self.alertModule(title: "", msg: "\(msg)")
                       
                   }else{
                       
                       self.alertModule(title:"Error", msg:dic["msg"] as? String ?? "error occured")
                   }
               case .failure(let error):
               //    print(error)
                   HomeViewController.removeSpinner(spinner: sv)
                   self.alertModule(title:"Error",msg:error.localizedDescription)
               }
           })
       }
    
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
            alertController.dismiss(animated: true, completion: {
                self.navigationController?.popToRootViewController(animated: true)
            })
        })
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: Texi view delegates method
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.white
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Please write your description details here"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
          textView.resignFirstResponder()
          return false
        }
        return true
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
