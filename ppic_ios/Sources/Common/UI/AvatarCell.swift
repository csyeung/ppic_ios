//
//  AvatarCell.swift
//  flipmap_ios
//
//

import UIKit
import Kingfisher

final class AvatarCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView!
    private(set) var iconHeight: CGFloat = 0
    private(set) var iconMargin: CGFloat = 0

    override func prepareForReuse() {
        super.prepareForReuse()
        self.iconView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame = CGRect(x: iconMargin, y: iconMargin, width: iconHeight, height: iconHeight)
        self.iconView.clipsToBounds = true
    }

    func configure(with path: String, bkColor: UIColor = UIColor.white, height: CGFloat, margin: CGFloat) {
        self.iconHeight = height
        self.iconMargin = margin
        self.iconView.layer.cornerRadius = height * 0.5
        iconView.kf.setImage(with: URL(string: path), placeholder: nil, options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)
    }

    func setImage(_ image: UIImage?) {
        self.iconView.image = image
    }
}
