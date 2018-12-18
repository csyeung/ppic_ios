//
//  SettingController.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/10.

//

import DIKit
import UIKit
import RxSwift
import RxCocoa
import CropViewController
import SVProgressHUD

final class SettingController: UIViewController, PropertyInjectable {
    struct Dependency {
        let menuHeader: CGFloat
        let viewModel: SettingViewModelProtocol
    }
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var navigationBar : UINavigationBar!
    
    // UI用定数
    enum TargetPage : TransitionInformation {
        case webView(title: String, url: String)
        case selectPhoto
        case cropPhoto(image: UIImage)
    }
    
    enum Section : Int {
        case avatar = 0
        case accountName
        case bio
        case menu
        case total
    }
    
    var dependency: Dependency!
    
    private(set) var menuHeaderSpace : CGFloat?
    private let avatarHeight : CGFloat = 90
    private let avatarMargin : CGFloat = 16
    private let inputBoxMargin : CGFloat = 16
    private let titleColor : UIColor = .init(red: 0, green: 122/255, blue: 1, alpha: 1)
    private let nameInputLimit : Int = 15
    private let bioInputLimit : Int = 250
    
    // TODO: リファクタリング
    private let titles : [String] = [ "利用規約", "プライバシーポリシー" ]
    private let urls : [String] = [ "https://flipmap.co/terms2", "http://www.fullspeed.co.jp/privacy/" ]
    
    private(set) var viewModel: SettingViewModelProtocol!
    private let disposeBag : DisposeBag = .init()

    // データ
    var photoUrl: Variable<String> = .init("")
    var displayName: Variable<String> = .init("")
    var bio: Variable<String> = .init("")
    
    // cropするとtrueになる。trueの場合に限り更新処理に画像データを渡す
    private(set) var photoImage : Variable<UIImage?> = Variable(nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        injectDependencies()
        setupNavigationBar()
        setupTableView()
        bindData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
}

// MARK: Main function
extension SettingController {
    private func injectDependencies() {
        self.menuHeaderSpace = dependency.menuHeader
        self.viewModel = dependency.viewModel
    }
    
    private func setupNavigationBar() {
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]

        let closeButton = UIBarButtonItem(image: UIImage(named: "btn_close"), style: .plain, target: self, action: #selector(doSave))
        self.navigationBar.topItem?.rightBarButtonItem = closeButton
        self.navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor.black
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // 登録
        self.tableView.register(UINib(nibName: "AvatarCell", bundle: nil), forCellReuseIdentifier: "AvatarCell")
        self.tableView.register(UINib(nibName: "EditCell", bundle: nil), forCellReuseIdentifier: "EditCell")
        self.tableView.register(UINib(nibName: "TextCell", bundle: nil), forCellReuseIdentifier: "TextCell")
        self.tableView.register(UINib(nibName: "TitleLineCell", bundle: nil), forCellReuseIdentifier: "TitleLineCell")
        
        // 余った部分の線を消す
        self.tableView.tableFooterView = UIView()
    }
    
    private func bindData() {
        viewModel.settingData
            .asDriver(onErrorDriveWith: Driver.empty())
            .drive(rx.settingDataBinder())
            .disposed(by: disposeBag)
    }
}

private extension Reactive where Base: SettingController {
    func settingDataBinder() -> Binder<(String, String, String)> {
        return .init(base, binding: { (base, value) in
            base.photoUrl.value = value.0
            base.displayName.value = value.1
            base.bio.value = value.2
            
            base.tableView.reloadData()
        })
    }
}

// Mark: - IBAction
extension SettingController {
    @IBAction func doSave() {
        // TODO: バリデーションの正式な実装
        let displayName = self.displayName.value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if displayName == "" || displayName.count > nameInputLimit {
            return
        }

        self.viewModel.save(displayName: displayName, bio: self.bio.value, photoImage: self.photoImage.value) { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: UIImagePickerControllerDelegate
extension SettingController : UIImagePickerControllerDelegate {
    func imagePickerController(_ imagePickerController: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // TODO: 330という値は、ユーザ画像の最大解像度。どこかに名前をつけて定義すべき
            self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.cropPhoto(image: image.resize(scaledToWidth: 330)))
        }
    }
}

extension SettingController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.photoImage.value = image
        self.transitionDelegate?.viewController(cropViewController, needsTransitionWith: nil)
    }
}

// MARK: UITableViewDelegate
extension SettingController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case Section.avatar.rawValue:
            self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.selectPhoto)
            
        case Section.menu.rawValue:
            let row = indexPath.row
            let title = self.titles[row]
            let url = self.urls[row]
            self.transitionDelegate?.viewController(self, needsTransitionWith: TargetPage.webView(title: title, url: url))
            
        default:
            // 反応なし
            break
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == Section.menu.rawValue || indexPath.section == Section.avatar.rawValue {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getRowHeight(indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return getHeaderHeight(section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK: UITableViewDataSource
extension SettingController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.total.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getRowInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case Section.avatar.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AvatarCell", for: indexPath) as! AvatarCell
            cell.configure(with: photoUrl.value, height: avatarHeight, margin: avatarMargin)
            self.photoImage.asObservable().bind { image in
                guard let updateImage = image else { return }
                cell.setImage(updateImage)
            }.disposed(by: disposeBag)
            return cell

        case Section.accountName.rawValue:
            let inputWidth = UIScreen.main.bounds.width - 2 * inputBoxMargin
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as! EditCell
            cell.configure(key: "アカウント名", value: displayName, indexPath: indexPath, inputWidth: inputWidth, inputLimit: nameInputLimit)
            return cell

        case Section.bio.rawValue:
            let inputWidth = UIScreen.main.bounds.width - 2 * inputBoxMargin
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as! EditCell
            cell.configure(key: "自己紹介", value: bio, indexPath: indexPath, inputWidth: inputWidth, inputLimit: bioInputLimit)
            return cell
            
        case Section.menu.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleLineCell", for: indexPath) as! TitleLineCell
            cell.configure(with: self.titles[row], color: titleColor)
            return cell
            
        default:
            assertionFailure()
            return UITableViewCell()
        }
    }
}

// MARK: テーブル設定
extension SettingController {
    private func getRowHeight(_ section: Int) -> CGFloat {
        switch section {
        case Section.avatar.rawValue: return avatarHeight + avatarMargin
        case Section.accountName.rawValue: return 60
        case Section.bio.rawValue: return 60
        default: return 44
        }
    }
    
    private func getHeaderHeight(_ section: Int) -> CGFloat {
        if section == Section.menu.rawValue {
            return 32
        }
        
        if section == Section.accountName.rawValue {
            return 24
        }
        
        return 0
    }
    
    private func getRowInSection(_ section: Int) -> Int {
        if section == Section.menu.rawValue {
            return titles.count
        }
        
        return 1
    }
}

// MARK: UINavigationControllerDelegate
extension SettingController : UINavigationControllerDelegate {
    
}
