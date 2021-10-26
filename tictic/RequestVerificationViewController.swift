//
//  RequestVerificationViewController.swift
//  TIK TIK
//
//  Created by Apple on 14/10/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit
import Alamofire

class RequestVerificationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var request_Table: UITableView!
    
    var imagePicker = UIImagePickerController()
    var imageUrl:URL? = nil
    var imge = UIImage()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var baseStr = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        request_Table.tableFooterView = UIView(frame: .zero)
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
  //MARK: Close button clicked
    
    @IBAction func close_ButtonClicked(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Table view delegates method
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rowcount = 0
        
        if section == 0{
            
            rowcount = 1
        }
        else if section == 1{
            
            rowcount = 2
        }
        else if section == 2{
            
            rowcount = 2
        }else if section == 3{
            rowcount = 1
        }
          return rowcount
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if indexPath.section == 0{
            
            let cell1 = request_Table.dequeueReusableCell(withIdentifier: "TextVerificationTableViewCell", for: indexPath) as! TextVerificationTableViewCell
            cell1.text_Lbl.text = "Apply for DhakDhak Verification \n \n \n A verified badge is check that appears next to an DhakDhak accounts name to indicate the the account is the authentic presence of notable public figure, celebrity,global brand or entity it represent.\n \n Submittings a request for Verification \n\n Does not gurantee that your account will be verified"
            cell = cell1
            
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                
                let cell1 = request_Table.dequeueReusableCell(withIdentifier: "UserNameTableViewCell", for: indexPath) as! UserNameTableViewCell
                cell1.username_Lbl.text = "Username"
                cell = cell1
                                       
            }else if indexPath.row == 1{
                
               let cell1 = request_Table.dequeueReusableCell(withIdentifier: "UserNameTableViewCell", for: indexPath) as! UserNameTableViewCell
               cell1.username_Lbl.text = "Full name"
               cell1.username_TextFeild.placeholder = "full name"
               cell = cell1
            
            }
           
        }else if indexPath.section == 2{
            
            if indexPath.row == 0{
                
                let cell1 = request_Table.dequeueReusableCell(withIdentifier: "chooseFileVerificationTableViewCell", for: indexPath) as! chooseFileVerificationTableViewCell
                if imageUrl == nil{
                    cell1.choose_File_Btn.setTitle("Choose File", for: .normal)
                }else{
                 //   cell1.choose_File_Btn.setTitle("\(imageUrl!.lastPathComponent)", for: .normal)
                    cell1.apply_Verfication_Lbl.text = "\(imageUrl!.lastPathComponent)"
                }
                cell1.choose_File_Btn.tag = indexPath.row
                cell1.choose_File_Btn.addTarget(self, action: #selector(chooseFileButtonClicked), for: .touchUpInside)
                cell = cell1
                
            }else if indexPath.row == 1{
                
                let cell1 = request_Table.dequeueReusableCell(withIdentifier: "TextVerificationTableViewCell", for: indexPath) as! TextVerificationTableViewCell
                cell1.text_Lbl.text = "We require a government-issued photo ID that shows your name and date of birth (e.g.driving license, passport pr national identification card)of official business documents(tax, filling,recent utility bill,article of \n\n incorporation) in order to review your request."
                
                cell = cell1
            }
           
        } else if indexPath.section == 3{
            
            let cell1 = request_Table.dequeueReusableCell(withIdentifier: "SendVerificationTableViewCell", for: indexPath) as! SendVerificationTableViewCell
            cell1.send_Btn.tag = indexPath.row
            cell1.send_Btn.addTarget(self, action: #selector(sendRequestForVerification), for: .touchUpInside)
            cell = cell1
        }
          return cell
      }
    
    
    //MARK: Choose File button clicked
    @objc func chooseFileButtonClicked(){
        
        print("choose file button clicked")
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                  print("Button capture")
                  imagePicker.sourceType = .photoLibrary
                  imagePicker.allowsEditing = false
                  present(imagePicker, animated: true, completion: nil)
        }
    }
    
  
    //MARK:- UIImagePickerViewDelegate.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        self.dismiss(animated: true) { [weak self] in

            guard let image = info[UIImagePickerController.InfoKey.imageURL] as? URL else { return }
            //Setting image to your image view
            let img =  info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            print(image)
            self?.imageUrl = image
            self?.request_Table.reloadData()
            self?.imge = img!
            
            let imageData: Data? = img!.jpegData(compressionQuality: 0.4)
            let imageStr = imageData?.base64EncodedString(options: .lineLength64Characters) ?? ""
            self!.baseStr = imageStr
            print(imageStr,"imageString")
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Send request for verification button clicked
    
    @objc func sendRequestForVerification(){
        
        print("Send Verification")
        
        let indexpathForEmail = NSIndexPath(row: 0, section: 1)
        let emailCell = request_Table.cellForRow(at: indexpathForEmail as IndexPath)! as! UserNameTableViewCell

        let indexpathForPass = NSIndexPath(row: 1, section: 1)
        let passCell =  request_Table.cellForRow(at: indexpathForPass as IndexPath)! as! UserNameTableViewCell
        
        let username = emailCell.username_TextFeild.text
        let fullName = passCell.username_TextFeild.text
        print(username)
        print(fullName)
        if username == "" || username == nil{
            
            alertModule(title: "", msg: "Please enter Username")
            
        }else if fullName == "" || fullName == nil{
            
            alertModule(title: "", msg: "Please enter Fullname")
            
        }else if baseStr == "" || baseStr == nil{
            
            alertModule(title: "", msg: "Please select Photo for Apply verification")

        }else{
            
         requestVerification_Api(username: username!, fullname: fullName!, attchmnet: baseStr)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat = 0
        
        if indexPath.section == 0{
            
            height = UITableView.automaticDimension
            
        }else if indexPath.section == 1{
            
            height = 100
            
        }else if indexPath.section == 2{
           
            if indexPath.row == 0{
                
                height = 100

            }else if indexPath.row == 1{
                
                height = UITableView.automaticDimension
            }
            
        }else if indexPath.section == 3{
            
            height = 80
        }
        return height
    }
    
    //MARK: Request verification API
    
    func requestVerification_Api(username:String,fullname:String,attchmnet:String){
        
           //  flagforMyVideo = true
            let url : String = self.appDelegate.baseUrl!+self.appDelegate.requestVerification
            let  sv = HomeViewController.displaySpinner(onView: self.view)
           //  var acctment = profile_pic
             let parameter :[String:Any]? = ["fb_id":UserDefaults.standard.string(forKey: "uid")!,"Full name":fullname, "middle_name": self.appDelegate.middle_name,"Username":username,"attachment":attchmnet]
           
             print(url)
           // print(parameter!)
          
             let headers: HTTPHeaders = [
                 "api-key": "4444-3333-2222-1111"
             ]
             
             AF.request(url, method: .post, parameters:parameter, encoding:JSONEncoding.default, headers:headers).validate().responseJSON(completionHandler: {
                 
                 respones in
                 
                 switch respones.result {
                 case .success( let value):
                     
                     let json  = value
                     
                     HomeViewController.removeSpinner(spinner: sv)
                     
                      // print(json)
                     let dic = json as! NSDictionary
                     let code = dic["code"] as! NSString
                     if(code == "200"){
                         
                        let alert = UIAlertController(title: "Successfully send for verification", message: "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                     }else{
                         
                         self.alertModule(title:"Error", msg:dic["msg"] as! String)
                     }
          
                 case .failure(let error):
                     print(error)
                     HomeViewController.removeSpinner(spinner: sv)
                     self.alertModule(title:"Error",msg:error.localizedDescription)
                 }
             })
         }
    
    //MARK: Alert Module
    func alertModule(title:String,msg:String){
           let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
           let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
               alertController.dismiss(animated: true, completion: nil)
           })
           alertController.addAction(alertAction)
           present(alertController, animated: true, completion: nil)
       }
}
