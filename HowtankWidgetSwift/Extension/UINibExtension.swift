//
//  UINibExtension.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 01/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

extension UINib {
    
    class func view<T>(nibName: String, owner: AnyObject) -> T? {
        let nib = howtankNib(name: nibName, owner: owner)
        return nib.instantiate(withOwner: owner, options: nil)[0] as? T
    }
    
    func view<T>(owner: AnyObject) -> T? {
        return instantiate(withOwner: owner, options: nil)[0] as? T
    }
    
    class func howtankNib(name: String, owner: AnyObject) -> UINib {
        return UINib(nibName: name, bundle: Bundle.howtankBundle(owner: owner))
    }
    
}

extension Bundle {
    
    class func howtankBundle(owner: AnyObject) -> Bundle? {
        let classBundle = Bundle(for: owner.classForCoder)
        if let url = classBundle.url(forResource: "HowtankWidgetSwift", withExtension: "bundle") {
            return Bundle(url: url)
        }
        return classBundle
    }
    
}
