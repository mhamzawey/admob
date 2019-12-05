//
//  ViewController.swift
//  AdMob
//
//  Created by Mohamed Hamza on 21/11/2019.
//  Copyright © 2019 Mohamed Hamza. All rights reserved.
//

import GoogleMobileAds
import GoogleMobileAdsMediationTestSuite
import AdColony


import UIKit

class ViewController: UIViewController,  GADInterstitialDelegate, GADRewardedAdDelegate, GADUnifiedNativeAdLoaderDelegate, GADUnifiedNativeAdDelegate {
    var adLoader: GADAdLoader!
    var interstitial: GADInterstitial!
    var rewarded: GADRewardedAd!
    var bannerAdId: String!
    var interstitialAdId: String!
    var rewardedAdId: String!
    var nativeAdId: String!
    

   

    /// The height constraint applied to the ad view, where necessary.
    var heightConstraint : NSLayoutConstraint?
    
    
    
    /// The native ad view that is being presented.
    var nativeAdView: GADUnifiedNativeAdView!
    
    
    //MARK: Properties
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var nativeAdPlaceholder: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerAdId = "ca-app-pub-5368551910820369/5203909777"
        interstitialAdId = "ca-app-pub-5368551910820369/4629194704"
        rewardedAdId = "ca-app-pub-5368551910820369/2003031365"
        nativeAdId = "ca-app-pub-5368551910820369/5529528623"
        //nativeAdId = "ca-app-pub-3940256099942544/3986624511"
//        bannerAdId = "ca-app-pub-2483783020483884/8216257943"
//        interstitialAdId = "ca-app-pub-2483783020483884/9194297693"
//        rewardedAdId = "ca-app-pub-2483783020483884/6272620888"
//        nativeAdId = "ca-app-pub-3940256099942544/3986624511"
//
        // Banner
        bannerView.adUnitID = bannerAdId
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        //bannerView.delegate = self
        
        // Interstitial
        interstitial = createAndLoadInterstitial()
        
        // Rewarded
        rewarded = createAndLoadRewarded()
        
        // Native
        guard let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil, options: nil),
        let adView = nibObjects.first as? GADUnifiedNativeAdView else {
            assert(false, "Could not load nib file for adView")
        }
        adView.isHidden = true
        setAdView(adView)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // Indicates the GDPR requirement of the user. If it's true, the user's subject to the GDPR laws.
        //GoogleMobileAdsMediationTestSuite.present(on:self, delegate:nil)
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
    
    func adLoader(_ adLoader: GADAdLoader,
                  didReceive nativeAd: GADUnifiedNativeAd) {
        nativeAdView.nativeAd = nativeAd
        nativeAd.delegate=self
        
        heightConstraint?.isActive = false
        
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        let mediaContent = nativeAd.mediaContent
        if mediaContent.hasVideoContent {
          // By acting as the delegate to the GADVideoController, this ViewController receives messages
          // about events in the video lifecycle.
          mediaContent.videoController.delegate = self
          //videoStatusLabel.text = "Ad contains a video asset."
        }
        else {
          //videoStatusLabel.text = "Ad does not contain a video."
        }
        
        if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
          heightConstraint = NSLayoutConstraint(item: mediaView,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: mediaView,
                                                attribute: .width,
                                                multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
                                                constant: 0)
          heightConstraint?.isActive = true
        }
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
          nativeAdView.bodyView?.isHidden = nativeAd.body == nil

          (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
          nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil

          (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
          nativeAdView.iconView?.isHidden = nativeAd.icon == nil

          (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from:nativeAd.starRating)
          nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil

          (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
          nativeAdView.storeView?.isHidden = nativeAd.store == nil

          (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
          nativeAdView.priceView?.isHidden = nativeAd.price == nil

          (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
          nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil

          // In order for the SDK to process touch events properly, user interaction should be disabled.
          nativeAdView.callToActionView?.isUserInteractionEnabled = false
        nativeAdView.isHidden = false     
    }
    
    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
       print("\(#function) called")
     }

     func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
       print("\(#function) called")
     }

     func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
       print("\(#function) called")
     }

     func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
       print("\(#function) called")
     }

     func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
       print("\(#function) called")
     }

     func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
       print("\(#function) called")
     }

    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        // The adLoader has finished loading ads, and a new request can be sent.
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
           print("Loader Failed to recieve ads")
       }
       
    func createAndLoadInterstitial() -> GADInterstitial {
      let interstitial = GADInterstitial(adUnitID: interstitialAdId)
        interstitial.delegate = self
      interstitial.load(GADRequest())
      return interstitial
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      print("interstitialDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
      interstitial = createAndLoadInterstitial()
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      print("interstitialDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      print("interstitialWillLeaveApplication")
    }
    
    
    func createAndLoadRewarded() -> GADRewardedAd{
        let rewarded = GADRewardedAd(adUnitID: rewardedAdId)
        rewarded.load(GADRequest()) { error in
          if let error = error {
            print("Loading failed: \(error)")
          } else {
            print("Loading Succeeded")
          }
        }
        return rewarded
    }
    
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        print("Ad finished")
        rewarded = createAndLoadRewarded()
    }
    
    func setAdView(_ view: GADUnifiedNativeAdView) {
      // Remove the previous ad view.
      nativeAdView = view
      nativeAdPlaceholder.addSubview(nativeAdView)
      nativeAdView.translatesAutoresizingMaskIntoConstraints = false

      // Layout constraints for positioning the native ad view to stretch the entire width and height
      // of the nativeAdPlaceholder.
      let viewDictionary = ["_nativeAdView": nativeAdView!]
      self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[_nativeAdView]|",
                                                              options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
      self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[_nativeAdView]|",
                                                              options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
    }
    
    
    //MARK: Action
    @IBAction func interstitialBtn(_ sender: UIButton) {
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
                
        }
    }
    
    //MARK: Action
    
    @IBAction func rewardedBtn(_ sender: UIButton) {
        if rewarded.isReady == true {
          rewarded.present(fromRootViewController: self, delegate:self)
        }else{
            print("Rewarded Ad wasn't ready")
        }
        
    }
    
    //MARK: Action
    
    
    @IBAction func nativeBtn(_ sender: UIButton) {
        
        adLoader = GADAdLoader(adUnitID: nativeAdId, rootViewController: self,
                               adTypes: [ .unifiedNative ], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
        
        
    }
    
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
      guard let rating = starRating?.doubleValue else {
        return nil
      }
      if rating >= 5 {
        return UIImage(named: "stars_5")
      } else if rating >= 4.5 {
        return UIImage(named: "stars_4_5")
      } else if rating >= 4 {
        return UIImage(named: "stars_4")
      } else if rating >= 3.5 {
        return UIImage(named: "stars_3_5")
      } else {
        return nil
      }
    }
    
}
extension ViewController : GADVideoControllerDelegate {

  func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
   // videoStatusLabel.text = "Video playback has ended."
  }
}

