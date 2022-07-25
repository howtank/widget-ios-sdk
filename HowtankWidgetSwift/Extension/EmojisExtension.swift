//
//  EmojisExtensions.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 05/05/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

import UIKit

extension UnicodeScalar {
    
    var isEmoji: Bool {
        
        switch value {
        case 0x1F600...0x1F64F, // Emoticons
        0x1F300...0x1F5FF, // Misc Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map
        0x2600...0x26FF,   // Misc symbols
        0x2700...0x27BF,   // Dingbats
        0xFE00...0xFE0F,   // Variation Selectors
        0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
        65024...65039, // Variation selector
        8400...8447: // Combining Diacritical Marks for Symbols
            return true
            
        default: return false
        }
    }
    
    var isZeroWidthJoiner: Bool {
        
        return value == 8205
    }
}

extension String {
    
    var glyphCount: Int {
        
        let richText = NSAttributedString(string: self)
        let line = CTLineCreateWithAttributedString(richText)
        return CTLineGetGlyphCount(line)
    }
    
    var isSingleEmoji: Bool {
        
        return glyphCount == 1 && containsEmoji
    }
    
    var containsEmoji: Bool {
        return unicodeScalars.contains { $0.isEmoji }
    }
    
    var containsOnlyEmojiOrSpaces: Bool {
        return !isEmpty
            && !unicodeScalars.contains(where: {
                !$0.isEmoji
                    && !$0.isZeroWidthJoiner
                    && !($0 == " ".unicodeScalars.first)
            })
    }
    
    // The next tricks are mostly to demonstrate how tricky it can be to determine emoji's
    // If anyone has suggestions how to improve this, please let me know
    var emojiString: String {
        return emojiScalars.map { String($0) }.reduce("", +)
    }
    
    var emojis: [String] {
        
        var scalars: [[UnicodeScalar]] = []
        var currentScalarSet: [UnicodeScalar] = []
        var previousScalar: UnicodeScalar?
        
        for scalar in emojiScalars {
            
            if let prev = previousScalar, !prev.isZeroWidthJoiner && !scalar.isZeroWidthJoiner {
                
                scalars.append(currentScalarSet)
                currentScalarSet = []
            }
            currentScalarSet.append(scalar)
            
            previousScalar = scalar
        }
        
        scalars.append(currentScalarSet)
        
        return scalars.map { $0.map{ String($0) } .reduce("", +) }
    }
    
    fileprivate var emojiScalars: [UnicodeScalar] {
        
        var chars: [UnicodeScalar] = []
        var previous: UnicodeScalar?
        for cur in unicodeScalars {
            
            if let previous = previous, previous.isZeroWidthJoiner && cur.isEmoji {
                chars.append(previous)
                chars.append(cur)
                
            } else if cur.isEmoji {
                chars.append(cur)
            }
            
            previous = cur
        }
        
        return chars
    }
    
