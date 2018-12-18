//
//  WtOperationView.swift
//  flipmap_ios
//
//

import UIKit
import RxSwift
import WebKit

final class WtOperationView: UIView {
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var ruleBtn: UIButton!
    @IBOutlet weak var privacyBtn: UIButton!

    private let disposeBag : DisposeBag = .init()
    private(set) var isChecked = Variable(false)
    private(set) var callingView : UIViewController?
    private(set) var onStartCallback : (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()

        // start button.
        startBtn.setBackgroundImage(AppUtility.makeImageWithColorAndHeight(color: UIColor.lightGray, height: 1), for: .disabled)

        // bind
        isChecked.asObservable().bind { [weak self] value in
            self?.checkBtn.setImage(UIImage(named: value ? "btn_check_green": "btn_uncheck_green"), for: .normal)
            self?.startBtn.isEnabled = value
        }.disposed(by: disposeBag)
    }

    func configure(view: UIViewController, onNext: @escaping () -> Void) {
        self.callingView = view
        self.onStartCallback = onNext
    }
}

// MARK: ボタンアクション
extension WtOperationView {
    @IBAction func doStart() {
        guard let callback = self.onStartCallback else { return }
        callback()
    }

    // TODO: リファクタリング（ナビゲーション）
    @IBAction func showRule() {
        guard let next = UIStoryboard(name: "Web", bundle: nil).instantiateInitialViewController() as? UINavigationController else {return}
        guard let web = next.topViewController as? WebController else {return}
        web.title = "利用規約"
        web.url = "https://flipmap.co/terms2"

        self.callingView?.present(next, animated: true, completion: nil)
    }

    @IBAction func showPrivacyBtn() {
        guard let next = UIStoryboard(name: "Web", bundle: nil).instantiateInitialViewController() as? UINavigationController else {return}
        guard let web = next.topViewController as? WebController else {return}
        web.title = "プライバシーポリシー"
        web.url = "http://www.fullspeed.co.jp/privacy/"
        self.callingView?.present(next, animated: true, completion: nil)
    }

    @IBAction func doCheck() {
        self.isChecked.value = !self.isChecked.value
    }
}
