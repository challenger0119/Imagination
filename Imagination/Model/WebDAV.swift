//
//  WebDAV.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/4/22.
//  Copyright © 2019 Star. All rights reserved.
//

import UIKit

class WebDAV: NSObject, URLSessionDelegate {
    let server:String
    let username:String
    let password:String
    var session:URLSession?
    
    init(withServer server:String, username:String, password:String) {
        self.server = server
        self.username = username
        self.password = password
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
    func loadPath(_ path:String? = nil, result:([WebDAVItem]) -> Void){
        var urlString = self.server
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
                    
                }
            }.resume()
        }else{
            print("URL create error")
        }
       
    }
    
}
