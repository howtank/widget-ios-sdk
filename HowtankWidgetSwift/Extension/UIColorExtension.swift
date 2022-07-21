//
//  UIColorExtension.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 03/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init?(hex:String?) {
        guard let hex = hex else {
            return nil
        }
        
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return nil
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        self.init(red:CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0, blue:CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: 1)
    }
    
    func brightnessValue() -> CGFloat {
        if let colors = self.cgColor.components {
            return (colors[0] * 299 + colors[1] * 587 + colors[2] * 114) / 1000
        }
        return 0
    }
    
}
