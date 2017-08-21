//
//  DFPAddView.swift
//  DFPDemo
//
//  Created by Ankit Panchal on 11/08/17.
//  Copyright © 2017 Ankit Panchal. All rights reserved.
//

import UIKit
import GoogleMobileAds
enum AdsType {
    case BannerView
    case Interstitial
    case NativeContent
    case NativeAppInstall
    case CustomRendering
}
class DFPAddView: NSObject {
    //variable declateation 
    var nativTemplateId:String?
    var adsUnitId:String?
    var adsType:AdsType = .BannerView
    var bannerview: DFPBannerView?
    var NativeContentView:GADNativeContentAdView?
    var NativeAppInstallView:GADNativeAppInstallAdView?
    var custumAddView:MySimpleNativeAdView?
    var adsShowingRootVC:UIViewController?
    var adsViewSize:CGSize?
    /// The interstitial ad.
    var interstitial: DFPInterstitial?
    //BannerView Clouser
    var  banerViewRecieveAds: ((_ bannerView: DFPBannerView) -> Void)? = nil
    var banerViewLeaveApp:((_ bannerView:DFPBannerView) -> Void)? = nil
    var banerViewFailToLoad: ((_ bannerView:DFPBannerView, _ error:GADRequestError) -> Void)? = nil
    //Interstitial Clouser
    var interstitialReciveAds:((_ interstitialAd:DFPInterstitial) -> Void)? = nil
    var interstitialLeaveApp: ((_ interstitialAd:DFPInterstitial) -> Void)? = nil
    var interstitialFailToLoad: ((_ interstitialAd:DFPInterstitial,_ error:GADRequestError) -> Void)? = nil
    
    //Common clouser for nativeContent,nativeAppInstall, custumAdd
    var nativeCustumViewFailToLoad: ((_ error:GADRequestError) -> Void)? = nil
    //NativeContentView Clouser
    var nativeContentViewRecieveAds: ((_ nativeContentView:GADNativeContentAdView) -> Void)? = nil
    //NativeAppInstallView Clouser
    var nativeAppInstallViewRecieveAds: ((_ nativeContentView:GADNativeAppInstallAdView) -> Void)? = nil
    //CustumView Clouser
    var custumAdRecieveAds: ((_ nativeContentView:MySimpleNativeAdView) -> Void)? = nil
    
    init(adType: AdsType,withRootVC rootVC: UIViewController,withAdUnitId unitId:String,withNativeTemplate nativeTempateId:String = "",withAdsViewSize ViewSize:CGSize ) {
        super.init()
        self.adsType = adType
        self.adsUnitId = unitId
        self.adsShowingRootVC = rootVC
        self.adsViewSize = ViewSize
        self.nativTemplateId = nativeTempateId
        self.setupAdd()
    }
    
