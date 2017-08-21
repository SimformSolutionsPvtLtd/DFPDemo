//
//  ViewController.swift
//  DFPDemo
//
//  Created by Ankit Panchal on 11/08/17.
//  Copyright © 2017 Ankit Panchal. All rights reserved.
//

import UIKit
import SVProgressHUD
struct AdUnitIds {
    let bannerId = "/6499/example/banner"
    let interstitialId = "/6499/example/interstitial"
    let contenAdId = "/6499/example/native"
    let nativeCustomTemplateId = "10104090"
}
class ViewController: UIViewController {

    
    @IBOutlet weak var custumswitch: UISwitch!
    @IBOutlet weak var ContentSwitch: UISwitch!
    @IBOutlet weak var appinstallSwitch: UISwitch!
    @IBOutlet weak var interstitialSwitch: UISwitch!
    @IBOutlet weak var bannerSwitch: UISwitch!
    @IBOutlet weak var adView: UIView!
    var adviewManager:DFPAddView?
    var nativeAdView:UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeAdManager()
        configureAdsDelegate()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onRefresh(_ sender: Any) {
        guard self.adviewManager != nil else {
            return
        }
        SVProgressHUD.show()
        if (self.bannerSwitch.isOn){
            adviewManager?.adsType = .BannerView
            adviewManager?.adsUnitId =  AdUnitIds().bannerId
        }else if (self.interstitialSwitch.isOn ){
            adviewManager?.adsType = .Interstitial
            adviewManager?.adsUnitId =  AdUnitIds().interstitialId
        }else if (self.appinstallSwitch.isOn){
            adviewManager?.adsType = .NativeAppInstall
            adviewManager?.adsUnitId =  AdUnitIds().contenAdId
            adviewManager?.nativTemplateId = AdUnitIds().nativeCustomTemplateId
        }else if (self.ContentSwitch.isOn){
            adviewManager?.adsType = .NativeContent
            adviewManager?.adsUnitId =  AdUnitIds().contenAdId
            adviewManager?.nativTemplateId = AdUnitIds().nativeCustomTemplateId
        }else if (self.custumswitch.isOn){
            adviewManager?.adsType = .CustomRendering
            adviewManager?.adsUnitId =  AdUnitIds().contenAdId
            adviewManager?.nativTemplateId = AdUnitIds().nativeCustomTemplateId
        }
        self.adviewManager?.setupAdd()
    }
    func configureAdsDelegate() -> Void {
        adviewManager?.banerViewRecieveAds = {(bannerView) -> Void in
            self.nativeAdView = bannerView
            self.adView.addSubview(bannerView)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            bannerView.frame = CGRect(x: self.adView.frame.size.width/2 - 160, y: 0, width: 320, height: 50)
        }
        adviewManager?.banerViewLeaveApp = {(bannerView) -> Void in
            print("Ads tap and leave app")
        }
        adviewManager?.banerViewFailToLoad = {(bannerView,error) -> Void in
            print("Fail to load ads :\(error.debugDescription)")
            DispatchQueue.main.async {
                self.showError(message: error.debugDescription)
                SVProgressHUD.dismiss()
            }
        }
        
        adviewManager?.interstitialReciveAds = {(interstitialAd) -> Void in
            if (interstitialAd.isReady){
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                interstitialAd.present(fromRootViewController: self)
            }
        }
        adviewManager?.interstitialLeaveApp = {(interstitialAd) -> Void in
            
        }
        adviewManager?.interstitialFailToLoad = {(interstitialAd,error) -> Void in
           print("Fail to load ads :\(error.debugDescription)")
            DispatchQueue.main.async {
                self.showError(message: error.debugDescription)
                SVProgressHUD.dismiss()
            }
        }
        adviewManager?.nativeContentViewRecieveAds = {(nativeAdView) -> Void in
            self.setupNativeAdd(nativeAd: nativeAdView)
        }
        adviewManager?.nativeCustumViewFailToLoad = {(error) -> Void in
           print("Fail to load ads :\(error.debugDescription)")
            DispatchQueue.main.async {
                self.showError(message: error.debugDescription)
                SVProgressHUD.dismiss()
            }
        }
        adviewManager?.nativeAppInstallViewRecieveAds = {(nativeAdView) -> Void in
            self.setupNativeAdd(nativeAd: nativeAdView)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
        adviewManager?.custumAdRecieveAds = {(nativeAdView) -> Void in
            self.setupNativeAdd(nativeAd: nativeAdView)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
    }
    func initializeAdManager() -> Void {
        SVProgressHUD.show()
        adviewManager = DFPAddView.init(adType: .BannerView, withRootVC: self, withAdUnitId: AdUnitIds().bannerId, withAdsViewSize: CGSize(width:UIScreen.main.bounds.size.width, height: 50))
    }
    //MARK:- setup Native adview
    func setupNativeAdd(nativeAd:UIView) -> Void {
        if (nativeAdView != nil){
            self.nativeAdView?.removeFromSuperview()
        }
        nativeAdView = nativeAd
        self.adView.addSubview(nativeAd)
        nativeAd.translatesAutoresizingMaskIntoConstraints = false
        let viewDictionary = ["_nativeAdView": nativeAd]
        self.adView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[_nativeAdView]|",
                                                                options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
        self.adView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[_nativeAdView]|",
                                                                options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDictionary))
    }
    //MARK:- Switch Actions
    @IBAction func onSwitchValueChange(_ sender: Any) {
        switch (sender as AnyObject).tag {
        case 1:
            self.interstitialSwitch.isOn = self.bannerSwitch.isOn ? false: self.interstitialSwitch.isOn
            self.appinstallSwitch.isOn = self.bannerSwitch.isOn ? false: self.appinstallSwitch.isOn
            self.ContentSwitch.isOn = self.bannerSwitch.isOn ? false: self.ContentSwitch.isOn
            self.custumswitch.isOn = self.bannerSwitch.isOn ? false: self.custumswitch.isOn
            break
        case 2:
            self.bannerSwitch.isOn = self.interstitialSwitch.isOn ? false: self.bannerSwitch.isOn
            self.appinstallSwitch.isOn = self.interstitialSwitch.isOn ? false: self.appinstallSwitch.isOn
            self.ContentSwitch.isOn = self.interstitialSwitch.isOn ? false: self.ContentSwitch.isOn
            self.custumswitch.isOn = self.interstitialSwitch.isOn ? false: self.custumswitch.isOn
            break
        case 3:
            self.bannerSwitch.isOn = self.appinstallSwitch.isOn ? false: self.bannerSwitch.isOn
            self.interstitialSwitch.isOn = self.appinstallSwitch.isOn ? false: self.interstitialSwitch.isOn
            self.ContentSwitch.isOn = self.appinstallSwitch.isOn ? false: self.ContentSwitch.isOn
            self.custumswitch.isOn = self.appinstallSwitch.isOn ? false: self.custumswitch.isOn
            break
        case 4:
            self.bannerSwitch.isOn = self.ContentSwitch.isOn ? false: self.bannerSwitch.isOn
            self.interstitialSwitch.isOn = self.ContentSwitch.isOn ? false: self.interstitialSwitch.isOn
            self.appinstallSwitch.isOn = self.ContentSwitch.isOn ? false: self.appinstallSwitch.isOn
            self.custumswitch.isOn = self.ContentSwitch.isOn ? false: self.custumswitch.isOn
            break
        case 5:
            self.bannerSwitch.isOn = self.custumswitch.isOn ? false: self.bannerSwitch.isOn
            self.interstitialSwitch.isOn = self.custumswitch.isOn ? false: self.interstitialSwitch.isOn
            self.appinstallSwitch.isOn = self.custumswitch.isOn ? false: self.appinstallSwitch.isOn
            self.ContentSwitch.isOn = self.custumswitch.isOn ? false: self.ContentSwitch.isOn
            break
        default:
            self.bannerSwitch.isOn = true
            self.interstitialSwitch.isOn = false
            self.appinstallSwitch.isOn = false
            self.ContentSwitch.isOn = false
            self.custumswitch.isOn = false
            break
        }
    }
    //MARK:- show Error if not load Ad
    func showError(message:String) -> Void {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

