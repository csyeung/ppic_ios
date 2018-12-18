//
//  Date.swift
//  flipmap_ios
//
//  Created by liqc on 2017/07/28.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import Foundation

extension Date {
    func yearFrom(_ date: Date) -> Int {
        if let result = Calendar.current.dateComponents([.year], from: date, to: self).year { return result }
        return 0
    }
    
    func monthFrom(_ date: Date) -> Int {
        if let result = Calendar.current.dateComponents([.month], from: date, to: self).month { return result }
        return 0
    }
    
    func weekFrom(_ date: Date) -> Int {
        if let result = Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear { return result }
        return 0
    }
    
    func dayFrom(_ date: Date) -> Int {
        if let result = Calendar.current.dateComponents([.day], from: date, to: self).day { return result }
        return 0
    }
    
    func hourFrom(_ date: Date) -> Int {
        if let result = Calendar.current.dateComponents([.hour], from: date, to: self).hour { return result }
        return 0
    }
    
    func minuteFrom(_ date : Date) -> Int {
        if let result = Calendar.current.dateComponents([.minute], from: date, to: self).minute { return result }
        return 0
    }
    
    func secondFrom(_ date : Date) -> Int {
        if let result = Calendar.current.dateComponents([.second], from: date, to: self).second { return result }
        return 0
    }
}
