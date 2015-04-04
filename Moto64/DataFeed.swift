//
//  DataFeed.swift
//  Moto64
//
//  Created by AseR on 17.03.15.
//
//

import Foundation

class DataFeed: NSObject, NSXMLParserDelegate
{
    struct Item {
        var title: String = ""
        var link: String = ""
        var pubDate: NSDate = NSDate()
        var descr: String = ""
        var isNew: Bool = true
        var latitude: Double = 0.00//51.533479//51.5405600
        var longitude: Double = 0.00//46.034264//46.0086100
    }
    
    private var feed: [Item] = []
    private var parser = NSXMLParser()
    private let linkRSS = "http://motosaratov.ru/rss/forums/2-1/"
    
    private var currentItem: Item = Item()

    private var currentElement: String = ""
    
    func getFeed() -> [Item]
    {
        return feed
    }
    
    func loadData() -> Void
    {
        if let url = NSURL (string: linkRSS) {
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            parser = NSXMLParser (contentsOfURL: url)!
            parser.delegate = self
            parser.shouldProcessNamespaces = false
            parser.shouldReportNamespacePrefixes = false
            parser.shouldResolveExternalEntities = false
            parser.parse()

        }
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!)
    {
        currentElement = elementName
        if elementName == "item" {
            currentItem = Item()
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)
    {
        currentElement = ""
        if elementName == "item" {
            feed.append(self.currentItem)
        }
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!)
    {
        switch currentElement {
        case "title": currentItem.title = string.replace("ДТП [0-9]{2}/[0-9]{2}/[0-9]{2,4} +", template: "")
        case "link": currentItem.link = string
            case "description":
                var descr = string.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                descr = descr.stringByReplacingOccurrencesOfString("&nbsp;", withString: "", options: .RegularExpressionSearch, range: nil)
                currentItem.descr = descr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

                var error: NSError? = nil
                let options = NSRegularExpressionOptions.CaseInsensitive | NSRegularExpressionOptions.DotMatchesLineSeparators
                let re1 = NSRegularExpression (pattern: ".*Широта:[^\\(]*\\((\\d+\\.\\d+)\\).*", options: options, error: &error)
                let re2 = NSRegularExpression (pattern: ".*Долгота:[^\\(]*\\((\\d+\\.\\d+)\\).*", options: options, error: &error)
                let range = NSMakeRange(0, countElements(descr))
                
                if re1?.numberOfMatchesInString(descr, options: nil, range: range) > 0 {
                    if let latitude = re1?.stringByReplacingMatchesInString(descr, options: nil, range: range, withTemplate: "$1") {
                        if let latitudeDouble = NSNumberFormatter().numberFromString(latitude)?.doubleValue {
                            currentItem.latitude = latitudeDouble
                        }
                    }
                }
                if re2?.numberOfMatchesInString(descr, options: nil, range: range) > 0 {
                    if let longitude = re2?.stringByReplacingMatchesInString(descr, options: nil, range: range, withTemplate: "$1") {
                        if let longitudeDouble = NSNumberFormatter().numberFromString(longitude)?.doubleValue {
                            currentItem.longitude = longitudeDouble
                        }
                    }
                }
            case "pubDate":
                var dateFormatter = NSDateFormatter()
                //dateFormatter.dateStyle = .FullStyle
                
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 3600 * 24 * 3) // GMT+3
                
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
                if let date = dateFormatter.dateFromString(string) {
                    currentItem.pubDate = date
                }
            default: break
        }
        
    }
    
    func parserDidEndDocument(parser: NSXMLParser!)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}