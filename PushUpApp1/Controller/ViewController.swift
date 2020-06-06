//
//  ViewController.swift
//  PushUpApp1
//
//  Created by Kazuya Fukui on 2020/04/27.
//  Copyright © 2020 Kazuya Fukui. All rights reserved.
//

import UIKit
import MediaPlayer
import GoogleMobileAds

class ViewController: UIViewController,MPMediaPickerControllerDelegate {
    
    //腕立てのカウント変数
    var count = 0
    
    //音楽の再生時間の変数
    var timeCount = 0
    
    var timer = Timer()
    
    var pushUpTimer = Timer()
    
    var player:MPMusicPlayerController!
    
    var pushUpTimeCount = 0
    
    @IBOutlet weak var artWorkImageView: UIImageView!
    
    @IBOutlet weak var songTitleLabel: UILabel!
    
    @IBOutlet weak var artistNameLabel: UILabel!
    
    @IBOutlet weak var musicTimeLabel: UILabel!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var finishButton: UIButton!
    
    @IBOutlet weak var selectButton: UIButton!
    
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //"c30d3720a2f03ccf9425b6faefc70f56"
        
        bannerView.adUnitID = "ca-app-pub-3236472241976929/3549401302"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        musicTimeLabel.text = "00:00"
        
        artWorkImageView.image = UIImage(named: "noimage")
        
        playButton.isEnabled = false
        stopButton.isEnabled = false
        finishButton.layer.cornerRadius = 20.0
        selectButton.layer.cornerRadius = 10.0
        finishButton.isEnabled = false
        
        //近接センサーを有効にする
        UIDevice.current.isProximityMonitoringEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(sensorState), name: UIDevice.proximityStateDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        
        count = 0
        countLabel.text = "0"
        musicTimeLabel.text = "00:00"
        finishButton.isEnabled = false
        
        if UserDefaults.standard.object(forKey: "timeCount") != nil {
            
            timeCount = UserDefaults.standard.object(forKey: "timeCount") as! Int
            
        }
    }
    
    
    
    @objc func sensorState(){
        
        //近接センサーが反応し、近い時
        if UIDevice.current.proximityState == true {
            count += 1
            countLabel.text = String(count)
        }
        
    }
    
    
    
    
    
    
    
    //ピッカー画面で曲が選択された時
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        //プレイヤーを止める
        player.stop()
        //選択した曲をplayerにセット
        player.setQueue(with: mediaItemCollection)
        
        //選択した曲の情報をラベルやイメージビューにセット
        if let mediaitem = mediaItemCollection.items.first {
            updatesong(mediaItem: mediaitem)
        }
        
        //ピッカーを閉じて、破棄する
        dismiss(animated: true, completion: nil)
        playButton.isEnabled = true
    }
    
    
    //曲が選択されなかった時
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func musicSelectTap(_ sender: Any) {
        
        //プレイヤーの準備
        player = MPMusicPlayerController.applicationMusicPlayer
        
        //MPMediaPickerのインスタンス
        let picker = MPMediaPickerController()
        //ピッカーのデリゲートを設定
        picker.delegate = self
        //複数選択を不可にする
        picker.allowsPickingMultipleItems = true
        //ピッカー画面を表示
        present(picker, animated: true, completion: nil)
        
    }
    
    @IBAction func playTap(_ sender: Any) {
        
        player.play()
        
        finishButton.isEnabled = true
        playButton.isEnabled = false
        stopButton.isEnabled = true
        
        //1秒毎
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        
        pushUpTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countUp), userInfo: nil, repeats: true)
    }
    
    @objc func countDown() {
        
        //1秒毎にカウントを1減らしていく
        timeCount -= 1
        if(timeCount > 0) {
            
            //秒数を分、秒に表示を変換
            let minutes = String(timeCount / 60)
            let seconds = String(timeCount % 60)
            musicTimeLabel.text = "\(minutes):\(seconds)"
        } else {
            musicTimeLabel.text = "Finish!!"
            timer.invalidate()
            player.stop()
            player.skipToBeginning()
            pushUpTimer.invalidate()
            playButton.isEnabled = true
            stopButton.isEnabled = false
            let nextVC = storyboard?.instantiateViewController(identifier: "next") as! NextViewController
            nextVC.name = artistNameLabel.text!
            nextVC.musicTitle = songTitleLabel.text!
            nextVC.pushCount = count
            nextVC.musicImage = artWorkImageView.image!
            nextVC.timeString = musicTimeLabel.text!
            navigationController?.pushViewController(nextVC, animated: true)
            
        }
    }
    
    @objc func countUp() {
        
        pushUpTimeCount += 1
        
        
    }
    
    @IBAction func stopTap(_ sender: Any) {
        
        player.pause()
        //タイマーを止める
        timer.invalidate()
        pushUpTimer.invalidate()
        playButton.isEnabled = true
        stopButton.isEnabled = false
        
    }
    
    //曲の情報を表示する
    func updatesong(mediaItem: MPMediaItem) {
        
        //曲情報を表示
        songTitleLabel.text = mediaItem.title ?? "No Title"
        artistNameLabel.text = mediaItem.artist ?? "No Artist"
        
        //再生時間がDouble型のため、Int型にキャストする
        timeCount = Int(mediaItem.playbackDuration)
        
        UserDefaults.standard.set(timeCount, forKey: "timeCount")
        //アートワークを表示
        if let artwork = mediaItem.artwork {
            //アートワークの枠サイズを設定
            let image = artwork.image(at: artWorkImageView.bounds.size)
            //imageviewにがアートワークを設定する
            artWorkImageView.image = image
        } else {
            //もしアートワークがなければ、何も表示しない
            artWorkImageView.image = UIImage(named: "noimage")
        }
        
    }
    
    
    @IBAction func finishTup(_ sender: Any) {
        
        player.stop()
        player.skipToBeginning()
        timer.invalidate()
        pushUpTimer.invalidate()
        playButton.isEnabled = true
        stopButton.isEnabled = false
        
        let minutes = String(pushUpTimeCount / 60)
        let seconds = String(pushUpTimeCount % 60)
        
        let remainingCount = (timeCount - pushUpTimeCount)
        
        let remainingMinutes = String(remainingCount / 60)
        let remainingSeconds = String(remainingCount % 60)
        
        
        
        let nextVC = storyboard?.instantiateViewController(identifier: "next") as! NextViewController
        nextVC.name = artistNameLabel.text!
        nextVC.musicTitle = songTitleLabel.text!
        nextVC.pushCount = count
        nextVC.musicImage = artWorkImageView.image!
        nextVC.timeString = "\(minutes):\(seconds)"
        if remainingCount == 0 {
            nextVC.remainingTime = "Total playback time"
        } else {
            nextVC.remainingTime = "\(remainingMinutes):\(remainingSeconds) remaining"
            
        }
        
        navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    
    
}

