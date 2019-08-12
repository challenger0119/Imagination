//
//  WebDAV.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/4/22.
//  Copyright © 2019 Star. All rights reserved.
//

import UIKit

class WebDAV: NSObject {
    static let shared = WebDAV()

    let config: WebDAVConfig
    var session: URLSession?
    let credential: URLCredential

    override init() {
        self.config = WebDAVConfig.recent() ?? WebDAVConfig.emptyConfig()
        self.credential = URLCredential(user: config.username, password: config.password, persistence: .forSession)
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
                    let parser = WebDAVParser(host: url.host!, rootHref: request.url!.absoluteString, data: data!, resultHandler: { (items) in
                        result(items)
                    })
                    parser.parser.parse()
                }
            }.resume()
        }else{
            print("URL create error")
        }
    }

    func uploadFile(filePath: String, atPath path: String) {
        if let url = URL(string: path) {
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            self.session?.uploadTask(with: request, fromFile: URL(fileURLWithPath: filePath), completionHandler: { (data, response, error) in
                print(response ?? "No response")
            }).resume()
        } else {
            print("invalid path")
        }
    }
    
    func createDir(dir: String, atPath path: String, complete: @escaping (Error?) -> Void) {
        if let url = URL(string: path) {
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            self.session?.dataTask(with: request, completionHandler: { (data, response, error) in
                print(response ?? "No response")
                complete(error)
            }).resume()
        } else {
            print("invalid path")
        }
    }

    func delete(path: String, complete: @escaping (Error?) -> Void) {
        if let url = URL(string: path) {
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            self.session?.dataTask(with: request, completionHandler: { (data, response, error) in
                print(response ?? "No response")
                complete(error)
            }).resume()

        } else {
            print("invalid path")
        }
    }
}

// MARK: - URLSessionDelegate
extension WebDAV: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, credential)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("didSendBodyData \(bytesSent) / \(totalBytesSent) / \(totalBytesExpectedToSend)")
    }
}
