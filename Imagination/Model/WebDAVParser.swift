//
//  WebDAVParser.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/4/22.
//  Copyright © 2019 Star. All rights reserved.
//

import UIKit

class WebDAVParser: NSObject, XMLParserDelegate {
    let parser:XMLParser
    
    init(data: Data) {
        self.parser = XMLParser(data: data)
        super.init()
        self.parser.delegate = self
    }
    
    // MARK: - XMLParserDelegate
    
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
