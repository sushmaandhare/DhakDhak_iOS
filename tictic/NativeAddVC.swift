//
//  NativeAddVC.swift
//  TIK TIK
//
//  Created by MacBook Air on 13/05/1943 Saka.
//  Copyright © 1943 Rao Mudassar. All rights reserved.
//

import UIKit
import GoogleMobileAds

class NativeAddVC: UIViewController , GADNativeCustomTemplateAdLoaderDelegate {
    func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [String] {
        return [""]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeCustomTemplateAd: GADNativeCustomTemplateAd) {
        
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        
    }
    
    
    var adLoader: GADAdLoader!

    override func viewDidLoad() {
      super.viewDidLoad()

      let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
      multipleAdsOptions.numberOfAds = 5

      adLoader = GADAdLoader(adUnitID: "ca-app-pub-3940256099942544/3986624511", rootViewController: self,
                             adTypes: [.nativeCustomTemplate],
          options: [multipleAdsOptions])
      adLoader.delegate = self
      adLoader.load(GADRequest())
    }

    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeAd: GADNativeAd) {
      // A native ad has loaded, and can be displayed.
    }

    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        // The adLoader has finished loading ads, and a new request can be sent.
    }

  }