    private static let textToEmojisDictionary =
        [try! NSRegularExpression(pattern: "(^| )(?::\\)|:-\\)|:d|:D|:-d|:-D|=D|=d)(\\.|\\?|!| |$)", options: []): "😀",
         try! NSRegularExpression(pattern: "(^| )(?:':\\)|':-\\)|'=\\)|':D|':-D|'=D)(\\.|\\?|!| |$)", options: []): "😅",
         try! NSRegularExpression(pattern: "(^| )(?:>:\\)|>;\\)|>:-\\)|>=\\))(\\.|\\?|!| |$)", options: []): "😆",
         try! NSRegularExpression(pattern: "(^| )(?:;\\)|;-\\)|\\*-\\)|\\*\\)|;-\\]|;\\]|;D|;^\\))(\\.|\\?|!| |$)", options: []): "😉",
         try! NSRegularExpression(pattern: "(^| )(?::\\||:-\\|)(\\.|\\?|!| |$)", options: []): "😐",
         try! NSRegularExpression(pattern: "(^| )(?:':\\(|':-\\(|'=\\()(\\.|\\?|!| |$)", options: []): "😓",
         try! NSRegularExpression(pattern: "(^| )(?::\\*|:-\\*|=\\*|:\\^\\*)(\\.|\\?|!| |$)", options: []): "😘",
         try! NSRegularExpression(pattern: "(^| )(?:>:P|X-P|x-p)(\\.|\\?|!| |$)", options: []): "😜",
         try! NSRegularExpression(pattern: "(^| )(?:>:\\[|:-\\(|:\\(|:-\\[|:\\[|=\\()(\\.|\\?|!| |$)", options: []): "😞",
         try! NSRegularExpression(pattern: "(^| )(?:>:\\(|>:-\\(|:@)(\\.|\\?|!| |$)", options: []): "😠",
         try! NSRegularExpression(pattern: "(^| )(?::'\\(|:'-\\(|;\\(|;-\\()(\\.|\\?|!| |$)", options: []): "😢",
         try! NSRegularExpression(pattern: "(^| )(?:>\\.<)(\\.|\\?|!| |$)", options: []): "😣",
         try! NSRegularExpression(pattern: "(^| )(?:D:)(\\.|\\?|!| |$)", options: []): "😧",
         try! NSRegularExpression(pattern: "(^| )(?::\\$|=\\$)(\\.|\\?|!| |$)", options: []): "😳",
         try! NSRegularExpression(pattern: "(^| )(?:#-\\)|#\\)|%-\\)|%\\)|X\\)|X-\\))(\\.|\\?|!| |$)", options: []): "😵",
         try! NSRegularExpression(pattern: "(^| )(?:O:-\\)|0:-3|0:3|0:-\\)|0:\\)|0;\\^\\)|O:\\)|O;-\\)|O=\\)|0;-\\)|O:-3|O:3)(\\.|\\?|!| |$)", options: []): "😇",
         try! NSRegularExpression(pattern: "(^| )(?:B-\\)|B\\)|8\\)|8-\\)|B-D|8-D)(\\.|\\?|!| |$)", options: []): "😎",
         try! NSRegularExpression(pattern: "(^| )(?:-_-|-__-|-___-)(\\.|\\?|!| |$)", options: []): "😑",
         try! NSRegularExpression(pattern: "(^| )(?:=\\\\\\\\|:\\\\\\\\|>:\\\\\\\\|>:/|:-/|:-\\.|:/|=/|:L|=L)(\\.|\\?|!| |$)", options: []): "😕",
         try! NSRegularExpression(pattern: "(^| )(?::P|:-P|=P|:-p|:p|=p|:-Þ|:Þ|:þ|:-þ|:-b|:b|d:)(\\.|\\?|!| |$)", options: []): "😛",
         try! NSRegularExpression(pattern: "(^| )(?::-O|:O|:-o|:o|O_O|>:O)(\\.|\\?|!| |$)", options: []): "😮",
         try! NSRegularExpression(pattern: "(^| )(?::-X|:X|:-#|:#|=X|=x|:x|:-x|=#)(\\.|\\?|!| |$)", options: []): "😶",
         try! NSRegularExpression(pattern: "(^| )(?::'\\))(\\.|\\?|!| |$)", options: []): "😂",
         try! NSRegularExpression(pattern: "(^| )(?:<3)(\\.|\\?|!| |$)", options: []): "❤️"]
    private static let emojisToTextDictionary = ["😀": ":)", "😅": "':)", "😆": ">:)", "😉": ";)", "😐": ":|", "😓": "':(", "😘": ":*",
                                                 "😜": ">:P", "😞": ">:[", "😠": ">:(", "😢": ":'(", "😣": ">.<", "😧": "D:", "😳": ":$", "😵": "#-)", "😇": "O:-)",
                                                 "😎": "B-)", "😑": "-_-", "😕": ":-/", "😛": ":P", "😮": ":-O", "😶": ":-X", "😂": ":')", "❤️": "<3"]
    /// Replace string emojis by unicode emojis
    func withUnicodeEmojis() -> String {
        var convertedString = self
        for (expression, emoji) in String.textToEmojisDictionary {
            convertedString = expression.stringByReplacingMatches(in: convertedString, options: [], range: NSMakeRange(0, (convertedString as NSString).length), withTemplate: "$1\(emoji)$2")
        }
        return convertedString
    }
    
    /// Replace unicode emojis by text emojis
    func withTextEmojis() -> String {
        var convertedString = self
        for (emoji, text) in String.emojisToTextDictionary {
            convertedString = convertedString.replacingOccurrences(of: emoji, with: " \(text) ")
        }
        return convertedString
    }
}

