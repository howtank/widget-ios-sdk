//
//  NSRegularExpressionExtenion.swift
//  HowtankWidgetSwift
//
//  Created by Damien Dorizy on 05/02/2018.
//  Copyright © 2018 Howtank. All rights reserved.
//

extension NSRegularExpression {
    
    static let whiteSpaces = try! NSRegularExpression(pattern: "(\\s)\\s+", options: [.caseInsensitive, .dotMatchesLineSeparators])
    
    struct Range {
        let range: NSRange
        let string: String
    }
    
    struct Result {
        let result: NSTextCheckingResult
        let ranges: [Int: Range]
    }    
    // MARK: - Common tools
    
    internal func firstMatch(in string: String, ranges: [Int]) -> Result? {
        if let result = self.firstMatch(in: string, options: [], range: NSMakeRange(0, (string as NSString).length)) {
            let rangesRes = ranges.reduce([Int: Range](), { (dictionary, rangeIndex) -> [Int: Range] in
                var dic = dictionary
                let range = result.range(at: rangeIndex)
                dic[rangeIndex] = Range(range: range, string: (string as NSString).substring(with: range))
                return dic
            })
            return Result(result: result, ranges: rangesRes)
        }
        return nil
    }
        
    // MARK: - Links
    private static let imagesExtensions = ["gif", "png", "jpg", "jpeg"]
    private static let linkDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    struct Link {
        public let range: NSRange
        public let url: URL
        public let image: Bool
    }
    
    static func links(in string: String) -> [Link] {
        var links = [Link]()
        let detectedLinksOrImages = NSRegularExpression.linkDetector.matches(in: string, options: [], range: NSMakeRange(0, (string as NSString).length))
        if detectedLinksOrImages.count > 0 {
            for detected in detectedLinksOrImages {
                let linkOrImage = (string as NSString).substring(with: detected.range)
                
                if let url = URL(string: linkOrImage) {
                    if NSRegularExpression.imagesExtensions.first(where: { linkOrImage.lowercased().contains(".\($0)") }) != nil {
                        links.append(Link(range: detected.range, url: url, image: true))
                    }
                    else {
                        links.append(Link(range: detected.range, url: url, image: false))
                    }
                }
            }
        }
        return links
    }    
    // MARK: - Videos
    private static let youtubeUrls = try! NSRegularExpression(pattern: "http(?:s?)://(?:www\\.)?youtu(?:be\\.com/watch\\?v=|\\.be/)([\\w-_]*)(&(amp;)?‌​[\\w\\?‌​=]*)?", options: [.caseInsensitive, .dotMatchesLineSeparators])
    struct Video {
        public let range: NSRange
        public let id: String
    }
    
    static func firstVideo(in string: String) -> Video? {
        if let result = NSRegularExpression.youtubeUrls.firstMatch(in: string, ranges: [1]) {
            return Video(range: result.result.range, id: result.ranges[1]!.string)
        }
        return nil
    }
    
    
}
