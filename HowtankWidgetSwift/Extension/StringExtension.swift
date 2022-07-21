//
//  StringExtension.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 03/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

extension String {
    
    func toCGFloat() -> CGFloat? {
        if let number = NumberFormatter().number(from: self) {
            return CGFloat(number.floatValue)
        }
        return nil
    }
    
    public func urlEncoded() -> String
    {
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "+")
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!
    }
    
}
