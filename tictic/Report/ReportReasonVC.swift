//
//  ReportReasonVC.swift
//  TIK TIK
//
//  Created by MacBook Air on 04/04/1943 Saka.
//  Copyright © 1943 Rao Mudassar. All rights reserved.
//

import UIKit

class ReportReasonVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   

    @IBOutlet weak var tableView: UITableView!
    
    var videoId : String!
    var reasonArr : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        reasonArr = ["Spam", "Offensive content", "Violent or Graphic cpntent", "Intellectual property infringement", "Fraud or Scam", "Dangerous Goods or Services", "Copyright infringement", "Others"]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reasonArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ReportReasonTVC = self.tableView.dequeueReusableCell(withIdentifier: "ReportReasonTVC") as! ReportReasonTVC
        
        cell.lblReason.text = reasonArr[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let yourVC: ReportDetailsVC = storyboard.instantiateViewController(withIdentifier: "ReportDetailsVC") as! ReportDetailsVC
        yourVC.reason = reasonArr[indexPath.row]
        yourVC.videoId = self.videoId
        self.navigationController?.pushViewController(yourVC, animated: true)
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

class ReportReasonTVC: UITableViewCell {
    
    @IBOutlet weak var lblReason: UILabel!
    
    
    @IBOutlet weak var innerview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
