//
//  UITableViewExtension.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 03/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

extension UITableView {
    func registerNibForIdentifier(nibName: String, identifier: String, bundle: Bundle? = nil) {
        let xib = UINib(nibName: nibName, bundle: bundle)
        self.register(xib, forCellReuseIdentifier: identifier)
    }
}

extension UICollectionView {
    func registerNibForIdentifier(nibName: String, identifier: String, bundle: Bundle? = nil) {
        let xib = UINib(nibName: nibName, bundle: bundle)
        self.register(xib, forCellWithReuseIdentifier: identifier)
    }
}
