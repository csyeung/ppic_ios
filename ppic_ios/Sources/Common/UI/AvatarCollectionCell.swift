//
//  AvatarCollectionCell.swift
//  flipmap_ios
//
//

import UIKit
import Kingfisher
import RxSwift

final class AvatarCollectionCell: UICollectionViewCell {
    @IBOutlet weak var iconView: UIImageView!

    private let disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        self.iconView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.clipsToBounds = true
    }

    func configure(uid: String, with path: String, cornerRadius: CGFloat) {
        self.iconView.layer.cornerRadius = cornerRadius
        iconView.kf.setImage(with: URL(string: path), placeholder: nil, options: [.transition(.fade(1))], progressBlock: nil, completionHandler: nil)

        let tapGesture = UITapGestureRecognizer()

        tapGesture.rx.event.bind { [weak self] sender in
            if let parentViewController = self?.parentViewController as? PicDetailController {
                parentViewController.transitionDelegate?.viewController(parentViewController, needsTransitionWith: PicDetailController.TargetPage.profile(uid: uid))
            }
        }.disposed(by: disposeBag)

        iconView.isUserInteractionEnabled = true
        iconView.addGestureRecognizer(tapGesture)
    }
}