    func setupAdd() -> Void {
        switch self.adsType {
        case .BannerView:
            self.setupBannerView()
            break
        case .Interstitial:
            self.setupInterstinalView()
            break
        case .NativeContent:
            self.setupNativeContenView()
            break
        case .NativeAppInstall:
            self.setupNativeAppInstallView()
            break
        case .CustomRendering:
            self.setupCustumAdView()
            break
        }
    }
    //MARK:- BannerView initialization
    func setupBannerView() -> Void {
        self.bannerview = DFPBannerView.init(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        self.bannerview?.adUnitID = self.adsUnitId
        self.bannerview?.rootViewController = self.adsShowingRootVC
        self.bannerview?.delegate = self
        self.bannerview?.load(DFPRequest())
    }
    //MARK:- Interstitial initialization
    func setupInterstinalView() -> Void {
        self.interstitial = DFPInterstitial(adUnitID: self.adsUnitId!)
        self.interstitial?.delegate = self
        self.interstitial?.load(DFPRequest())
    }
    //MARK:- NativeContentView initialization
    func setupNativeContenView() -> Void {
        let NativeContentVC = UIStoryboard.init(name: "AdStoryboard", bundle: nil).instantiateViewController(withIdentifier: "NativeContentADVC") as! NativeContentADVC
        self.NativeContentView = NativeContentVC.view as? GADNativeContentAdView
        let videoOptions = GADVideoOptions()
        videoOptions.startMuted = true
       let adLoader = GADAdLoader(adUnitID: self.adsUnitId!, rootViewController: self.adsShowingRootVC,
                               adTypes: [kGADAdLoaderAdTypeNativeContent], options: [videoOptions])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    //MARK:- NativeAppInstall initialization
    func setupNativeAppInstallView() -> Void {
        let NativeInstallVC = UIStoryboard.init(name: "AdStoryboard", bundle: nil).instantiateViewController(withIdentifier: "NativeAppInstallADVC") as! NativeAppInstallADVC
        self.NativeAppInstallView = NativeInstallVC.view as? GADNativeAppInstallAdView
        let videoOptions = GADVideoOptions()
        videoOptions.startMuted = true
        let adLoader = GADAdLoader(adUnitID: self.adsUnitId!, rootViewController: self.adsShowingRootVC,
                                   adTypes: [kGADAdLoaderAdTypeNativeAppInstall], options: [videoOptions])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    //MARK:- CustumAd initialization
    func setupCustumAdView() -> Void {
        let NativeInstallVC = UIStoryboard.init(name: "AdStoryboard", bundle: nil).instantiateViewController(withIdentifier: "CustumADVC") as! CustumADVC
        self.custumAddView = NativeInstallVC.view as? MySimpleNativeAdView
        let videoOptions = GADVideoOptions()
        videoOptions.startMuted = true
        let adLoader = GADAdLoader(adUnitID: self.adsUnitId!, rootViewController: self.adsShowingRootVC,
                                   adTypes: [kGADAdLoaderAdTypeNativeCustomTemplate], options: [videoOptions])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    func imageOfStars(fromStarRating starRating: NSDecimalNumber) -> UIImage? {
        let rating = starRating.doubleValue
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

//MARK:- comn  Delegate for nativeContent, nativeAppInstall & custumAdView
extension DFPAddView: GADAdLoaderDelegate{
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        guard self.nativeCustumViewFailToLoad != nil else {
            return
        }
        self.nativeCustumViewFailToLoad!(error)
    }
}
extension DFPAddView: GADVideoControllerDelegate{
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
        
    }
}
//MARK:- NativeContenView Delegate
extension DFPAddView: GADNativeContentAdLoaderDelegate{
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd) {
        
        self.NativeContentView?.nativeContentAd = nativeContentAd
        (self.NativeContentView?.headlineView as? UILabel)?.text = nativeContentAd.headline
        (self.NativeContentView?.bodyView as? UILabel)?.text = nativeContentAd.body
        (self.NativeContentView?.advertiserView as? UILabel)?.text = nativeContentAd.advertiser
        (self.NativeContentView?.callToActionView as? UIButton)?.setTitle(nativeContentAd.callToAction, for: .normal)
        if (nativeContentAd.videoController.hasVideoContent()) {
            nativeContentAd.videoController.delegate = self
        }
        // These assets are not guaranteed to be present, and should be checked first.
        if let image = nativeContentAd.logo?.image {
            (self.NativeContentView?.logoView as? UIImageView)?.image = image
            self.NativeContentView?.logoView?.isHidden = false
        }else {
            self.NativeContentView?.logoView?.isHidden = true
        }
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        self.NativeContentView?.callToActionView?.isUserInteractionEnabled = false
        guard self.nativeContentViewRecieveAds != nil else {
            return
        }
        self.nativeContentViewRecieveAds!(self.NativeContentView!)
    }
    
}
//MARK:- NativeAppInstallView Delegate
extension DFPAddView: GADNativeAppInstallAdLoaderDelegate{
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAppInstallAd: GADNativeAppInstallAd) {
        self.NativeAppInstallView?.nativeAppInstallAd = nativeAppInstallAd
        // Populate the app install ad view with the app install ad assets.
        // Some assets are guaranteed to be present in every app install ad.
        (self.NativeAppInstallView?.headlineView as! UILabel).text = nativeAppInstallAd.headline
        (self.NativeAppInstallView?.iconView as! UIImageView).image = nativeAppInstallAd.icon?.image
        (self.NativeAppInstallView?.bodyView as! UILabel).text = nativeAppInstallAd.body
        (self.NativeAppInstallView?.callToActionView as! UIButton).setTitle(nativeAppInstallAd.callToAction, for: .normal)
        
       
        if (nativeAppInstallAd.videoController.hasVideoContent()) {
            nativeAppInstallAd.videoController.delegate = self
        }
        // These assets are not guaranteed to be present, and should be checked first.
        if let starRating = nativeAppInstallAd.starRating {
            (self.NativeAppInstallView?.starRatingView as? UIImageView)?.image = imageOfStars(fromStarRating:starRating)
            self.NativeAppInstallView?.starRatingView?.isHidden = false
        }
        else {
            self.NativeAppInstallView?.starRatingView?.isHidden = true
        }
        if let store = nativeAppInstallAd.store {
            (self.NativeAppInstallView?.storeView as? UILabel)?.text = store
            self.NativeAppInstallView?.storeView?.isHidden = false
        }
        else {
            self.NativeAppInstallView?.storeView?.isHidden = true
        }
        if let price = nativeAppInstallAd.price {
            (self.NativeAppInstallView?.priceView as? UILabel)?.text = price
            self.NativeAppInstallView?.priceView?.isHidden = false
        }
        else {
            self.NativeAppInstallView?.priceView?.isHidden = true
        }
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        self.NativeAppInstallView?.callToActionView?.isUserInteractionEnabled = false
        guard self.nativeAppInstallViewRecieveAds != nil else {
            return
        }
        self.nativeAppInstallViewRecieveAds!(self.NativeAppInstallView!)
    }

    
}

//MARK:- CustumAdView Delegate
extension DFPAddView: GADNativeCustomTemplateAdLoaderDelegate{

    func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [Any] {
        return [ AdUnitIds().nativeCustomTemplateId ]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeCustomTemplateAd: GADNativeCustomTemplateAd) {
        
        if (nativeCustomTemplateAd.videoController.hasVideoContent()) {
            nativeCustomTemplateAd.videoController.delegate = self
        }
        // Populate the custom native ad view with the custom native ad assets.
        self.custumAddView?.populate(withCustomNativeAd:nativeCustomTemplateAd)
        guard self.custumAdRecieveAds != nil else {
            return
        }
        self.custumAdRecieveAds!(self.custumAddView!)
    }
    
}
//MARK:- Interstitial Delegate
extension DFPAddView: GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        guard self.interstitialReciveAds != nil else {
            return
        }
        self.interstitialReciveAds!(self.interstitial!)
    }
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        guard self.interstitialLeaveApp != nil else {
            return
        }
        self.interstitialLeaveApp!(self.interstitial!)
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        guard self.interstitialFailToLoad != nil else {
            return
        }
        self.interstitialFailToLoad!(self.interstitial!,error)
    }
}

//MARK:- BannerView Delegate
extension DFPAddView:GADBannerViewDelegate{
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        guard self.banerViewRecieveAds != nil else {
            return
        }
        self.banerViewRecieveAds!(self.bannerview!)
    }
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        guard self.banerViewLeaveApp != nil else {
            return
        }
        self.banerViewLeaveApp!(self.bannerview!)
    }
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        guard self.banerViewFailToLoad != nil else {
            return
        }
        self.banerViewFailToLoad!(self.bannerview!,error)
    }
}
