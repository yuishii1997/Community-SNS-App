//
//  GoogleMobileAdsTableCell.swift
//  Nomad-App
//
//  Created by Yu Ishii on 2020/08/05.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// AdMob広告(ボーダーなし)

import UIKit
import GoogleMobileAds

final class GoogleMobileAdsTableCell: UITableViewCell {
    
    @IBOutlet private weak var nativeAdView: GADUnifiedNativeAdView!
    @IBOutlet private weak var bodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func apply(nativeAd: GADUnifiedNativeAd) {
        nativeAdView.nativeAd = nativeAd
        nativeAd.delegate = self
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        (nativeAdView.iconView as? UIImageView)?.contentMode = .scaleAspectFill
        (nativeAdView.iconView as? UIImageView)?.layer.cornerRadius = 18.0 //直径の半分
        //(nativeAdView.iconView as? UIImageView)?.layer.borderWidth = 1.5
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from:nativeAd.starRating)
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
        bodyLabel.text = nativeAd.body
        bodyLabel.isHidden = nativeAd.body == nil
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.layer.cornerRadius = 2.0
        nativeAdView.callToActionView?.layer.borderColor = UIColor(hex: "445EAB").cgColor
        nativeAdView.callToActionView?.layer.borderWidth = 1.0
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
    }
    
    private func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
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

// MARK: GADUnifiedNativeAdDelegate
extension GoogleMobileAdsTableCell : GADUnifiedNativeAdDelegate {
    
    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
        debugPrint("\(#function) called")
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
        debugPrint("\(#function) called")
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
        debugPrint("\(#function) called")
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
        debugPrint("\(#function) called")
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
        debugPrint("\(#function) called")
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
        debugPrint("\(#function) called")
    }
}
