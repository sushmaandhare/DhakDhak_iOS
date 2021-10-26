//  AppDelegate.swift
//  tictic
//  Created by Rao Mudassar on 24/04/2019.
//  Copyright © 2019 Rao Mudassar. All rights reserved.

import UIKit
import IQKeyboardManagerSwift
import FBSDKCoreKit
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import UserNotifications
import UserNotifications
import FirebaseInstanceID
import AuthenticationServices
import FirebaseAuth
import Siren // Line 1
import Alamofire
import Firebase
import FirebaseDynamicLinks
import GoogleMobileAds


let NextLevelAlbumTitle = "NextLevel"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate,UNUserNotificationCenterDelegate,MessagingDelegate {
    
    var window: UIWindow?
     // Web Apis Urls
    
 // var baseUrl:String? = "https://dhakdhak.world/API/index.php?p="  // live url
  //  var baseUrl:String? = "https://dhakdhak.world/API/indexnew.php?p="  // test live url
    var baseUrl:String? = "https://the3du.com/API/index.php?p=" // test url
    
    var imgbaseUrl:String? = "https://the3du.com/test/API/"// //"https://dhakdhak.world/API/dhakdhak"//
    var sharURl:String? =  "http://domain.com/"
    var signUp:String? = "signup"
  //  var uploadVideo:String? = "uploadVideoDuetTest"
    var uploadVideo:String? = "uploadVideoDuet"
    var SearchByHashTag:String = "SearchByHashTag"
    var showAllVideos:String? = "showAllVideos"
    var showMyAllVideos:String? = "showMyAllVideos"
    var likeDislikeVideo:String? = "likeDislikeVideo"
    var postComment:String? = "postComment"
    var showVideoComments:String? = "showVideoComments"
    var updateVideoView:String? = "updateVideoView"
    var fav_sound:String? = "fav_sound"
    var my_FavSound:String? = "my_FavSound"
    var allSounds:String? = "allSounds"
    var my_liked_video:String? = "my_liked_video"
    var discover:String? = "discover_new"
    var edit_profile:String? = "edit_profile"
    var follow_users:String? = "follow_users"
    var get_user_data:String? = "get_user_data"
    var uploadImage:String? = "uploadImage"
    var get_followers:String? = "get_followers"
    var get_followings:String? = "get_followings"
    var downloadFile:String? = "downloadFile"
    var getNotifications:String? = "getNotifications"
    var Search_User:String? = "search"
    var Search_Video:String? = "video"
    var Search_sound:String? = "sound"
    var videoRekog:String? = "videoRekog"
    var videoDelete:String? = "DeleteVideo"
    var allSoundsNew:String? = "allSoundsNew"
    var getCategories:String? = "admin_getSoundSection"
    var reportUser = "ReportVideo"
    var showAllVideosNew:String? = "showAllVideosNew"
    var requestVerification = "getVerified"
    var blockUser = "blockUserProfile"
    var blockUserList = "getBlockUserProfile"
    var shareVideo = "updateShareVideo"
    var getBannerImages = "get_banner_data"
    var discover_details = "discover_details"
    var download_url = "https://dhakdhak.world/API//tmp/11994180231618821558.mp4"

    var middle_name = "abfe0129571f3ffe9e28e74f9d09d38d" //Security purpose
    var getShareUserData = "getShareUserData"
    var addTodayLogin:String? = "addTodayLogin"
    var getPointsOfferDetails:String? = "getPointsOfferDetails"
    var showAllVideosList:String? = "showAllVideosList"
    var showAllVideosNewTest:String? = "showAllVideosNewTest"
    var updateFCMId:String? = "updateFcmId"
    
    
    var tabbarSelect = 0
    var SelectedBtn = 0
    var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return self.orientationLock
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if #available(iOS 13.0, *) {
            if (window?.responds(to: #selector(getter: UIView.overrideUserInterfaceStyle)))! {
                window?.setValue(UIUserInterfaceStyle.dark.rawValue, forKey: "overrideUserInterfaceStyle")
            }
           // Siren.shared.wail() // Line 2
        }
        hyperCriticalRulesExample()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        GIDSignIn.sharedInstance().clientID = "71045082327-c5aaj9l6d9483mh38bs4d89ffjngqo5d.apps.googleusercontent.com"
        
        //"425877507102-npepuauv59a5mc1dpfrka6gfgj7aitfg.apps.googleusercontent.com"
        
        //"964642536474-jaldv56dmv19ijuc9nqfos51rt5rji85.apps.googleusercontent.com"
       
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                           categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
          ApplicationDelegate.shared.application(
                  application,
                  didFinishLaunchingWithOptions: launchOptions
              )
//        if let bundleIdentifier = Bundle.main.bundleIdentifier {
//            appSupportURL.appendingPathComponent("\(bundleIdentifier)").appendingPathComponent("Documents")
//        }
    print(UIDevice.current.identifierForVendor?.uuidString)
        return true
    }
    
    //MARK: Hyper critical rules expample for force update
    
    func hyperCriticalRulesExample() {
      
        let siren = Siren.shared
        siren.rulesManager = RulesManager(globalRules: .critical,
                                          showAlertAfterCurrentVersionHasBeenReleasedForDays: 0)
        siren.wail { results in
        
            switch results {
                
            case .success(let updateResults):
                print("AlertAction ", updateResults.alertAction)
                print("Localization ", updateResults.localization)
                print("Model ", updateResults.model)
                print("UpdateType ", updateResults.updateType)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        
        let handled=ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return application(app, open: url,
        sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
        annotation: "")
        
        return GIDSignIn.sharedInstance().handle(url)  || handled
    }
    
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            // ...
        } else {
            print("\(error.localizedDescription)")
        }
        
        
    }
    
    // Register Push Notifications Methods
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
                
                UserDefaults.standard.set("NuLL", forKey:"DeviceToken")
               
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                UserDefaults.standard.set(result.token, forKey:"DeviceToken")
                let firebaseAuth = Auth.auth()
                firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.prod)
                Messaging.messaging().apnsToken = deviceToken
            }
        }
        
    }
    

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!")
    }
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
//                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        print(userInfo)
//        let firebaseAuth = Auth.auth()
//        if (firebaseAuth.canHandleNotification(userInfo)){
//            print(userInfo)
//            if let aps = userInfo["aps"] as? NSDictionary, let notificationData = userInfo["gcm.notification.data"] as? NSString {
//                print(aps)
//                var dictonary:NSDictionary?
//                if let data = notificationData.data(using: String.Encoding.utf8.rawValue) {
//                    do {
//                        dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
//
//                        if let alertDictionary = dictonary {
//                            print(alertDictionary)
//                        }
//                    } catch{
//                        print(error)
//                    }
//                    return
//                }
//            }
//        }
//    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
    }
    
    // Firebase notification received
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
        
        // custom code to handle push while app is in the foreground
        print("Handle push from foreground, received: \n \(notification.request.content)")
        print(notification.request.content.userInfo)
        let userInfo = notification.request.content.userInfo
        if let aps = userInfo["aps"] as? NSDictionary, let notificationData = userInfo["gcm.notification.data"] as? NSString {
            print(aps)
            var dictonary:NSDictionary?
            if let data = notificationData.data(using: String.Encoding.utf8.rawValue) {
                do {
                    dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                    
                    if let alertDictionary = dictonary {
                        print(alertDictionary)
                    }
                } catch{
                    print(error)
                }
                return
            }
        }
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle tapped push from background, received: \n \(response.notification.request.content.userInfo)")
        let userInfo = response.notification.request.content.userInfo
        let action = userInfo["click_action"] as? String
        if action == "USER_CLICK"{
            //  let rootViewController = self.window!.rootViewController as! UINavigationController
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let profileViewController = mainStoryboard.instantiateViewController(withIdentifier: "Profile1ViewController") as! Profile1ViewController
            //         rootViewController.pushViewController(profileViewController, animated: true)
            UserDefaults.standard.set("", forKey: "fb_Id")
            StaticData.obj.other_id = userInfo["user_id"] as? String
            profileViewController.isNotification =  true
            self.window?.rootViewController?.present(profileViewController, animated: true, completion: nil)
            //         return true
        }
        
        completionHandler()
    }
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//
//        UserDefaults.standard.set(fcmToken, forKey:"DeviceToken")
//    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")
        UserDefaults.standard.set(fcmToken, forKey:"DeviceToken")
      let dataDict:[String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    
    //MARK: Handle dynamic link
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
      let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
        
        let url = "\(userActivity.webpageURL!)"
        
        if url.contains("user_id"){
            
            let urllastpath = userActivity.webpageURL?.lastPathComponent
            let userid = urllastpath?.replacingOccurrences(of: "user_id", with: "")
            let user = userid?.replacingOccurrences(of: "%3D", with: "")

            UserDefaults.standard.setValue(user, forKey: "referral_fb_id")
print(user)
        self.shareUserData(userid: user ?? "")
        print("dynamiclink",dynamiclink)
            
        }
      }
      return handled
    }
    
    //MARK: Share User Data
    func shareUserData(userid:String){
        
        let url : String = self.baseUrl!+self.getShareUserData
                    
        let udid = UIDevice.current.identifierForVendor?.uuidString

        let parameter :[String:Any]? = ["fb_id":userid,"device_id":udid, "middle_name": self.middle_name]
                    
               // print(url)
               // print(parameter!)
                    
       let headers: HTTPHeaders = ["api-key": "4444-3333-2222-1111"]
        
        AF.request(url, method: .post, parameters: parameter, encoding:JSONEncoding.default, headers:headers).validate().responseString(completionHandler: {
                        
                respones in
            print("respones",respones)
                
                })
        
            }
    
//    @available(iOS 9.0, *)
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
//      return application(app, open: url,
//                         sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//                         annotation: "")
//    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
        // Handle the deep link. For example, show the deep-linked content or
        
    
        print("annotation:",annotation)
        return true
      }
      return false
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
        
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//         let placesData = UserDefaults.standard.object(forKey: "Draft") as? NSData
//        NSKeyedArchiver.archiveRootObject(placesData, toFile: "Draft")
    }


}

