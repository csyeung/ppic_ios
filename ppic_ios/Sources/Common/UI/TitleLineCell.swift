//
//  TitleLineCell.swift
//  flipmap_ios
//
//

import UIKit
import RxSwift

final class TitleLineCell: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    var disposeBag : DisposeBag = .init()

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLbl.text = nil
        disposeBag = DisposeBag()
    }

    func configure(with name: String, color: UIColor) {
        titleLbl.text = name
        titleLbl.textColor = color
    }
}
