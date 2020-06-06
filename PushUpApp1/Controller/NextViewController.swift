//
//  NextViewController.swift
//  PushUpApp1
//
//  Created by Kazuya Fukui on 2020/04/28.
//  Copyright © 2020 Kazuya Fukui. All rights reserved.
//

import UIKit
import Photos
import GoogleMobileAds

class NextViewController: UIViewController {

    var pushCount = 0
    
    var musicImage = UIImage()
    var musicTitle = String()
    var name = String()
    var timeString = String()
    var remainingTime = String()
    
    var shareImage = UIImage()
    
    
    @IBOutlet weak var artWorkImageView: UIImageView!
    
    
    @IBOutlet weak var artistNameLabel: UILabel!
    
    @IBOutlet weak var musicTitleLabel: UILabel!
    
    @IBOutlet weak var pushCountLabel: UILabel!
    
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var shareButton: UIButton!
    
    
    @IBOutlet weak var nextBannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextBannerView.adUnitID = "ca-app-pub-3236472241976929/9173263073"
        nextBannerView.rootViewController = self
        nextBannerView.load(GADRequest())
       
        shareButton.layer.cornerRadius = 20.0
        
        pushCountLabel.text = "\(pushCount)"
        
        artWorkImageView.image = musicImage
        
        musicTitleLabel.text = musicTitle
        
        artistNameLabel.text = name
        
        timeLabel.text = timeString
        
        remainingTimeLabel.text = "\(remainingTime)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    
    @IBAction func shareTap(_ sender: Any) {
    
        //スクリーンショットを撮る
            takeScreenShot()
            //アクティビティビューに乗っけて、シェアする
            let items = [shareImage] as [Any]
        
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            present(activityVC, animated: true, completion: nil)
    
    
    }
    


    
    func takeScreenShot() {
        
        //スクリーンショットのサイズ
        let width = CGFloat(view.frame.size.width)
        let height = CGFloat(view.frame.size.height/1.2)
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size,false, 0.0)
        
        //viewに書き出す
        self.view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        shareImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
    }

}
