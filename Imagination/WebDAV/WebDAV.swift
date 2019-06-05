//
//  WebDAV.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/4/22.
//  Copyright © 2019 Star. All rights reserved.
//

import UIKit

class WebDAV: NSObject, URLSessionTaskDelegate {
    static let shared = WebDAV()

    let config: WebDAVConfig
    var session: URLSession?
    
    override init() {
        self.config = WebDAVConfig.recent() ?? WebDAVConfig.emptyConfig()
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
    func loadPath(_ path:String? = nil, result:@escaping ([WebDAVItem]) -> Void){
        var urlString = self.config.server
        if let p = path, p.count > 0 {
            urlString = p
        }
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "PROPFIND"
            self.session?.dataTask(with: request) { (data, response, error) in
                if let e = error {
                    print(e)
                }else{
                    print(String(data: data!, encoding: .utf8)!)
                    let parser = WebDAVParser(rootHref: request.url!.absoluteString, data: data!, resultHandler: { (items) in
                        result(items)
                    })
                    parser.parser.parse()
                }
            }.resume()
        }else{
            print("URL create error")
        }
    }
    
    // MARK: - URLSessionDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(user: config.username, password: config.password, persistence: .forSession))
    }
    
    
}
