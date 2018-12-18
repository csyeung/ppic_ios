//
// Created by Jonathan YEUNG on 2018/07/13.
// ppic_ios

// 

import UIKit

final class PicButton: AnimationButton {
    private(set) var countLabel: UILabel!
    private(set) var picIcon: UIImageView!
    
    // タイマーに関する
    private(set) var timer : Timer = .init()
    private(set) var isRunning : Bool = false
    private(set) var expiredAt : Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setCountLabel()
        setIcon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
        setCountLabel()
        setIcon()
    }
}

extension PicButton {
    private func setCountLabel() {
        self.countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.countLabel.font = UIFont.systemFont(ofSize: 16)
        self.countLabel.textColor = UIColor(red: 227/255, green: 96/255, blue: 119/255, alpha: 1)
        self.countLabel.textAlignment = .center
        self.countLabel.text = "0:00"
        self.countLabel.isHidden = true
        
        self.addSubview(self.countLabel)
    }
    
    private func setIcon() {
        let baseImage: UIImage! = UIImage(named: "icon_pic_red_text")
        
        self.picIcon = UIImageView(image: baseImage)
        self.picIcon.frame.origin = CGPoint(x: self.frame.width * 0.5 - baseImage.size.width * 0.5, y: self.frame.height * 0.5 - baseImage.size.height * 0.5)
        self.picIcon.isHidden = true
        
        self.addSubview(self.picIcon)
    }
    
    func showIcon() {
        self.picIcon.isHidden = false
        self.countLabel.isHidden = true
    }
    
    func showCount() {
        self.picIcon.isHidden = true
        self.countLabel.isHidden = false
    }
    
    func startCountdown(expiredAt: Date) {
        if isRunning { return }
        
        self.expiredAt = expiredAt
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        isRunning = true
    }
    
    @objc func updateTimer() {
        // 非起動時は呼ばれないらしいので、decrementではなく毎回差分計算する https://qiita.com/KikurageChan/items/5b33f95cbec9e0d8a05f#%E3%82%BF%E3%82%A4%E3%83%9E%E3%83%BC%E3%81%8C%E5%91%BC%E3%81%B0%E3%82%8C%E3%81%A6%E3%81%84%E3%82%8B%E3%82%BF%E3%82%A4%E3%83%9F%E3%83%B3%E3%82%B0
        guard let expiredAt = self.expiredAt else {return}
        let seconds = Int(expiredAt.timeIntervalSinceNow)

        // hh:mm
        self.countLabel.text = secondsToHoursMinutesSeconds(seconds: seconds)
        
        if seconds <= 0 {
            timer.invalidate()
            isRunning = false
//            self.showIcon()
            // main thread で実行される確証がどうしてもないので、メインスレッド保証をしたうえでアイコン変更する
            DispatchQueue.main.async { [weak self] in
                self?.showIcon()
            }

        }
    }
    
    private func secondsToHoursMinutesSeconds(seconds : Int) -> String {
        let hour = seconds / 3600
        let min = seconds % 3600 / 60
        let _ = (seconds % 3600) % 60 // seconds, not use now
        
        return String(format: "%d:%02d", hour, min)
    }
}
