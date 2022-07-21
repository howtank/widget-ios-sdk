//
//  PurchaseParameters.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 30/01/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

public enum ValueCurrency {
    case euro
    case dollar
    case pound
    case custom(String)
    
    var value: String {
        switch self {
        case .euro:
            return "EUR"
        case .dollar:
            return "USD"
        case .pound:
            return "GBP"
        case .custom(let value):
            return value
        }
    }
}

@objc public enum HowtankCurrency: Int {
    case euro
    case dollar
    case pound
    
    var value: String {
        switch self {
        case .euro:
            return "EUR"
        case .dollar:
            return "USD"
        case .pound:
            return "GBP"
        }
    }
}

public class PurchaseParameters: NSObject {
    
    public init(newBuyer: Bool,
                purchaseId: String,
                valueAmount: Double,
                valueCurrency: ValueCurrency) {
        self.newBuyer = newBuyer
        self.purchaseId = purchaseId
        self.valueAmount = valueAmount
        self.valueCurrency = valueCurrency
    }
    
    @objc public init(newBuyer: Bool,
                      purchaseId: String,
                      valueAmount: Double,
                      valueCurrency: HowtankCurrency) {
        self.newBuyer = newBuyer
        self.purchaseId = purchaseId
        self.valueAmount = valueAmount
        switch valueCurrency {
        case .euro: self.valueCurrency = .euro
        case .dollar: self.valueCurrency = .dollar
        case .pound: self.valueCurrency = .pound
        }
    }
    
    @objc public init(newBuyer: Bool,
                      purchaseId: String,
                      valueAmount: Double,
                      customValueCurrency: String) {
        self.newBuyer = newBuyer
        self.purchaseId = purchaseId
        self.valueAmount = valueAmount
        self.valueCurrency = .custom(customValueCurrency)
    }
    
    let newBuyer: Bool
    let purchaseId: String
    let valueAmount: Double
    let valueCurrency: ValueCurrency
    
}

