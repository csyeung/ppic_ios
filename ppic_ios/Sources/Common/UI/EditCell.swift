//
//  KeyvalueCell.swift
//  flipmap_ios
//
//

import UIKit
import RxSwift

final class EditCell: UITableViewCell {
    @IBOutlet weak var keyLbl: UILabel!
    @IBOutlet weak var valueTf: UITextField!
    @IBOutlet weak var textWidth: NSLayoutConstraint!

    var disposeBag : DisposeBag = .init()
    var indexPath: IndexPath?
    var inputLimit: Int = 20

    override func prepareForReuse() {
        super.prepareForReuse()

        keyLbl.text = nil
        valueTf.text = nil
        disposeBag = DisposeBag()
    }

    func configure(key : String, value: Variable<String>, placeholder: String = "未設定", indexPath: IndexPath, inputWidth: CGFloat, inputLimit: Int = 20) {
        self.textWidth.constant = inputWidth

        self.indexPath = indexPath
        keyLbl.text = key
        valueTf.text = value.value
        valueTf.placeholder = placeholder
        valueTf.delegate = self
        valueTf.tag = tag
        self.inputLimit = inputLimit

        valueTf.rx.text.asObservable().bind { [weak self] text in
            if let currentPath = self?.indexPath, currentPath == indexPath, let text = text {
                value.value = text
            }
        }.disposed(by: disposeBag)
    }
}

extension EditCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }

        if string == "\n" {
            textField.resignFirstResponder()
        }

        // Backspace はどうしても有効に
        if let char = string.cString(using: .utf8) {
            let backSpace = strcmp(char, "\\b")
            if backSpace == -92 {
                return true
            }
        }

        return text.count + string.count <= self.inputLimit
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let parent = parentViewController as? SettingController, let indexPath = indexPath {
            parent.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }

        return true
    }
}
