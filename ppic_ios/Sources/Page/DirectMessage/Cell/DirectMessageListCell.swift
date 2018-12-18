//
// Created by Jonathan YEUNG on 2018/07/11.
// ppic_ios

// 

import UIKit
import Kingfisher
import SwiftDate

final class DirectMessageListCell : UITableViewCell {
    @IBOutlet weak var avatarIcon : UIImageView!
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var timeLabel : UILabel!
    @IBOutlet weak var countLabel : UILabel!
    @IBOutlet weak var contentLabel : UILabel!
    @IBOutlet weak var indicateIcon : UIImageView!
    
    private let picUsecase = PicUsecase()

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 丸型の設定
        self.avatarIcon.layer.masksToBounds = true
        self.avatarIcon.layer.cornerRadius = self.avatarIcon.frame.height * 0.5
    }
}

extension DirectMessageListCell {
    // データ導入
    func configure(data: ChatListDataEntity) {
        if let unread = data.unread {
            indicateIcon.isHidden = !unread
            
            if unread {
                self.nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                self.countLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            } else {
                self.nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                self.countLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            }
        }
        
        if let content = data.latest.content {
            contentLabel.text = content
            
            if let isBlocked = data.latest.isBlocked {
                if isBlocked {
                    contentLabel.text = "ブロック済みユーザーの発言です"
                }
            }
        }
        
        if let createdAt = data.latest.createdAt {
            timeLabel.text = createdAt.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.japanese)
        }

        if let picId = data.picId {
            picUsecase.get(id: picId) { (pic) in

                self.nameLabel.text = pic.title

                if pic.photoURL != "" {
                    self.avatarIcon.kf.setImage(with: URL(string: pic.photoURL))
                } else if let owner = pic.owner {
                    self.avatarIcon.kf.setImage(with: URL(string: owner.photoURL))
                }

                self.countLabel.text = AppUtility.makeDMCountString(count: pic.participantsNumber)
            }
        }
    }
}
