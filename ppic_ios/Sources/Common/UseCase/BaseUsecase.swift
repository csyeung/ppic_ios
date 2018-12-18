//
//  BaseUsecase.swift
//  ppic_ios
//
//  Created by RN-070 on 2018/07/13.

//

import Foundation

class BaseUsecase {
    func trim(string: String) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
