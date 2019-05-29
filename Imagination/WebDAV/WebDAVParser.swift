//
//  WebDAVParser.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/4/22.
//  Copyright © 2019 Star. All rights reserved.
//

import UIKit

typealias WebDAVParserHandler = ([WebDAVItem]) -> Void

class WebDAVParser: NSObject, XMLParserDelegate {
    let parser: XMLParser
    let parserHandler: WebDAVParserHandler
    let rootHref: String
    let lastHref: String
    var items: [WebDAVItem] = []
    var currentItem = WebDAVItem()
    var currentProperty: String = ""
    
    init(rootHref: String, data: Data, resultHandler: @escaping WebDAVParserHandler) {
        self.rootHref = rootHref
        self.lastHref = "/" + rootHref.split(separator: "/").last! + "/"
        self.parser = XMLParser(data: data)
        self.parserHandler = resultHandler
        super.init()
        self.parser.delegate = self
    }
    
    // MARK: - XMLParserDelegate
    
    func parserDidStartDocument(_ parser: XMLParser) {
        print("parserDidStartDocument")
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("parserDidEndDocument")
        self.parserHandler(items)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.currentProperty = String(elementName.split(separator: ":").last!)
        print("didStartElement elementName: \(elementName) namespaceURI:\(namespaceURI ?? "none") quelifedName: \(qName ?? "") attr: \(attributeDict)")
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("didEndElement elementName: \(elementName) namespaceURI:\(namespaceURI ?? "none") quelifedName: \(qName ?? "")")
    }
    
    func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
        print("didStartMappingPrefix \(prefix)  namesapceURI \(namespaceURI)")
    }
    
    func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
        print("didEndMappingPrefix \(prefix)")
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("parseErrorOccurred \(parseError)")
    }
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        print("validationErrorOccurred \(validationError)")
    }
    
    func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? {
        print("resolveExternalEntityName \(name)")
        return nil
    }
    
    
    func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?) {
        print("foundNotationDeclarationWithName \(name) publicID \(publicID ?? "") systemID \(systemID ?? "")")
    }
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        print("foundCDATA \(String(data: CDATABlock, encoding: .utf8)!)")
    }
    func parser(_ parser: XMLParser, foundComment comment: String) {
        print("foundComment \(comment)")
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print("foundCharacters \(string)")
        var value = string
        if self.currentProperty == "href" {
            if self.lastHref == value {
                self.currentItem.isFather = true
                value = self.rootHref
            } else {
                let end = value.index(value.startIndex, offsetBy: self.lastHref.count)
                value = String(value[end...])
                value = rootHref + "\(value)"
            }
        }
        if self.currentItem.set(key: self.currentProperty, value: value){
            self.items.append(self.currentItem)
            self.currentItem = WebDAVItem()
        }
    }
    func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
        print("foundIgnorableWhitespace \(whitespaceString)")
    }
    func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String) {
        print("foundElementDeclarationWithName \(elementName) model \(model)")
    }
    func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
        print("foundProcessingInstructionWithTarget \(target) data \(data ?? "")")
    }
    func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) {
        print("foundInternalEntityDeclarationWithName \(name) value \(value ?? "")")
    }
    func parser(_ parser: XMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {
        print("foundExternalEntityDeclarationWithName \(name) publicID \(publicID ?? "") systemID \(systemID ?? "")")
    }
    func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) {
        print("foundUnparsedEntityDeclarationWithName \(name) publicID \(publicID ?? "") systemID \(systemID ?? "")")
    }
    func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {
        print("foundAttributeDeclarationWithName \(attributeName) forElement \(elementName) type \(type ?? "") defaultValue \(defaultValue ?? "")")
    }
}
