//
//  UITableView.swift
//  flipmap_ios
//
//  Created by liqc on 2018/04/18.
//  Copyright © 2018年 RN-079. All rights reserved.
//

import UIKit

extension UITableView {
    func reloadDataKeepOffset() {
        let offset = contentOffset
        UIView.setAnimationsEnabled(false)
        beginUpdates()
        endUpdates()
        UIView.setAnimationsEnabled(true)
        contentOffset = offset
    }
    
    func reloadData(to offset: CGPoint) {
        UIView.setAnimationsEnabled(false)
        beginUpdates()
        endUpdates()
        UIView.setAnimationsEnabled(true)
        contentOffset = offset
    }
}
