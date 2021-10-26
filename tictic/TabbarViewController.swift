//  TabbarViewController.swift
//  TIK TIK
//  Created by Rao Mudassar on 24/04/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.

import UIKit

class TabbarViewController: UITabBarController,UITabBarControllerDelegate {
    
    //var button = UIButton(type: .custom)
    
    var bgView:UIImageView?
    
   let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
          self.delegate = self
         
         self.tabBar.isTranslucent = false
//
//         UITabBar.appearance().unselectedItemTintColor = UIColor(red: 205, green: 205, blue: 205, alpha: 1)
//
//         UITabBar.appearance().tintColor = UIColor.white
//         self.bgView?.removeFromSuperview()
//
//         let screenSize = UIScreen.main.bounds
//         let screenWidth = screenSize.width
//         let screenHeight = screenSize.height
//         bgView = UIImageView(image: UIImage(named: "Untitled drawing"))
//         bgView!.frame = CGRect(x: 0, y: screenHeight-60, width:screenWidth, height: 60)
//
//         self.view.addSubview(bgView!)
        
        
//        let frost = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        frost.frame = self.tabBar.bounds
//        self.view.addSubview(frost)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 25, y: -15, width: self.tabBar.bounds.width - 50, height: self.tabBar.bounds.height + 10), cornerRadius: (self.tabBar.frame.width/2)).cgPath
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        layer.shadowRadius = 25.0
        layer.shadowOpacity = 0.3
        layer.borderWidth = 1.0
        layer.opacity = 0.75
        layer.isHidden = false
        layer.masksToBounds = false
        layer.fillColor = UIColor.darkGray.cgColor
        UITabBar.appearance().backgroundColor = UIColor.clear
        self.tabBar.layer.insertSublayer(layer, at: 0)
        
        if let items = self.tabBar.items {
          items.forEach { item in item.imageInsets = UIEdgeInsets(top: -15, left: 0, bottom:0, right: 0) }
        }

        self.tabBar.itemWidth = 35.0
        
        self.tabBar.itemPositioning = .centered
        self.tabBar.backgroundImage = UIImage(color: .clear, size: CGSize(width: self.tabBar.frame.width, height: self.tabBar.frame.height))
        
        self.view.bringSubviewToFront(self.tabBar)
        print(self.view.safeAreaHeight)
        
    }
    
    // Add Custom video making button in tabbar
    private func addCenterButton() {
        // button.setTitle("DhakDhak", for: .normal)
        let button = UIButton()
        button.setImage(UIImage(named: "dhakdhak_final"), for: .normal)
        let square = self.tabBar.frame.size.height
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        button.center = self.tabBar.center
        self.view.addSubview(button)
        self.view.bringSubviewToFront(button)
        tabBar.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        tabBar.topAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        button.addTarget(self, action: #selector(didTouchCenterButton(_:)), for: .touchUpInside)
    }
    
    @objc
    private func didTouchCenterButton(_ sender: AnyObject) {
        
        if(UserDefaults.standard.string(forKey: "uid") == ""){
            
            self.alertModule(title:"DhakDhak", msg: "Please login from profile to upload video!")
            
            
        }else{
            
          DispatchQueue.main.async {
              let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
              let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "RecorderVC") as! RecorderVC
              self.present(vc, animated: true, completion: nil)
          }
            
        }
        
       
    }
    
    // Tabbar delegate Method

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController){
        let tabBarIndex = tabBarController.selectedIndex
        
        appDelegate.tabbarSelect = tabBarIndex
        if tabBarIndex == 0{
            tabBar.isHidden = false
            self.tabBar.isTranslucent = true
           // self.bgView?.alpha = 1
            self.tabBarItem.title = " "
        }else if tabBarIndex == 2{
            tabBar.isHidden = true
            self.tabBarItem.title = " "
           
        }else{
            tabBar.isHidden = false
            tabBar.barTintColor = UIColor.black
            self.tabBarItem.title = " "
             // self.tabBar.unselectedItemTintColor = UIColor(red: 205, green: 205, blue: 205, alpha: 1)
            //  button.setImage(UIImage(named: "DhakDhak"), for: .normal)
           //   self.bgView?.alpha = 0
            //you might need to modify this frame to your tabbar frame
              //self.bgView?.removeFromSuperview()
        }
        
    }
    
    func alertModule(title:String,msg:String){
        
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: {(alert : UIAlertAction!) in
        alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    

}

extension UIView {
   var safeAreaHeight: CGFloat {
       if #available(iOS 11, *) {
        return safeAreaLayoutGuide.layoutFrame.size.height
       }
       return bounds.height
  }
}
