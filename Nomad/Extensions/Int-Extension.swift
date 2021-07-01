//
//  Int-Extension.swift
//  Nomad-App
//
//  Created by yuishii on 2020/12/19.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//

import UIKit

extension Int {
    func shorted() -> String {
        
        if self >= 10000 && self < 100000 {
            return String(format: "%.1f万", Double(self/1000)/10).replacingOccurrences(of: ".0", with: "")
        }
        
        if self >= 100000 && self < 100000000 {
            return "\(self/10000)万"
        }
        
        if self >= 100000000 && self < 1000000000 {
            return String(format: "%.1f億", Double(self/10000000)/10).replacingOccurrences(of: ".0", with: "")
        }
        
        if self >= 1000000000 {
            return "\(self/100000000)億"
        }
        
        return String(self)
    }
}


//英語の数字表記 shorted2
//import UIKit
//
//extension Int {
//func shorted2() -> String {
//    if self >= 1000 && self < 10000 {
//        return String(format: "%.1fK", Double(self/100)/10).replacingOccurrences(of: ".0", with: "")
//    }
//
//    if self >= 10000 && self < 1000000 {
//        return "\(self/1000)K"
//    }
//
//    if self >= 1000000 && self < 10000000 {
//        return String(format: "%.1fM", Double(self/100000)/10).replacingOccurrences(of: ".0", with: "")
//    }
//
//    if self >= 10000000 {
//        return "\(self/1000000)M"
//    }
//
//    return String(self)
//}
//}
