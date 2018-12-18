//
// Created by Jonathan YEUNG on 2018/07/25.
// ppic_ios

// 

import NotAutoLayout
import UIKit
import Kingfisher

final class ProfileView : UIView {
    private let avatarView: UIImageView
    private let nameLabel: UILabel
    private let bioLabel: UITextView
    private let moreButton: UIButton
    private let closeButton: UIButton
    
    public var avatar: String? {
        get {
            return self.avatarView.kf.webURL?.absoluteString
        }
        
        set {
            guard let url = newValue else { return }
            self.avatarView.kf.setImage(with: URL(string: url), placeholder: nil, options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)
        }
    }
    
    public var userName: String? {
        get {
            return self.nameLabel.text
        }
        
        set {
            self.nameLabel.text = newValue
        }
    }
    
    public var bio: String? {
        get {
            return self.bioLabel.text
        }
        
        set {
            self.bioLabel.text = newValue
        }
    }
    
    public override init(frame: CGRect) {
        self.avatarView = UIImageView()
        self.nameLabel = UILabel()
        self.bioLabel = UITextView()
        self.moreButton = UIButton()
        self.closeButton = UIButton()
        
        super.init(frame: frame)
        
        self.setupAvatarView()
        self.setupNameLabel()
        self.setupBioLabel()
        self.setupButtons()
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.placeAvatarView()
        self.placeNameLabel()
        self.placeBioLabel()
        self.placeButtons()
    }
}

extension ProfileView {
    private func setupAvatarView() {
        let view = self.avatarView
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.9, height: 450)
        view.clipsToBounds = true
        self.addSubview(view)
    }
    
    private func setupBioLabel() {
        let label = self.bioLabel
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = UIColor.init(red: 44/255, green: 43/255, blue: 49/255, alpha: 1)
        label.backgroundColor = UIColor.clear
        label.isSelectable = false
        label.isEditable = false
        self.addSubview(label)
    }
    
    private func setupNameLabel() {
        let label = self.nameLabel
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = UIColor.init(red: 44/255, green: 43/255, blue: 49/255, alpha: 1)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        self.addSubview(label)
    }
    
    private func setupButtons() {
        let closeButton = self.closeButton
        closeButton.setImage(UIImage(named: "btn_close"), for: .normal)
        closeButton.addTarget(self, action: #selector(onCloseButton(sender:)), for: .touchUpInside)
        self.addSubview(closeButton)
        
        let moreButton = self.moreButton
        moreButton.setImage(UIImage(named: "btn_more"), for: .normal)
        moreButton.addTarget(self, action: #selector(onMoreButton(sender:)), for: .touchUpInside)
        self.addSubview(moreButton)
    }
}

extension ProfileView {
    private func placeAvatarView() {
        self.nal.layout(self.avatarView) { $0
            .setCenter(by: { $0.center })
            .setTop(to: 30)
            .setSize(to: .init(width: 110, height: 110))
            .addingProcess(by: { (frame, parameters) in
                let radius = min(frame.width, frame.height) * 0.5
                parameters.targetView.layer.cornerRadius = radius.cgValue
            })
        }
    }
    
    private func placeBioLabel() {
        self.nal.layout(self.bioLabel) { $0
            .setLeft(by: { $0.left + 13 })
            .setRight(by: { $0.right - 12 })
            .pinTop(to: self.nameLabel, with: { $0.bottom + 16 })
            .setBottom(by: { $0.bottom + 84 })
        }
    }
    
    private func placeNameLabel() {
        self.nal.layout(self.nameLabel) { $0
            .setCenter(by: { $0.center })
            .pinTop(to: self.avatarView, with: { $0.bottom + 16 })
            .setWidth(to: 270)
            .setHeight(to: 38)
        }
    }
    
    private func placeButtons() {
        self.nal.layout(self.closeButton) { $0
            .setRight(by: { $0.right + 3 })
            .setTop(by: { $0.top + 2 })
            .setSize(to: .init(width: 44, height: 44))
        }
        
        self.nal.layout(self.moreButton) { $0
            .setCenter(by: { $0.center })
            .setBottom(by: { $0.bottom - 6 })
            .setSize(to: .init(width: 44, height: 44))
        }
    }
}

extension ProfileView {
    @objc func onCloseButton(sender: UIButton) {
        guard let parent = self.parentViewController as? ProfileViewController else { return }
        parent.onClose(sender: sender)
    }
    
    @objc func onMoreButton(sender: UIButton) {
        guard let parent = self.parentViewController as? ProfileViewController else { return }
        parent.showMenu(sender: sender)
    }
}
